import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_sample/employee.dart';
import 'photo.dart';

class UpdateData extends StatefulWidget {
  const UpdateData({super.key, required this.employee});

  final Employee employee;

  @override
  State<UpdateData> createState() => _UpdateDataState();
}

class _UpdateDataState extends State<UpdateData> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  late String errormessage;
  late bool isError;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String urlfile = "";
  String image = "";
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  @override
  void initState() {
    errormessage = "This is an error";
    isError = false;
    nameController.text = widget.employee.name;
    emailController.text = widget.employee.email;
    image = widget.employee.image;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget imgExist() => Image.file(
        File(pickedFile!.path!),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );

  Widget imgNotExist() => Image.network(
        image,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );
  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        "AaBaCaDaEaFaGaHaIaJaKaLaMaNaOaPaQaRaSaTaUaVaWaXaYaZaA1B1C1D1E1F1G1H1I1J1K1L1M1N1O1P1Q1R1S1T1U1V1W1X1Y1Z1";
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text("Updating ..."),
          )
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future uploadFile(context) async {
    showLoaderDialog(context);

    final path = 'images/${'${generateRandomString(5)}-${pickedFile!.name}'}';
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });
    final snapshot = await uploadTask!.whenComplete(() => {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    updateDatabase(urlDownload, context, widget.employee.id);
    updateUser(widget.employee.id);
    // setState(() {
    //   urlfile = urlDownload;
    //   uploadTask = null;
    // });
  }

  showAlertDialogUpload(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop();
        if (pickedFile != null) {
          uploadFile(context);
        }
        (pickedFile != null)
            ? uploadFile(context)
            : updateUser(widget.employee.id);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('Question'),
      content: Text("Are you sure you want to Update this user?"),
      actions: [cancelButton, continueButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  showAlert(BuildContext context, String title, String msg) {
    Widget continueButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        if (title == "Success") {
          if (urlfile == '') urlfile = "-";
          Navigator.of(context).pop(Photo(image: urlfile));
        }
      },
      child: Text("OK"),
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [continueButton],
    );

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future updateDatabase(urlDownload, context, id) async {
    final docUser = FirebaseFirestore.instance.collection('Employee').doc(id);

    await docUser.update({
      'image': urlDownload,
    }).then((value) => showAlert(context, 'Success', 'Image Update Success!'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go back'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'UPDATE DATA',
                  style: txtstyle,
                ),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.grey)),
                  child: Center(
                    child: (pickedFile != null) ? imgExist() : imgNotExist(),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    selectFile();
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: Text('Select Photo'),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Email Address',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    showAlertDialogUpload(context);
                  },
                  child: const Text('UPDATE'),
                ),
                const SizedBox(height: 15),
                (isError)
                    ? Text(
                        errormessage,
                        style: errortxtstyle,
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  var errortxtstyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.red,
    letterSpacing: 1,
    fontSize: 18,
  );
  var txtstyle = const TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    fontSize: 38,
  );
  Future updateUser(String id) async {
    final docUser = FirebaseFirestore.instance.collection('Employee').doc(id);
    docUser.update({
      'email': emailController.text,
      'name': nameController.text,
    });
    Navigator.pop(context);
  }
}
