import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    final jobPostProvider = Provider.of<Jobpostprovider>(context);
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
                                          requestStates[index]
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
                                                await reqstprovider
                                                    .sendreqstuser(
                                                      userId: job.userId,
                                                      providerId: providerId,
                                                      jobId: job.id,
                                                    );
                                                setState(() {
                                                  requestStates[index] = true;
                                                });
                                              },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            requestStates[index]
                                                ? Colors.grey
                                                : null,
                                      ),
                                      child: Text(
                                        requestStates[index]
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
