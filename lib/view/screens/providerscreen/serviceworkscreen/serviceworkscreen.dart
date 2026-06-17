import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/service_provider/Serviceproivdereqst/servicereqsrprovider.dart';
import 'package:svareign/viewmodel/service_provider/jobpost/jobpost.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:svareign/widgets/cached_image.dart';

class ServiceProviderHome extends StatefulWidget {
  const ServiceProviderHome({super.key});

  @override
  State<ServiceProviderHome> createState() => _ServiceProviderHomeState();
}

class _ServiceProviderHomeState extends State<ServiceProviderHome>
    with TickerProviderStateMixin {
  List<bool> expandedStates = [];
  List<bool> requestStates = [];
  double _searchRadiusKm = 100;

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

    final lat = doc.data()?['location']?['latitude'];
    final lng = doc.data()?['location']?['longitude'];
    final jobPostProvider = Provider.of<Jobpostprovider>(
      context,
      listen: false,
    );
    if (lat != null && lng != null) {
      jobPostProvider.startlisteningTojobs(
        providerLat: (lat as num).toDouble(),
        providerLng: (lng as num).toDouble(),
        radiusinKm: _searchRadiusKm,
      );
    } else {
      // No location data — show all active jobs without distance filter
      jobPostProvider.startlisteningTojobs(
        providerLat: 0,
        providerLng: 0,
        radiusinKm: double.infinity,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobCount = jobPostProvider.works.length;
      setState(() {
        expandedStates = List<bool>.generate(jobCount, (_) => false);
        requestStates = List<bool>.generate(jobCount, (_) => false);
      });
    });
  }

  Future<void> _refreshProviderJobRadius() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('services')
            .doc(user.uid)
            .get();

    final lat = doc.data()?['location']?['latitude'];
    final lng = doc.data()?['location']?['longitude'];
    if (lat != null && lng != null) {
      final jobPostProvider = Provider.of<Jobpostprovider>(
        context,
        listen: false,
      );
      jobPostProvider.startlisteningTojobs(
        providerLat: (lat as num).toDouble(),
        providerLng: (lng as num).toDouble(),
        radiusinKm: _searchRadiusKm,
      );
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
        Fluttertoast.showToast(
          msg: errorMessage,
          backgroundColor: Colors.red,
          textColor: Colors.white,
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
        centerTitle: true,
        title: const Text(
          'Jobs Post',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer radius: ${_searchRadiusKm.round()} km',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider.adaptive(
                  value: _searchRadiusKm,
                  min: 10,
                  max: 200,
                  divisions: 19,
                  label: '${_searchRadiusKm.round()} km',
                  onChanged: (value) {
                    setState(() {
                      _searchRadiusKm = value;
                    });
                  },
                  onChangeEnd: (_) {
                    _refreshProviderJobRadius();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child:
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
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.08)
                                      : null,
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
                                      maxLines:
                                          expandedStates[index] ? null : 3,
                                      overflow:
                                          expandedStates[index]
                                              ? null
                                              : TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    if (expandedStates[index]) ...[
                                      const SizedBox(height: 10),
                                      if (job.imagepath != null)
                                        AppCachedImage(
                                          imageUrl: job.imagepath.toString(),
                                          height: height * 0.22,
                                          width: double.infinity,
                                          borderRadius: BorderRadius.circular(
                                            20,
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
                                                          >(
                                                            context,
                                                            listen: false,
                                                          );

                                                      await _sendRequest(
                                                        reqstprovider:
                                                            reqstprovider,
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
          ),
        ],
      ),
    );
  }
}
