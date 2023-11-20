import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'photo.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UpdatePhoto extends StatefulWidget {
  const UpdatePhoto({super.key});

  @override
  State<UpdatePhoto> createState() => _UpdatePhotoState();
}

class _UpdatePhotoState extends State<UpdatePhoto> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String urlFile = "";

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile(context) async {
    showLoaderDialog(context);

    final path = 'images/${generateRandomString(5)}-${pickedFile!.name}';
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);

    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() => {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    updateDatabase(urlDownload, context);

    // setState(() {
    //   urlFile = urlDownload;
    //   uploadTask = null;
    // });
  }

  Future updateDatabase(urlDownload, context) async {
    final docUser = FirebaseFirestore.instance
        .collection('Employee')
        .doc('AVtShPPuaYa40BfUnENQBJymlhI3');

    await docUser.update({
      'image': urlDownload,
    }).then((value) {
      showAlert(context, 'Success', 'Image Update Success');
    });

    setState(() {
      pickedFile = null;
    });
  }

  Widget imgExist() => Image.file(
        File(pickedFile!.path!),
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
      );

  Widget imgNotExist() => Image.asset(
        'images/no-image.png',
        fit: BoxFit.cover,
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String generateRandomString(int len) {
    var r = Random();
    const _char =
        'AaBbCcDdEeFfGgHhIiJjKkLlMnNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _char[r.nextInt(_char.length)]).join();
  }

  showAlertDialogUpload(BuildContext context) {
    Widget cancelButton = TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text('Cancel'),
    );
    Widget continueButton = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        uploadFile(context);
      },
      child: const Text('Continue'),
    );

    AlertDialog alert = AlertDialog(
        title: const Text('Question'),
        content: const Text('Are you sure want to upload this image?'),
        actions: [
          cancelButton,
          continueButton,
        ]);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlert(BuildContext context, String title, String msg) {
    Widget continueButton = TextButton(
      onPressed: () {
        Navigator.pop(context);
        if (title == "Success") if (urlFile == '') urlFile = "-";
        Navigator.of(context).pop(Photo(image: urlFile));
      },
      child: const Text('Ok'),
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        continueButton,
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text("Uploading ..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget progressBar(progress) => SizedBox(
        height: 50,
        child: Stack(
          fit: StackFit.expand,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey,
              color: Colors.green,
            ),
            Center(
              child: Text(
                '${(100 * progress).roundToDouble()}%',
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return progressBar(progress);
          } else {
            return const SizedBox(
              height: 50,
            );
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photo'),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey),
            ),
            child: Center(
                child: (pickedFile != null) ? imgExist() : imgNotExist()),
          ),
          ElevatedButton.icon(
            onPressed: () {
              selectFile();
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Select Photo'),
          ),
          const SizedBox(
            height: 32,
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (pickedFile != null) {
                showAlertDialogUpload(context);
              } else {
                showAlert(context, 'Error', 'Please select a Photo');
              }
            },
            icon: const Icon(Icons.upload),
            label: const Text('Upload Image'),
          ),
          const SizedBox(
            height: 10,
          ),
          buildProgress(),
        ],
      ),
    );
  }
}
