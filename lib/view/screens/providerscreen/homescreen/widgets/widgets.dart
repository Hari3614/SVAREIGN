import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:svareign/services/fetchinserviceaddres/serviceaddress.dart';
import 'package:svareign/services/location_services/fetchinguseraddress/fetching_address.dart';
import 'package:svareign/services/location_services/location_services.dart';

import 'package:svareign/view/screens/providerscreen/homescreen/subscreens/myjobsscreen/myjobsscreen.dart';
import 'package:svareign/view/screens/providerscreen/homescreen/subscreens/completedjobs/completedjobs.dart';
import 'package:svareign/view/screens/providerscreen/homescreen/subscreens/reviewscreen/reviewscreen.dart';
import 'package:http/http.dart' as http;
import 'package:svareign/viewmodel/service_provider/jobstatprovider/jobstatprovider.dart';
import 'package:svareign/viewmodel/service_provider/setupprofile/setupprofile_provider.dart';

class Homewidget extends StatefulWidget {
  const Homewidget({super.key});

  @override
  State<Homewidget> createState() => _HomewidgetState();
}

class _HomewidgetState extends State<Homewidget> {
  bool isAvailable = true;
  bool isloading = true;
  @override
  void initState() {
    Provider.of<Jobstatprovider>(context, listen: false).fetchjobstats();
    Provider.of<Profileprovider>(context, listen: false).fetchprofile();
    // Provider.of<ServiceAuthprovider>(listen: false,context).
    super.initState();
  }

  Future<Map<String, double>?> _getlatlanfromaddress(String address) async {
    final String apiKey = "AIzaSyDqpOdQdfhCp5iv-2TdmOCYJwEI0K_O8IY";
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      if (results.isNotEmpty) {
        final location = results[0]['geometry']['location'];
        return {'lat': location['lat'], 'lng': location['lng']};
      }
    } else {
      print('error fetching geocode');
    }
  }

  void _manuallocationdialogue() {
    String newlocation = "";
    List<String> suggestions = [];
    final TextEditingController searchcontroller = TextEditingController();
    String selectedlocation = "";
    Map<String, double>? selectedcordinates;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> fetchsuggestion(String input) async {
              final String apiKey = "AIzaSyDqpOdQdfhCp5iv-2TdmOCYJwEI0K_O8IY";
              final url = Uri.parse(
                'https://maps.googleapis.com/maps/api/place/autocomplete/json'
                '?input=$input&key=$apiKey&types=geocode&language=en',
              );
              final response = await http.get(url);
              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                final List predictions = data['predictions'];
                setState(() {
                  suggestions =
                      predictions
                          .map((p) => p['description'] as String)
                          .toList();
                });
              } else {
                print('error fetching suggestons: ${response.body}');
                setState(() => suggestions = []);
              }
            }

            return AlertDialog(
              title: const Text('Enter New Location'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchcontroller,
                      onChanged: (value) {
                        newlocation = value;
                        if (value.length > 2) {
                          fetchsuggestion(value);
                        } else {
                          setState(() => suggestions = []);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: "Search location",
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...suggestions.map(
                      (location) => ListTile(
                        title: Text(location),
                        onTap: () async {
                          searchcontroller.text = location;
                          selectedlocation = location;
                          final coordinates = await _getlatlanfromaddress(
                            selectedlocation,
                          );
                          if (coordinates != null) {
                            selectedcordinates = coordinates;
                            setState(() {
                              suggestions = [];
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
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
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    if (selectedcordinates != null) {
                      double lat = selectedcordinates!['lat']!;
                      double long = selectedcordinates!['long']!;
                      await FirebaseFirestore.instance
                          .collection('services')
                          .doc(uid)
                          .update({
                            'location': {'latitude': lat, 'longitude': long},
                          });
                      Navigator.of(context).pop();
                      print("No location selection");
                    }
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showlocationoption() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose location option",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text(
                  "Use my current location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  CircularProgressIndicator();
                  Navigator.of(context).pop();
                  setState(() {
                    isloading = true;
                  });
                  Position? position = await LocationService()
                      .getCurrentLocation(context);
                  if (position != null) {
                    double lat = position.latitude;
                    double lng = position.longitude;
                    String userId = FirebaseAuth.instance.currentUser!.uid;
                    await FirebaseFirestore.instance
                        .collection('services')
                        .doc(userId)
                        .update({
                          'location': {'latitude': lat, 'longitude': lng},
                        });
                  } else {
                    print("failed to get the location");
                  }

                  setState(() {
                    isloading = false;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.location_city),
                title: const Text(
                  "Change Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () => _manuallocationdialogue(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobstats = Provider.of<Jobstatprovider>(context);
    final profileprovider = Provider.of<Profileprovider>(context);
    final profilename = profileprovider.profile?.fullname;
    final imagepath = profileprovider.profile?.imageurl ?? "";
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            Icon(Icons.home, color: Colors.deepPurpleAccent, size: 28),
            SizedBox(width: width * 0.02),
            Text(
              "Home",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JobStatsCard(
                onlocationtap: _showlocationoption,
                providerName: profilename ?? "Unknown",
                isAvailable: isAvailable,
                imagepath: imagepath,
                location: "",
                onToggle: (value) {
                  setState(() {
                    isAvailable = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Recentactivitycard(),
              const Divider(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Quick Stats",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Statcard(
                    label: "Jobs Today",
                    value:
                        jobstats.isloading
                            ? "..."
                            : jobstats.jobtodaycount.toString(),
                  ),
                  Statcard(
                    label: 'Completed',
                    value:
                        jobstats.isloading
                            ? "..."
                            : jobstats.completedjobcount.toString(),
                  ),
                ],
              ),
              const Divider(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 2,
                  children: const [
                    Quickactionboard(icon: Icons.assignment, label: "My Jobs"),
                    Quickactionboard(icon: Icons.reviews, label: "Reviews"),
                    Quickactionboard(
                      icon: Icons.assignment_turned_in,
                      label: "Completed Jobs",
                    ),
                    Quickactionboard(icon: Icons.settings, label: "Settings"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class JobStatsCard extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onToggle;
  final String providerName;
  final String imagepath;
  final String location;
  final VoidCallback onlocationtap;
  const JobStatsCard({
    super.key,
    required this.isAvailable,
    required this.onToggle,
    required this.providerName,
    required this.imagepath,
    required this.onlocationtap,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDF9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, $providerName 👋",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: onlocationtap,

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 19),
                      FutureBuilder<String?>(
                        future: serviceaddress.getserviceaddress(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              "Loading....",
                              style: TextStyle(color: Colors.black),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              'Unknown error',
                              style: TextStyle(color: Colors.black),
                            );
                          } else if (snapshot.data == null) {
                            return const Text(
                              "Location Not available",
                              style: TextStyle(color: Colors.black),
                            );
                          } else {
                            return Text(
                              snapshot.data!,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Availability",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isAvailable,
                      activeColor: Colors.deepPurple,
                      onChanged: onToggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 40,
            backgroundImage:
                imagepath.isNotEmpty
                    ? NetworkImage(imagepath)
                    : AssetImage(
                      "assets/images/pngtree-icon-add-people-profile-new-button-vector-png-image_26219400.jpg",
                    ),
          ),
        ],
      ),
    );
  }
}

class Recentactivitycard extends StatelessWidget {
  const Recentactivitycard({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      height: height * 0.22,
      width: width * 0.9,
      margin: EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Todays Activity",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Check Activities",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: Text(
              "See Details",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class Statcard extends StatelessWidget {
  const Statcard({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: width * 0.42,
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class Quickactionboard extends StatelessWidget {
  final IconData icon;
  final String label;

  const Quickactionboard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == "My Jobs") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Myjobsscreen()),
          );
        } else if (label == "Completed Jobs") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Completedjobs()),
          );
        } else if (label == "Reviews") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Reviewscreen()),
          );
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
