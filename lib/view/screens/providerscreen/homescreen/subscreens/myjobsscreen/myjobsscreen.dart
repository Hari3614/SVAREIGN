import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Myjobsscreen extends StatelessWidget {
  const Myjobsscreen({super.key});

  Future<void> _launchPhone(String phoneNumber, BuildContext context) async {
    final phonenumber = phoneNumber.replaceAll('+', "").trim();
    final uri = Uri.parse("tel:$phonenumber");
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("failed to call")));
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber, BuildContext context) async {
    final phonenumber = phoneNumber.replaceAll('+', "").trim();
    final uri = Uri.parse("https://wa.me/$phonenumber");
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("failed to call")));
    }
  }

  Future<void> _showpaymentdialogue(
    BuildContext context,
    String requestDocId,
    String parentDocpath,
  ) async {
    final amountcontroller = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Enter the final amount"),
            content: TextField(
              controller: amountcontroller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Enter Amount"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amount = amountcontroller.text.trim();
                  if (amount.isEmpty || double.tryParse(amount) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please Enter a valid amount"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final finalamount = double.parse(amount);
                  await _markWorkAsComplete(
                    requestDocId,
                    parentDocpath,
                    finalamount,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Job Marked as complete"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text("Submit"),
              ),
            ],
          ),
    );
  }

  Future<void> _markWorkAsComplete(
    String requestDocId,
    String parentDocPath,
    double finalAmount,
  ) async {
    try {
      final providerId = FirebaseAuth.instance.currentUser!.uid;

      // Get request data from global collection
      final requestRef = FirebaseFirestore.instance
          .collection('requests')
          .doc(requestDocId);
      final requestSnap = await requestRef.get();
      if (!requestSnap.exists) {
        throw Exception("Request document not found");
      }
      final requestData = requestSnap.data() as Map<String, dynamic>;

      // 1️⃣ Get user name
      final userSnap =
          await FirebaseFirestore.instance.doc(parentDocPath).get();
      final userName =
          userSnap.exists ? (userSnap.data()?['name'] ?? "Unknown") : "Unknown";

      // 2️⃣ Get work description
      final workSnap =
          await FirebaseFirestore.instance
              .collection("works")
              .doc(requestData['jobId'])
              .get();
      final workDescription =
          workSnap.exists
              ? (workSnap.data()?['description'] ?? "No description")
              : "No description";

      // 3️⃣ Update request status in both global and user's subcollection
      await requestRef.update({
        'status': 'Completed',
        'finalAmount': finalAmount,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Update in user's subcollection as well
      await FirebaseFirestore.instance
          .doc('$parentDocPath/requests/$requestDocId')
          .update({
            'status': 'Completed',
            'finalAmount': finalAmount,
            'completedAt': FieldValue.serverTimestamp(),
          });

      // 4️⃣ Save to provider's completedJobs
      await FirebaseFirestore.instance
          .collection('services')
          .doc(providerId)
          .collection('completedWorks')
          .doc(requestDocId)
          .set({
            ...requestData, // original request fields
            'status': 'Completed',
            'finalAmount': finalAmount,
            'completedAt': FieldValue.serverTimestamp(),
            'userName': userName,
            'description': workDescription,
          });

      print(" Work marked complete and saved to provider's completedJobs.");
    } catch (e) {
      print(" Error updating work status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String providerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "My Jobs",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.lightGreen,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('requests')
                .where('providerId', isEqualTo: providerId)
                .where("status", isEqualTo: "Accepted")
                .snapshots(),
        builder: (context, snapshot) {
          debugPrint(
            "My Jobs screen - snapshot state: ${snapshot.connectionState}",
          );

          if (snapshot.hasError) {
            debugPrint("My Jobs screen - error: ${snapshot.error}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Error loading Jobs"),
                  Text("Error: ${snapshot.error.toString()}"),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            debugPrint("My Jobs screen - no data");
            return const Center(child: Text("No data available"));
          }

          final docs = snapshot.data!.docs;
          debugPrint("My Jobs screen - found ${docs.length} accepted jobs");

          if (docs.isEmpty) {
            return const Center(child: Text("No Accepted Jobs yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              debugPrint("Processing job request: ${docs[index].id}");

              final userId = data['userId'];
              final workId = data['jobId'];
              final requestDocId = docs[index].id;
              // For global requests, we might need the userDocPath
              final userDocPath =
                  data['userDocPath'] as String? ?? 'users/$userId';

              // Add error handling for missing data
              if (userId == null || workId == null) {
                debugPrint("Invalid request data - missing userId or workId");
                return const ListTile(
                  title: Text("Invalid request data"),
                  subtitle: Text("Missing user or work information"),
                );
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.doc(userDocPath).get(),
                builder: (context, usersnapshot) {
                  if (usersnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (usersnapshot.hasError) {
                    return ListTile(
                      title: const Text("Error loading user data"),
                      subtitle: Text("Error: ${usersnapshot.error.toString()}"),
                    );
                  }
                  if (!usersnapshot.hasData || !usersnapshot.data!.exists) {
                    return const ListTile(
                      title: Text("Error loading user data"),
                      subtitle: Text("Unable to fetch customer information"),
                    );
                  }

                  final userdata =
                      usersnapshot.data!.data() as Map<String, dynamic>;
                  final userName = userdata['name'] ?? "Unknown";
                  final userPhone = userdata['phone'] ?? "";

                  return FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('works')
                            .doc(workId)
                            .get(),
                    builder: (context, worksnapshot) {
                      if (worksnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (worksnapshot.hasError) {
                        return ListTile(
                          title: Text(userName),
                          subtitle: Text(
                            "Error loading work: ${worksnapshot.error.toString()}",
                          ),
                        );
                      }
                      if (!worksnapshot.hasData || !worksnapshot.data!.exists) {
                        return ListTile(
                          title: Text(userName),
                          subtitle: const Text("Work details not available"),
                        );
                      }

                      final workdata =
                          worksnapshot.data!.data() as Map<String, dynamic>;
                      final worktitle =
                          workdata['worktittle'] ??
                          workdata['title'] ??
                          "Unknown Work";
                      final workdesc =
                          workdata['description'] ?? "No description";
                      final minbudget =
                          workdata['minbudget'] ?? workdata['budget'] ?? "0";
                      final maxbudget = workdata['maxbudget'] ?? "0";
                      final duration = workdata['duration'] ?? "N/A";

                      return Card(
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer: $userName",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Work: $worktitle",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ExpandableText(text: workdesc),
                              Text(
                                "Budget: ₹$minbudget - ₹$maxbudget",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Duration: $duration",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Text("Phone: $userPhone"),
                              const SizedBox(height: 10),

                              // Call & WhatsApp row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed:
                                        () => _launchPhone(userPhone, context),
                                    icon: const Icon(Icons.call),
                                    label: const Text("Call"),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed:
                                        () =>
                                            _launchWhatsApp(userPhone, context),
                                    icon: const Icon(Icons.chat),
                                    label: const Text("WhatsApp"),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Complete button below row
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      () => _showpaymentdialogue(
                                        context,
                                        requestDocId,
                                        userDocPath,
                                      ),
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text("Mark as Complete"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
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

// Widget to manage long descriptions with expand/collapse
class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({super.key, required this.text});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text.trim();
    const cutoff = 150;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description: ${expanded || text.length <= cutoff ? text : '${text.substring(0, cutoff)}...'}",
          style: const TextStyle(height: 1.4, fontWeight: FontWeight.w500),
        ),
        if (text.length > cutoff)
          TextButton(
            onPressed: () => setState(() => expanded = !expanded),
            child: Text(expanded ? "Show less" : "Show more"),
          ),
      ],
    );
  }
}
