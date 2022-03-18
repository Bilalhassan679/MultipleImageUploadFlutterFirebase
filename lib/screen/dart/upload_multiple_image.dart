import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadMultipleImage extends StatefulWidget {
  const UploadMultipleImage({Key? key}) : super(key: key);

  @override
  _UploadMultipleImageState createState() => _UploadMultipleImageState();
}

class _UploadMultipleImageState extends State<UploadMultipleImage> {
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _selectedFiles = [];
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  List<String> arrimgsUrl = [];
  int uploadItem = 0;
  bool _upLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _upLoading
            ? showLoading()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: OutlinedButton(
                        onPressed: () {
                          selectImage();
                        },
                        child: Text('Select Files')),
                  ),
                  Center(
                    child: ElevatedButton.icon(
                        onPressed: () {
                          if (_selectedFiles.isNotEmpty) {
                            uploadFunction(_selectedFiles);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("PLEASE Select Image")));
                          }
                        },
                        icon: Icon(Icons.upload_sharp),
                        label: Text('Upload')),
                  ),
                  Center(
                    child: _selectedFiles.length == null
                        ? Text("No Images Selected")
                        : Text(
                            'Image is Selected : ${_selectedFiles.length.toString()}'),
                  ),
                  SizedBox(height: 50),
                  Expanded(
                    child: GridView.builder(
                        itemCount: _selectedFiles.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Image.file(File(_selectedFiles[index].path),
                                fit: BoxFit.cover),
                          );
                        }),
                  )
                ],
              ),
      ),
    );
  }

  //showLoading Login()
  Widget showLoading() {
    return Center(
      child: Column(
        children: [
          Text(
            "Uploading : " +
                uploadItem.toString() +
                "/" +
                _selectedFiles.length.toString(),
          ),
          SizedBox(height: 30),
          CircularProgressIndicator()
        ],
      ),
    );
  }

  //upload ImageFile One by one
  void uploadFunction(List<XFile> _images) async {
    for (int i = 0; i < _images.length; i++) {
      var imageUrl = await uploadFile(_images[i]);
      arrimgsUrl.add(imageUrl.toString());
    }
    print("93 ${arrimgsUrl}");
  }
  //Finish upload ImageFile One by one

  //Upload Images in Firestore Storage
  Future<String> uploadFile(XFile _image) async {
    setState(() {
      _upLoading = true;
    });
    Reference reference =
        _firebaseStorage.ref().child("Multiple images").child(_image.name);
    await reference.putFile(File(_image.path)).whenComplete(() async {
      setState(() {
        uploadItem += 1;
        if (uploadItem == _selectedFiles.length) {
          _upLoading = false;
          uploadItem = 0;
        }
      });
    });
    // await reference.getDownloadURL();
    // print("111 ${await reference.getDownloadURL()}");
    var img_url = await reference.getDownloadURL();
    print('function print ${img_url}');
    return img_url;
    // return await reference.getDownloadURL();
  }
  //Finish Upload Images in Firestore Storage

//Select Image From Gallery
  Future<void> selectImage() async {
    if (_selectedFiles != null) {
      _selectedFiles.clear();
    }

    try {
      final List<XFile>? imgs = await _imagePicker.pickMultiImage(
          imageQuality: 50, maxWidth: 400, maxHeight: 400);
      if (imgs!.isNotEmpty) {
        _selectedFiles.addAll(imgs);
      }
      print("List of Images : " + imgs.length.toString());
    } catch (e) {
      print("Something Wrong" + e.toString());
    }
    setState(() {});
  }
//Finish Select Image From Gallery

}
