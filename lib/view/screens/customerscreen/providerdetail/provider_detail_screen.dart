import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/customer/fetchserviceprovider.dart';
import 'package:svareign/viewmodel/customerprovider/addworkprovider/reviewprovider/reviewprovider.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';
import 'package:svareign/widgets/cached_image.dart';

class ProviderDetailScreen extends StatelessWidget {
  final Fetchserviceprovidermodel provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(provider.name), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppCachedAvatar(imageUrl: provider.imagepath, radius: 50),
                  const SizedBox(height: 12),
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (provider.role.isNotEmpty)
                    Text(
                      provider.role.join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${provider.hourlypayment}/hr",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Rating summary
                  FutureBuilder<double>(
                    future: reviewProvider.getAverageRating(provider.serviceId),
                    builder: (context, ratingSnap) {
                      final avg = ratingSnap.data ?? 0.0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < avg.round() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            avg.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      label: const Text(
                        "Add to Cart",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        final cartprovider = Provider.of<Cartprovider>(
                          context,
                          listen: false,
                        );
                        final isAlreadyInCart = cartprovider.cartitems.any(
                          (e) => e.serviceId == provider.serviceId,
                        );
                        if (isAlreadyInCart) {
                          Fluttertoast.showToast(
                            msg: '${provider.name} is already in the cart',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        } else {
                          cartprovider.addtocart(provider);
                          Fluttertoast.showToast(
                            msg: '${provider.name} added to cart',
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Reviews section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FutureBuilder<int>(
                future: reviewProvider.getreviews(provider.serviceId),
                builder: (context, countSnap) {
                  final count = countSnap.data ?? 0;
                  return Text(
                    "Reviews ($count)",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            // Reviews list
            FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('services')
                      .doc(provider.serviceId)
                      .collection('reviews')
                      .orderBy('timestamp', descending: true)
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text("No reviews yet")),
                  );
                }

                final reviews = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final data = reviews[index].data() as Map<String, dynamic>;
                    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
                    final reviewText = data['review'] ?? '';
                    final userId = data['userId'] ?? '';

                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .get(),
                      builder: (context, userSnap) {
                        final userName =
                            userSnap.data?.exists == true
                                ? ((userSnap.data!.data()
                                        as Map<String, dynamic>?)?['name'] ??
                                    'User')
                                : 'User';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  reviewText,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
