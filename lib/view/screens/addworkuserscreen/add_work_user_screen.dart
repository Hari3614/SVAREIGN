import 'package:flutter/material.dart';
import 'package:svareign/view/screens/addworkuserscreen/floatingaction/floating_action_widget.dart';
import 'package:svareign/view/screens/addworkuserscreen/widgets/add_work_widget.dart';

class AddWorkUserScreen extends StatelessWidget {
  const AddWorkUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Active Tasks",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      body: AddWorkWidget(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        splashColor: Colors.blue,
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
