import 'package:flutter/material.dart';
import 'package:svareign/view/screens/addworkuserscreen/floatingaction/floating_action_widget.dart';
import 'package:svareign/view/screens/addworkuserscreen/widgets/add_work_widget.dart';

class AddWorkUserScreen extends StatelessWidget {
  const AddWorkUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            "Active Tasks",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: AddWorkWidget(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FloatingActionWidget()),
          );
        },
      ),
    );
  }
}
