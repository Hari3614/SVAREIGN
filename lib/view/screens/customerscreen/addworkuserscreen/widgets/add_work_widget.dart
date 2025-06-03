import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/customer/addwork._model.dart';
import 'package:svareign/view/screens/customerscreen/customer_reqst_screen/customreqst_screen.dart';
import 'package:svareign/viewmodel/customerprovider/addworkprovider/addworkprovider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AddWorkWidget extends StatelessWidget {
  const AddWorkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final workprovider = Provider.of<Workprovider>(context, listen: false);

    return StreamBuilder<List<Addworkmodel>>(
      stream: workprovider.getworks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.black),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong: ${snapshot.error}'));
        }
        print("snapshot : $snapshot");
        final works = snapshot.data ?? [];
        print("work is :$works");
        if (works.isEmpty) {
          return const Center(child: Text("No tasks found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: works.length,
          itemBuilder: (context, index) {
            final work = works[index];

            return Dismissible(
              key: Key(work.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(right: 20),
                child: Icon(Icons.delete, color: Colors.white, size: 30),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) async {
                await workprovider.deletework(work.id);
                // ScaffoldMessenger.of(
                //   context,
                // ).showSnackBar(SnackBar(content: Text("work deleted")));
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Posted ${timeago.format(work.postedtime)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.pending_actions_outlined,
                            color: const Color.fromARGB(255, 192, 31, 31),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        work.worktittle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "Budget: ",
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextSpan(
                              text: "₹${work.minbudget}-${work.maxbudget}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        work.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),

                      const Divider(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.timer, size: 18),
                            label: Text(work.duration),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomreqstScreen(),
                                ),
                              );
                            },
                            child: const Text("Requests"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
