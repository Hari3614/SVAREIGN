import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/serviceprovider/bookingmodel.dart';
import 'package:svareign/viewmodel/customerprovider/bookingprovider/bookingprovider.dart';

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
      Provider.of<Bookingprovider>(context, listen: false).fetchbookings();
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

                    await FirebaseFirestore.instance
                        .collection('services')
                        .doc(booking.providerId)
                        .collection('reviews')
                        .add({
                          'userId': booking.userId,
                          'providerId': booking.providerId,
                          'jobId': booking.bookingId,
                          'review': reviewText,
                          'rating': rating,
                          'timestamp': DateTime.now(),
                        });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Review submitted")),
                    );
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
    final bookingProvider = Provider.of<Bookingprovider>(context);
    final allBookings = bookingProvider.bookings;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Orders"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions, color: Colors.lightGreen),
              text: "Orders",
            ),
            Tab(
              icon: Icon(Icons.check_circle, color: Colors.lightGreen),
              text: "Completed",
            ),
            Tab(
              icon: Icon(Icons.cancel, color: Colors.lightGreen),
              text: "Rejected",
            ),
          ],
        ),
      ),
      body:
          bookingProvider.isloading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  buildBookingList(allBookings, ["pending", "Accepted"]),
                  buildBookingList(allBookings, ["completed"]),
                  buildBookingList(allBookings, ["rejected"]),
                ],
              ),
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
            leading: CircleAvatar(
              backgroundImage: NetworkImage(booking.imagePath),
            ),
            title: Text(booking.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Description: ${booking.description}"),
                Text("Date: ${booking.bookingDate}"),
                Text("Time: ${booking.bookingTime}"),
              ],
            ),
            trailing: GestureDetector(
              onTap:
                  isCompleted ? () => showReviewDialog(context, booking) : null,
              child: Chip(
                label: Text(
                  isCompleted ? "Payment" : status.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: chipColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
