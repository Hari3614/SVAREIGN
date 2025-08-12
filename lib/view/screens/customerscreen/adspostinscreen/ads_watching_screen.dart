import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/service_provider/jobads/jobadsprovider.dart';
import 'package:svareign/viewmodel/service_provider/jobpost/jobpost.dart';

class AdswatchingScreen extends StatefulWidget {
  const AdswatchingScreen({super.key});

  @override
  State<AdswatchingScreen> createState() => _AdswatchingScreenState();
}

class _AdswatchingScreenState extends State<AdswatchingScreen> {
  @override
  void initState() {
    super.initState();
    _loadserviceproviderplaceandStartlistening();
  }

  Future<void> _loadserviceproviderplaceandStartlistening() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('services')
              .doc(user.uid)
              .get();
      final place = doc.data()?['place'];
      if (place != null && place is String) {
        final jobpostProvider = Provider.of<Jobpostprovider>(
          context,
          listen: false,
        );
        jobpostProvider.startlisteningTojobs(place);
      } else {
        print("place is null");
      }
    } catch (e) {
      print("error fetching place:$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Service Posts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
      ),
      body: Consumer<Jobadsprovider>(
        builder: (context, provider, _) {
          if (provider.isloading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.lightGreen),
            );
          }

          if (provider.globalposts.isEmpty) {
            return const Center(child: Text("No service posts available."));
          }

          return ListView.builder(
            itemCount: provider.globalposts.length,
            itemBuilder: (context, index) {
              final post = provider.globalposts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.imageurl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: CarouselSlider(
                          items:
                              post.imageurl.map((imageUrl) {
                                return Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Center(
                                            child: Icon(Icons.broken_image),
                                          ),
                                );
                              }).toList(),
                          options: CarouselOptions(
                            height: 180,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 1.0,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image, size: 40)),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Budget: ₹${post.budget ?? 0}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Available Time: ${post.starttime} - ${post.endtime}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text(
                                "Chat via WhatsApp",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
