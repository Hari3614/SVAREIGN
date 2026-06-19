import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:provider/provider.dart';
import 'package:svareign/view/screens/providerscreen/servicepostscreen/widgets/servieaddwidgetscreen.dart';
import 'package:svareign/viewmodel/service_provider/jobads/jobadsprovider.dart';
import 'package:svareign/model/serviceprovider/jobsadsmodel.dart';
import 'package:svareign/widgets/cached_image.dart';

class Serviceadscreen extends StatefulWidget {
  const Serviceadscreen({super.key});

  @override
  State<Serviceadscreen> createState() => _ServiceadscreenState();
}

class _ServiceadscreenState extends State<Serviceadscreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  double _radiusKm = 10;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchplaceandPosts();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
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
                    await provider.deletePost(post.id, user.uid);
                    if (context.mounted) {
                      Fluttertoast.showToast(
                        msg: 'Post deleted successfully',
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Fluttertoast.showToast(
                        msg: 'Error deleting post',
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
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
  }

  Future<void> _fetchplaceandPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final jobadsProvider = Provider.of<Jobadsprovider>(context, listen: false);
    jobadsProvider.fetchMyPosts();
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('services')
              .doc(user.uid)
              .get();
      final lat = doc.data()?['location']?['latitude'];
      final lng = doc.data()?['location']?['longitude'];
      if (lat != null && lng != null) {
        _userLat = (lat as num).toDouble();
        _userLng = (lng as num).toDouble();
        jobadsProvider.fetchglobalposts(
          userLat: _userLat!,
          userLng: _userLng!,
          radiusinKm: _radiusKm,
        );
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
        title: const Text(
          "Service Posts",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.5),
          indicatorColor: kPrimaryAccent,
          tabs: const [Tab(text: "My Posts"), Tab(text: "All Posts")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMyPostsTab(), _buildAllPostsTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Serviceaddwidget()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMyPostsTab() {
    return Consumer<Jobadsprovider>(
      builder: (context, provider, _) {
        if (provider.isMyPostsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryAccent),
          );
        }

        if (provider.myposts.isEmpty) {
          return const Center(
            child: Text("You haven't created any posts yet."),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 12),
          itemCount: provider.myposts.length,
          itemBuilder: (context, index) {
            final post = provider.myposts[index];
            return _buildPostCard(post, provider, showDelete: true);
          },
        );
      },
    );
  }

  Widget _buildAllPostsTab() {
    return Consumer<Jobadsprovider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                child: Center(child: Text("No posts available nearby.")),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 12),
                  itemCount: provider.globalposts.length,
                  itemBuilder: (context, index) {
                    final post = provider.globalposts[index];
                    return _buildPostCard(post, provider, showDelete: false);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(
    Jobsadsmodel posts,
    Jobadsprovider provider, {
    required bool showDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: Icon(Icons.image, size: 40)),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  posts.tittle,
                  style: const TextStyle(
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
                  "Budget: ₹${posts.budget}",
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  "Available Time: ${posts.starttime} - ${posts.endtime}",
                  style: const TextStyle(fontSize: 13),
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
                if (showDelete) ...[
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
