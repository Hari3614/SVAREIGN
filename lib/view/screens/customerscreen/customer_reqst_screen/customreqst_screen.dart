import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/customerprovider/userrequestprovider/userrequestprovider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomreqstScreen extends StatefulWidget {
  const CustomreqstScreen({super.key});

  @override
  State<CustomreqstScreen> createState() => _CustomreqstScreenState();
}

class _CustomreqstScreenState extends State<CustomreqstScreen> {
  @override
  void initState() {
    super.initState();
    final userid = FirebaseAuth.instance.currentUser?.uid;
    Provider.of<Userrequestprovider>(
      context,
      listen: false,
    ).loadrequest(userid.toString());
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text("Requests")),
      body: Consumer<Userrequestprovider>(
        builder: (context, provider, _) {
          final request = provider.request;
          if (request.isEmpty) {
            return const Center(child: Text('No requests found'));
          }

          return ListView.builder(
            itemCount: request.length,
            itemBuilder: (context, index) {
              final req = request[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            req.imagepath ?? '',
                            width: width * 0.18,
                            height: height * 0.08,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      req.name ?? "Unknown",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '4.2',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.star,
                                        size: 18,
                                        color: Color(0xFFF6C104),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 9),
                              Text(
                                req.jobs?.join(', ') ?? "",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoColumn("Experience", "${req.experience}"),
                        _infoColumn("Projects completed", "200"),
                        _infoColumn("Reviews", "140"),
                      ],
                    ),
                    const Divider(height: 20),
                    const SizedBox(height: 10),

                    if (req.status == "Accepted")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Work in Progress",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final cleanednumber =
                                      req.phonenumber
                                          .replaceAll("+", "")
                                          .trim();
                                  final url = Uri.parse('tel:$cleanednumber');
                                  final launched = await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (!launched) {
                                    print("Failed to launch whatsapp");
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Failed to call"),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.phone),
                                label: Text("Call"),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final cleanedNumber =
                                      req.phonenumber
                                          .replaceAll("+", "")
                                          .trim();
                                  final url = Uri.parse(
                                    "https://wa.me/$cleanedNumber",
                                  );
                                  print(
                                    "Trying to launch WhatsApp with URL: $url",
                                  );

                                  final launched = await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (!launched) {
                                    print("Failed to launch WhatsApp");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Failed to open WhatsApp",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.chat),
                                label: const Text("WhatsApp"),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              final userid =
                                  FirebaseAuth.instance.currentUser!.uid;
                              if (userid != null) {
                                Provider.of<Userrequestprovider>(
                                  context,
                                  listen: false,
                                ).updaterequeststatus(
                                  userId: userid,
                                  reqstId: req.id,
                                  newstatus: "Rejected",
                                );
                              }
                            },
                            icon: Icon(Icons.close, color: Colors.red),
                            label: Text("Reject"),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              print("onpressed");
                              final userid =
                                  FirebaseAuth.instance.currentUser!.uid;
                              if (userid != null) {
                                Provider.of<Userrequestprovider>(
                                  context,
                                  listen: false,
                                ).updaterequeststatus(
                                  userId: userid,
                                  reqstId: req.id,
                                  newstatus: "Accepted",
                                );
                              }
                            },
                            label: Text("Accept"),
                            icon: Icon(Icons.check, color: Colors.green),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
