import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/customer/fetchserviceprovider.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';
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
      // Fetch place from the correct collection for customers
      final doc =
          await FirebaseFirestore.instance
              .collection('users') // Changed from 'services' to 'users'
              .doc(user.uid)
              .get();

      final place = doc.data()?['place'];

      if (place != null && place is String) {
        // Use Jobadsprovider instead of Jobpostprovider
        final jobAdsProvider = Provider.of<Jobadsprovider>(
          context,
          listen: false,
        );
        jobAdsProvider.fetchglobalposts(place);
      } else {
        print("place is null or not a string");
      }
    } catch (e) {
      print("error fetching place:$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                          Column(
                            children: [
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
                                  icon: const Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Chat via WhatsApp",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade600,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final cartprovider =
                                        Provider.of<Cartprovider>(
                                          context,
                                          listen: false,
                                        );

                                    // Check if already in cart
                                    final isAlreadyInCart = cartprovider
                                        .cartitems
                                        .any(
                                          (item) =>
                                              item.serviceId == post.providerid,
                                        );

                                    if (isAlreadyInCart) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Already added to cart",
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    } else {
                                      // Add to cart
                                      final jobspostprovider =
                                          Provider.of<Jobpostprovider>(
                                            context,
                                            listen: false,
                                          );

                                      // Get provider details
                                      final providerDoc =
                                          await FirebaseFirestore.instance
                                              .collection('services')
                                              .doc(post.providerid)
                                              .collection('profile')
                                              .limit(1)
                                              .get();

                                      if (providerDoc.docs.isNotEmpty) {
                                        final profileData =
                                            providerDoc.docs.first.data();

                                        // Create a service model
                                        final serviceModel =
                                            Fetchserviceprovidermodel(
                                              serviceId: post.providerid,
                                              name:
                                                  profileData['fullname'] ??
                                                  'Unknown',
                                              imagepath:
                                                  profileData['imageurl'] ?? '',
                                              role: List<String>.from(
                                                profileData['categories'] ?? [],
                                              ),
                                              description:
                                                  profileData['description'] ??
                                                  post.description,
                                              hourlypayment:
                                                  profileData['payment'] ?? '',
                                            );

                                        cartprovider.addtocart(serviceModel);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "${profileData['fullname'] ?? 'Service provider'} added to cart",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Add to Cart",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
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
