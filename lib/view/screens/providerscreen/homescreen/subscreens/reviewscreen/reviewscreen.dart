import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/customerprovider/addworkprovider/reviewprovider/reviewprovider.dart';

class Reviewscreen extends StatefulWidget {
  const Reviewscreen({super.key});

  @override
  State<Reviewscreen> createState() => _ReviewscreenState();
}

class _ReviewscreenState extends State<Reviewscreen> {
  @override
  void initState() {
    super.initState();
    final providerid = FirebaseAuth.instance.currentUser?.uid;
    if (providerid != null) {
      Provider.of<ReviewProvider>(
        context,
        listen: false,
      ).fetchReviews(providerid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reviews",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewprovider, child) {
          final reviews = reviewprovider.reviews;
          if (reviews.isEmpty) {
            return const Center(child: Text("No Reviews found"));
          } else {
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];

                return FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(review.userid)
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: LinearProgressIndicator(),
                      );
                    }

                    final userData =
                        snapshot.data?.data() as Map<String, dynamic>?;
                    final username = userData?['name'] ?? 'Unknown User';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username + Star Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.review,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
