import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_sample/add_data.dart';
import 'package:flutter_firebase_sample/update_data.dart';

import 'employee.dart';

class Alldata extends StatefulWidget {
  const Alldata({super.key});

  @override
  State<Alldata> createState() => _AlldataState();
}

Future deleteUser(String id) async {
  final docUser = FirebaseFirestore.instance.collection('Employee').doc(id);
  docUser.delete();
}

class _AlldataState extends State<Alldata> {
  Stream<List<Employee>> readUsers() {
    return FirebaseFirestore.instance.collection('Employee').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Employee.fromJSon(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Widget buildList(Employee employee) => ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(employee.image),
          radius: 25,
        ),
        title: Text(employee.name),
        subtitle: Text(employee.email),
        dense: true,
        onTap: () {},
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UpdateData(employee: employee),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: () {
                deleteUser(employee.id);
              },
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Firebase Data'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddData(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle),
          ),
        ],
      ),
      body: StreamBuilder<List<Employee>>(
        stream: readUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          } else if (snapshot.hasData) {
            final employee = snapshot.data!;
            return ListView(children: employee.map(buildList).toList());
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
