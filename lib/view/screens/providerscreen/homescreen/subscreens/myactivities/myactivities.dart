import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:svareign/viewmodel/service_provider/booknndfetchprovider/ordersfromuserprovider.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<Ordersfromuserprovider>(
        context,
        listen: false,
      ).fetchbookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<Ordersfromuserprovider>(context);
    final bookings = bookingProvider.bookings;

    final requestedBookings =
        bookings.where((b) => b.status == 'pending').toList();
    final acceptedBookings =
        bookings.where((b) => b.status == 'Accepted').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          centerTitle: true,
          backgroundColor: Colors.lightGreen,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [Tab(text: 'Requests'), Tab(text: 'Accepted')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingList(requestedBookings, 'No new requests'),
            _buildBookingList(acceptedBookings, 'No accepted bookings'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List bookings, String emptyText) {
    if (bookings.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ListView.builder(
      itemCount: bookings.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(booking.imagePath),
              radius: 30,
            ),
            title: Text(
              booking.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Work: ${booking.description}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  "Date: ${booking.bookingDate}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  "Time: ${booking.bookingTime}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  "Phone: ${booking.phoneNumber}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                if (booking.status == 'pending') ...[
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Provider.of<Ordersfromuserprovider>(
                            context,
                            listen: false,
                          ).updatebookings(booking.bookingId, "Accepted");
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          "Accept",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Provider.of<Ordersfromuserprovider>(
                            context,
                            listen: false,
                          ).updatebookings(booking.bookingId, 'Declined');
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text(
                          "Decline",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ] else if (booking.status == 'Accepted') ...[
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          final Uri callUri = Uri(
                            scheme: 'tel',
                            path: booking.phoneNumber,
                          );
                          launchUrl(callUri);
                        },
                        icon: Icon(Icons.call, color: Colors.white),
                        label: Text(
                          "Call",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          final Uri whatsappUri = Uri.parse(
                            "https://wa.me/${booking.phoneNumber}",
                          );
                          launchUrl(whatsappUri);
                        },
                        icon: Icon(Icons.chat, color: Colors.white),
                        label: Text(
                          "WhatsApp",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Provider.of<Ordersfromuserprovider>(
                        context,
                        listen: false,
                      ).updatebookings(booking.bookingId, "completed");
                    },
                    icon: Icon(Icons.check_circle_outline, color: Colors.white),
                    label: Text(
                      "Mark as Complete",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
