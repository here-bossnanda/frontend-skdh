// import 'dart:html';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
// import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
// import 'dart:ui' as ui;
// import 'package:path/path.dart';
// import 'package:async/async.dart';

class Home extends StatefulWidget {
  Home() : super();

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  bool _loading = true;
  File _image;
  String _output;
  final picker = ImagePicker();

  // @override
  // void initState() {
  //   super.initState();
  //   // loadModel().then((value) {
  //   setState(() {});
  //   // });
  // }

  fetchResponse(File imageFile) async {
    final mimeTypeData =
        lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8]).split('/');

    final imageUploadRequest = http.MultipartRequest(
        'POST', Uri.parse('http://767465fd7fcb.ngrok.io/predict'));

    final file = await http.MultipartFile.fromPath('image', imageFile.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);


    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(' * Status code:  ${response.statusCode}');

      final Map<String, dynamic> responseData = json.decode(response.body);
      String outputFile = responseData['result'][0];

    setState(() {
      _output = outputFile;
      _loading = true;
    });

    } catch (e) {
      print(' * ERROR : ' + e.toString());
      return null;
    }
  }

  // classifyImage(File imageFile) async {
  // open a bytestream
  // ignore: deprecated_member_use
  // var stream =new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
  // get file length
  // var length = await imageFile.length();

  // string to uri
  // var uri = Uri.parse("http://192.168.100.6:5000/predict");

  // create multipart request
  // var request = new http.MultipartRequest("POST", uri);

  // multipart that takes file
  // var multipartFile = new http.MultipartFile('image', stream, length,
  //     filename: basename(imageFile.path));

  // add file to multipart
  // request.files.add(multipartFile);

  // send
  // var response = await request.send();
  // print(response.statusCode);
  // if (response.statusCode == 200) {
  //   print('oke');
  // }

  // listen for response
  // response.stream.transform(utf8.decoder).listen((value) {
  //   print(value);
  // });

  //   setState(() {
  //     // _output = output;
  //     _loading = false;
  //   });
  // }

  // loadModel() async {
  //   await Tflite.loadModel(
  //       model: 'assets/model_unquant.tfite', labels: 'assets/labels.txt');
  // }

  // @override
  // void dispose() {
  //   // Tflite.close();
  //   super.dispose();
  // }

  pickImage() async {
    var image = await picker.getImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      // _loading = false;
      fetchResponse(_image);
    });
  }

  pickGalleryImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      // _loading = false;
      fetchResponse(_image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101010),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 85),
            Text(
              'Klasifikasi Daun Herbal dengan KNN',
              style: TextStyle(color: Color(0xFFEEDA28), fontSize: 18),
            ),
            SizedBox(height: 6),
            Text(
              'Detect Daun Herbal',
              style: TextStyle(
                  color: Color(0xFFE99600),
                  fontWeight: FontWeight.w500,
                  fontSize: 28),
            ),
            SizedBox(height: 50),
            Center(
              child: _loading
                  ? Container(
                      child: Column(children: <Widget>[
                      Image.asset('assets/flower.png'),
                      SizedBox(height: 50),
                    ]))
                  : Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 250,
                            child: Image.file(_image),
                          ),
                          SizedBox(height: 20),
                          _output != null
                              ? Text(
                                  'Accuracy : ',
                                  // '${_output[0]['confidence']} \n'
                                  // 'name : '
                                  // '${_output[0]['label']}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )
                              : Container(),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 120,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                        decoration: BoxDecoration(
                            color: Color(0xFFE99600),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'Take a photo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: pickGalleryImage,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 120,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                        decoration: BoxDecoration(
                            color: Color(0xFFE99600),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'Camera Roll',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
