import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';

class DeleteAccountScreen extends StatefulWidget {
  final String role; // 'user' or 'provider'
  const DeleteAccountScreen({super.key, required this.role});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String? selectedReason;
  final TextEditingController otherController = TextEditingController();
  bool isLoading = false;

  List<String> get predefinedReasons {
    return widget.role == "user"
        ? [
          "Didn’t get a service provider",
          "Service provider was unprofessional",
          "Too many bugs or crashes",
          "App not useful for me",
          "Found another platform",
          "Privacy or security concerns",
        ]
        : [
          "Didn’t get enough bookings",
          "Payment or commission issues",
          "Technical issues with the app",
          "Not getting relevant job requests",
          "Switching to another platform",
        ];
  }

  Future<void> deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No user logged in")));
      return;
    }

    setState(() => isLoading = true);

    final reason =
        selectedReason ??
        (otherController.text.isNotEmpty
            ? otherController.text.trim()
            : "No reason provided");

    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('users').doc(user.uid);
      final providerDoc = firestore.collection('services').doc(user.uid);

      // Save feedback
      await firestore.collection('account_feedback').add({
        'uid': user.uid,
        'role': widget.role,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Delete profile data
      final userSnap = await userDoc.get();
      final providerSnap = await providerDoc.get();

      if (userSnap.exists) {
        await userDoc.delete();
      } else if (providerSnap.exists) {
        await providerDoc.delete();
      }

      // Delete Firebase Auth account
      await user.delete();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Loginscreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Auth error")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Delete Account"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "We’re sorry to see you go 😔",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please tell us why you’re deleting your account:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    children: [
                      ...predefinedReasons.map(
                        (r) => RadioListTile<String>(
                          title: Text(r),
                          value: r,
                          groupValue: selectedReason,
                          onChanged:
                              (val) => setState(() => selectedReason = val),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: otherController,
                        decoration: const InputDecoration(
                          labelText: "Other reason (optional)",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            selectedReason == null &&
                                    otherController.text.isEmpty
                                ? null
                                : () => deleteAccount(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Delete My Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
