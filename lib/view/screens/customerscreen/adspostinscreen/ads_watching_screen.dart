import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/model/customer/fetchserviceprovider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';
import 'package:svareign/viewmodel/service_provider/jobads/jobadsprovider.dart';
import 'package:svareign/widgets/cached_image.dart';
import 'package:svareign/viewmodel/service_provider/jobpost/jobpost.dart';

class AdswatchingScreen extends StatefulWidget {
  const AdswatchingScreen({super.key});

  @override
  State<AdswatchingScreen> createState() => _AdswatchingScreenState();
}

class _AdswatchingScreenState extends State<AdswatchingScreen> {
  double _radiusKm = 10;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadserviceproviderplaceandStartlistening();
    });
  }

  Future<void> _loadserviceproviderplaceandStartlistening() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final lat = doc.data()?['location']?['latitude'];
      final lng = doc.data()?['location']?['longitude'];

      if (lat != null && lng != null) {
        _userLat = (lat as num).toDouble();
        _userLng = (lng as num).toDouble();
        final jobAdsProvider = Provider.of<Jobadsprovider>(
          context,
          listen: false,
        );
        jobAdsProvider.fetchglobalposts(
          userLat: _userLat!,
          userLng: _userLng!,
          radiusinKm: _radiusKm,
        );
      } else {
        print("location is null");
      }
    } catch (e) {
      print("error fetching location:$e");
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
      ),
      body: Consumer<Jobadsprovider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    const Text("Radius: ", style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Slider(
                        value: _radiusKm,
                        min: 5,
                        max: 100,
                        divisions: 19,
                        activeColor: kPrimaryAccent,
                        label: "${_radiusKm.round()} km",
                        onChanged: (value) {
                          setState(() {
                            _radiusKm = value;
                          });
                        },
                        onChangeEnd: (value) {
                          if (_userLat != null && _userLng != null) {
                            provider.fetchglobalposts(
                              userLat: _userLat!,
                              userLng: _userLng!,
                              radiusinKm: _radiusKm,
                            );
                          }
                        },
                      ),
                    ),
                    Text(
                      "${_radiusKm.round()} km",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.isloading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: kPrimaryAccent),
                  ),
                )
              else if (provider.globalposts.isEmpty)
                const Expanded(
                  child: Center(child: Text("No service posts available.")),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: provider.globalposts.length,
                    itemBuilder: (context, index) {
                      final post = provider.globalposts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
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
                                        return AppCachedImage(
                                          imageUrl: imageUrl,
                                          width: double.infinity,
                                          height: 180,
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
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: Icon(Icons.image, size: 40),
                                ),
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
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade600,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final phone = post.phonenumber;
                                            if (phone.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Phone number not available",
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            final cleaned =
                                                phone
                                                    .replaceAll('+', '')
                                                    .trim();
                                            final uri = Uri.parse(
                                              "https://wa.me/$cleaned",
                                            );
                                            if (!await launchUrl(
                                              uri,
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            )) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Failed to open WhatsApp",
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.chat,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            "Chat via WhatsApp",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orange.shade600,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                      item.serviceId ==
                                                      post.providerid,
                                                );

                                            if (isAlreadyInCart) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Already added to cart",
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange,
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
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('services')
                                                      .doc(post.providerid)
                                                      .collection('profile')
                                                      .limit(1)
                                                      .get();

                                              if (providerDoc.docs.isNotEmpty) {
                                                final profileData =
                                                    providerDoc.docs.first
                                                        .data();

                                                // Create a service model
                                                final serviceModel = Fetchserviceprovidermodel(
                                                  serviceId: post.providerid,
                                                  name:
                                                      profileData['fullname'] ??
                                                      'Unknown',
                                                  imagepath:
                                                      profileData['imageurl'] ??
                                                      '',
                                                  role: List<String>.from(
                                                    profileData['categories'] ??
                                                        [],
                                                  ),
                                                  description:
                                                      profileData['description'] ??
                                                      post.description,
                                                  hourlypayment:
                                                      profileData['payment'] ??
                                                      '',
                                                );

                                                cartprovider.addtocart(
                                                  serviceModel,
                                                );

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "${profileData['fullname'] ?? 'Service provider'} added to cart",
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
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
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
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
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
