import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/service_provider/Serviceproivdereqst/servicereqsrprovider.dart';
import 'package:svareign/viewmodel/service_provider/jobpost/jobpost.dart';
import 'package:timeago/timeago.dart' as timeago;

class ServiceProviderHome extends StatefulWidget {
  const ServiceProviderHome({super.key});

  @override
  State<ServiceProviderHome> createState() => _ServiceProviderHomeState();
}

class _ServiceProviderHomeState extends State<ServiceProviderHome>
    with TickerProviderStateMixin {
  List<bool> expandedStates = [];
  List<bool> requestStates = [];

  @override
  void initState() {
    super.initState();
    _loadServiceProviderPlaceAndStartListening();
    _loadRequestedJobs();
  }

  Future<void> _loadRequestedJobs() async {
    final providerId = FirebaseAuth.instance.currentUser?.uid;
    if (providerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final reqstprovider = Provider.of<Servicereqsrprovider>(
          context,
          listen: false,
        );
        reqstprovider.startListeningToRequests(providerId);
      });
    }
  }

  @override
  void dispose() {
    // Stop listening to requests when the widget is disposed
    final providerId = FirebaseAuth.instance.currentUser?.uid;
    if (providerId != null) {
      final reqstprovider = Provider.of<Servicereqsrprovider>(
        context,
        listen: false,
      );
      reqstprovider.stopListeningToRequests();
    }
    super.dispose();
  }

  Future<void> _loadServiceProviderPlaceAndStartListening() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('services')
            .doc(user.uid)
            .get();

    final place = doc.data()?['place'];
    if (place != null) {
      final jobPostProvider = Provider.of<Jobpostprovider>(
        context,
        listen: false,
      );
      jobPostProvider.startlisteningTojobs(place);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final jobCount = jobPostProvider.works.length;
        setState(() {
          expandedStates = List<bool>.generate(jobCount, (_) => false);
          requestStates = List<bool>.generate(jobCount, (_) => false);
        });
      });
    }
  }

  String _formatedtimestamp(DateTime timestamp) {
    return timeago.format(timestamp);
  }

  Future<void> _sendRequest({
    required Servicereqsrprovider reqstprovider,
    required String userId,
    required String providerId,
    required String jobId,
    required int index,
  }) async {
    try {
      await reqstprovider.sendreqstuser(
        userId: userId,
        providerId: providerId,
        jobId: jobId,
      );
      setState(() {
        requestStates[index] = true;
      });
    } catch (e) {
      // Handle errors when sending request
      String errorMessage = "Failed to send request";
      if (e is FirebaseException) {
        if (e.code == 'permission-denied') {
          errorMessage = "Permission denied. Please contact support.";
        } else {
          errorMessage = e.message ?? errorMessage;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }

      // Reset the button state on error
      setState(() {
        requestStates[index] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobPostProvider = Provider.of<Jobpostprovider>(context);
    final reqstprovider = Provider.of<Servicereqsrprovider>(context);
    final height = MediaQuery.of(context).size.height;

    // Make sure state list sizes match data length
    if (expandedStates.length != jobPostProvider.works.length) {
      expandedStates = List<bool>.generate(
        jobPostProvider.works.length,
        (_) => false,
      );
    }

    if (requestStates.length != jobPostProvider.works.length) {
      requestStates = List<bool>.generate(
        jobPostProvider.works.length,
        (_) => false,
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
        title: const Text(
          'Jobs Post',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body:
          jobPostProvider.works.isEmpty
              ? const Center(child: Text("No jobs available"))
              : ListView.builder(
                itemCount: jobPostProvider.works.length,
                itemBuilder: (context, index) {
                  final job = jobPostProvider.works[index];
                  // Check if this job has already been requested
                  final isAlreadyRequested = reqstprovider.requestedjobIds
                      .contains(job.id);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedStates[index] = !expandedStates[index];
                      });
                    },
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.decelerate,
                      child: Card(
                        margin: const EdgeInsets.all(12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        color:
                            expandedStates[index]
                                ? Colors.blue[50]
                                : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.tittle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                job.description,
                                maxLines: expandedStates[index] ? null : 3,
                                overflow:
                                    expandedStates[index]
                                        ? null
                                        : TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              if (expandedStates[index]) ...[
                                const SizedBox(height: 10),
                                if (job.imagepath != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      job.imagepath.toString(),
                                      height: height * 0.22,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Duration: ${job.duration}'),
                                    Text(
                                      "Budget: ${job.minbudget}-${job.maxbudget}₹",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed:
                                          isAlreadyRequested
                                              ? null
                                              : () async {
                                                final providerId =
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid;
                                                final reqstprovider =
                                                    Provider.of<
                                                      Servicereqsrprovider
                                                    >(context, listen: false);

                                                // Call the request sending method with error handling
                                                await _sendRequest(
                                                  reqstprovider: reqstprovider,
                                                  userId: job.userId,
                                                  providerId: providerId,
                                                  jobId: job.id,
                                                  index: index,
                                                );
                                              },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            isAlreadyRequested
                                                ? Colors.grey
                                                : null,
                                      ),
                                      child: Text(
                                        isAlreadyRequested
                                            ? "Requested"
                                            : "Request",
                                      ),
                                    ),
                                    Text(
                                      "Posted: ${_formatedtimestamp(job.postedtime)}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
