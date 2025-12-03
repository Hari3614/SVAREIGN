import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/view/screens/providerscreen/servicepostscreen/widgets/servieaddwidgetscreen.dart';
import 'package:svareign/viewmodel/service_provider/jobads/jobadsprovider.dart';
import 'package:svareign/model/serviceprovider/jobsadsmodel.dart';

class Serviceadscreen extends StatefulWidget {
  const Serviceadscreen({super.key});

  @override
  State<Serviceadscreen> createState() => _ServiceadscreenState();
}

class _ServiceadscreenState extends State<Serviceadscreen> {
  @override
  void initState() {
    super.initState();
    _fetchplaceandPosts();
  }

  String _formatExpiryTime(DateTime expiryTime) {
    final now = DateTime.now();
    final difference = expiryTime.difference(now);

    if (difference.isNegative) {
      return "Expired";
    }

    final inHours = difference.inHours;
    final inMinutes = difference.inMinutes % 60;

    if (inHours > 0) {
      return "$inHours hours $inMinutes minutes";
    } else {
      return "$inMinutes minutes";
    }
  }

  void _confirmDelete(
    BuildContext context,
    Jobsadsmodel post,
    Jobadsprovider provider,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        FirebaseFirestore.instance.collection('services').doc(user.uid).get();
    doc.then((value) {
      final place = value.data()?['place'] ?? '';

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Delete Post"),
              content: const Text("Are you sure you want to delete this post?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await provider.deletePost(post.id, user.uid, place);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Post deleted successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Error deleting post: ${e.toString()}",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );
    });
  }

  Future<void> _fetchplaceandPosts() async {
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
        Provider.of<Jobadsprovider>(
          context,
          listen: false,
        ).fetchglobalposts(place);
      }
    } catch (e) {
      print("error fetching the place for provider :$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
        title: const Text(
          "Service Posts",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
      ),
      body: Consumer<Jobadsprovider>(
        builder: (context, provider, _) {
          if (provider.isloading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.lightGreen),
            );
          }

          if (provider.globalposts.isEmpty) {
            return const Center(child: Text("No posts available."));
          }

          return ListView.builder(
            itemCount: provider.globalposts.length,
            itemBuilder: (context, index) {
              final posts = provider.globalposts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (posts.imageurl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: CarouselSlider(
                          items:
                              posts.imageurl.map((imageUrl) {
                                return Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
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
                            posts.tittle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            posts.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Budget: ₹${posts.budget ?? 0}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Available Time: ${posts.starttime} - ${posts.endtime}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Expires in: ${_formatExpiryTime(posts.expirytime)}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                _confirmDelete(context, posts, provider);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text("Delete"),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Serviceaddwidget()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
