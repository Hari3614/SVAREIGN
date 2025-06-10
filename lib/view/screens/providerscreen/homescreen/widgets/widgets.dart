import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:svareign/view/screens/providerscreen/homescreen/subscreens/myjobsscreen/myjobsscreen.dart';
import 'package:svareign/view/screens/providerscreen/homescreen/subscreens/notifications/completedjobs.dart';
import 'package:svareign/viewmodel/service_provider/jobstatprovider/jobstatprovider.dart';

class Homewidget extends StatefulWidget {
  const Homewidget({super.key});

  @override
  State<Homewidget> createState() => _HomewidgetState();
}

class _HomewidgetState extends State<Homewidget> {
  bool isAvailable = true;
  @override
  void initState() {
    Provider.of<Jobstatprovider>(context, listen: false).fetchjobstats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final jobstats = Provider.of<Jobstatprovider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          "Home",
          style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JobStatsCard(
                isAvailable: isAvailable,
                onToggle: (value) {
                  setState(() {
                    isAvailable = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Today's Jobs",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                itemCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => const Joblist(),
              ),
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
                    Quickactionboard(
                      icon: Icons.notifications,
                      label: "Notifications",
                    ),
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

  const JobStatsCard({
    super.key,
    required this.isAvailable,
    required this.onToggle,
    this.providerName = "Ganesh",
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
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.purple,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class Joblist extends StatelessWidget {
  const Joblist({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hari", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("Service: Plumbing", overflow: TextOverflow.ellipsis),
            const Text("Time: Today at 4:00 PM"),
            const Text("Location: Ernakulam", overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text("Accept")),
                OutlinedButton(onPressed: () {}, child: const Text("Reject")),
              ],
            ),
          ],
        ),
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
        }
        if (label == "Completed Jobs") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Completedjobs()),
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
