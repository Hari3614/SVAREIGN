import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class Completedjobs extends StatelessWidget {
  const Completedjobs({super.key});

  @override
  Widget build(BuildContext context) {
    final providerId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Completed Jobs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collectionGroup("requests")
                .where('providerId', isEqualTo: providerId)
                .where('status', isEqualTo: "Completed")
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No completed jobs yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final userid = data['userId'];
              final workid = data['jobId'];
              final status = data['status'];

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(userid)
                        .get(),
                builder: (context, usersnapshot) {
                  if (usersnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (usersnapshot.hasError ||
                      !usersnapshot.hasData ||
                      !usersnapshot.data!.exists) {
                    return const ListTile(
                      title: Text(
                        "This job may have been removed from the user",
                      ),
                    );
                  }

                  final userdata =
                      usersnapshot.data!.data() as Map<String, dynamic>;
                  final username = userdata['name'];
                  final location = userdata['location'] as Map<String, dynamic>;
                  final lat = location['latitude'];
                  final long = location['longitude'];
                  return FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('works')
                            .doc(workid)
                            .get(),
                    builder: (context, worksnapshot) {
                      if (worksnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      if (worksnapshot.hasError ||
                          !worksnapshot.hasData ||
                          !worksnapshot.data!.exists) {
                        return const ListTile(
                          title: Text("This job my removed from the user"),
                        );
                      }

                      final workdata =
                          worksnapshot.data!.data() as Map<String, dynamic>;
                      final worktitle = workdata['worktittle'];
                      final minbudget = workdata['minbudget'];
                      final maxbudget = workdata['maxbudget'];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Customer: $username",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.work,
                                    color: Colors.blueAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Work Title: $worktitle",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Budget: ₹$minbudget - ₹$maxbudget",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              const SizedBox(height: 10),
                              FutureBuilder<List<Placemark>>(
                                future: placemarkFromCoordinates(lat, long),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text("Loading location ....."),
                                      ],
                                    );
                                  } else if (snapshot.hasError ||
                                      !snapshot.hasData) {
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text("Location Unavailable"),
                                      ],
                                    );
                                  } else {
                                    final Placemark place =
                                        snapshot.data!.first;
                                    final address =
                                        "${place.locality},${place.administrativeArea}";
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Location : $address",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Status: ",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}
