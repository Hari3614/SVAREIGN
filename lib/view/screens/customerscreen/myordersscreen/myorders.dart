import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/serviceprovider/bookingmodel.dart';
import 'package:svareign/viewmodel/customerprovider/bookingprovider/bookingprovider.dart';
import 'package:svareign/widgets/cached_image.dart';
import 'package:svareign/viewmodel/customerprovider/addworkprovider/reviewprovider/reviewprovider.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.delayed(Duration.zero, () {
      try {
        Provider.of<Bookingprovider>(context, listen: false).fetchbookings();
      } catch (e) {
        print("Error initializing bookings: $e");
        // Show error message to user
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Fluttertoast.showToast(
              msg: 'Failed to load bookings. Please try again.',
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        });
      }
      // Provider.of<Bookingprovider>(context, listen: false).fetproviderforuser();
    });
  }

  void showReviewDialog(BuildContext context, Bookingmodel booking) {
    final TextEditingController reviewController = TextEditingController();
    double rating = 3.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Rate and Review"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      labelText: "Write your review",
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Text("Rating: ${rating.toStringAsFixed(1)}"),
                  Slider(
                    value: rating,
                    onChanged: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: rating.toStringAsFixed(1),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final reviewText = reviewController.text.trim();
                    if (reviewText.isEmpty) return;

                    final reviewProvider = Provider.of<ReviewProvider>(
                      context,
                      listen: false,
                    );
                    final success = await reviewProvider.addReview(
                      providerId: booking.providerId,
                      jobId: booking.bookingId,
                      reviewText: reviewText,
                      rating: rating,
                    );

                    Navigator.pop(context);
                    if (success) {
                      Fluttertoast.showToast(
                        msg: 'Review submitted',
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                      setState(() {});
                    } else {
                      Fluttertoast.showToast(
                        msg: 'You have already reviewed this task',
                        backgroundColor: Colors.orange,
                        textColor: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Bookingprovider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isloading) {
          return Scaffold(
            appBar: AppBar(title: const Text("My Orders")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final allBookings = bookingProvider.bookings;

        return Scaffold(
          appBar: AppBar(
            title: const Text("My Orders"),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.pending_actions), text: "Orders"),
                Tab(icon: Icon(Icons.check_circle), text: "Completed"),
                Tab(icon: Icon(Icons.cancel), text: "Rejected"),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              buildBookingList(allBookings, ["pending", "Accepted"]),
              buildBookingList(allBookings, ["completed"]),
              buildBookingList(allBookings, ["rejected"]),
            ],
          ),
        );
      },
    );
  }

  Widget buildBookingList(List<Bookingmodel> bookings, List<String> statuses) {
    final filtered =
        bookings.where((b) => statuses.contains(b.status)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.info_outline, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text("No bookings available", style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final booking = filtered[index];
        final status = booking.status;
        final isCompleted = status == "completed";

        Color chipColor = switch (status) {
          "Accepted" => Colors.green,
          "pending" => Colors.orange,
          "completed" => Colors.blue,
          _ => Colors.red,
        };

        return Card(
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListTile(
            leading: AppCachedAvatar(imageUrl: booking.imagePath),
            title: Text(booking.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Description: ${booking.description}"),
                Text("Date: ${booking.bookingDate}"),
                Text("Time: ${booking.bookingTime}"),
              ],
            ),
            trailing:
                isCompleted
                    ? FutureBuilder<bool>(
                      future: Provider.of<ReviewProvider>(
                        context,
                        listen: false,
                      ).hasUserReviewedJob(
                        providerId: booking.providerId,
                        jobId: booking.bookingId,
                      ),
                      builder: (context, snapshot) {
                        final alreadyReviewed = snapshot.data ?? false;
                        return GestureDetector(
                          onTap:
                              alreadyReviewed
                                  ? null
                                  : () {
                                    showReviewDialog(context, booking);
                                  },
                          child: Chip(
                            label: Text(
                              alreadyReviewed ? "Reviewed" : "Review",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                alreadyReviewed ? Colors.grey : Colors.blue,
                          ),
                        );
                      },
                    )
                    : Chip(
                      label: Text(
                        status.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: chipColor,
                    ),
          ),
        );
      },
    );
  }
}
