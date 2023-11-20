import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'employee.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final user = FirebaseAuth.instance.currentUser!;

  getUserData(uid) {
    var collection = FirebaseFirestore.instance.collection('Employee');
    return StreamBuilder(
      stream: collection.doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error = ${snapshot.error}');
        }
        if (snapshot.hasData) {
          final data = snapshot.data!.data();
          final employee = Employee(
            id: data!['id'],
            name: data['name'],
            email: data['email'],
            image: data['image'],
          );
          return buildUserInfo(employee);
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  buildUserInfo(Employee employee) => Column(
        children: [
          const Text('from firestore:'),
          const SizedBox(height: 15),
          Text(employee.id, style: txtstyle),
          const SizedBox(height: 15),
          Text(employee.name, style: txtstyle),
        ],
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You succesfully connected to firebase'),
            const SizedBox(height: 15),
            const Text('Sign as: '),
            const SizedBox(height: 15),
            Text(
              user.email!,
              style: txtstyle,
            ),
            const SizedBox(height: 15),
            getUserData(user.uid),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Text('SIGN OUT'),
            ),
          ],
        ),
      ),
    );
  }

  var txtstyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
}
