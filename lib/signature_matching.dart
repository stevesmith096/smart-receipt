import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SignatureComparePage extends StatefulWidget {
  final Uint8List data;

  // ✅ Constructor
  const SignatureComparePage({super.key, required this.data});

  @override
  _SignatureComparePageState createState() => _SignatureComparePageState();
}

class _SignatureComparePageState extends State<SignatureComparePage> {
  File? image1;
  File? image2;
  String result = "";
  double? similarityScore;

  final picker = ImagePicker();

  Future pickImage(bool isFirst) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isFirst) {
          image1 = File(pickedFile.path);
        } else {
          image2 = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> compareSignatures() async {
    if (image1 == null || image2 == null) return;

    var uri = Uri.parse("http://192.168.100.47:5000/compare");

    // var request =
    //     http.MultipartRequest('POST', uri)
    //       ..files.add(
    //         await http.MultipartFile.fromPath('signature1', image1!.path),
    //       )
    //       ..files.add(
    //         await http.MultipartFile.fromPath('signature2', image2!.path),
    //       );

    final byteData = await rootBundle.load(
      'assets/signature1.png',
    ); // adjust path as needed
    final Uint8List image1Bytes = byteData.buffer.asUint8List();

    var request =
        http.MultipartRequest('POST', uri)
          ..files.add(
            http.MultipartFile.fromBytes(
              'signature1',
              image1Bytes,
              filename: 'signature1.png',
              contentType: http_parser.MediaType('image', 'png'),
            ),
          )
          ..files.add(
            http.MultipartFile.fromBytes(
              'signature2',
              widget.data,
              filename: 'signature2.png',
              contentType: http_parser.MediaType('image', 'png'),
            ),
          );
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);
      setState(() {
        similarityScore = json['similarity_score'];
        result = json['result'];
      });
    } else {
      setState(() {
        result = "Error comparing signatures.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signature Compare")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset("assets/images/sign.jpg", height: 200),
            SizedBox(height: 10),

            Image.memory(widget.data, height: 300),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: compareSignatures,
              child: Text("Compare Signatures"),
            ),
            SizedBox(height: 20),
            if (similarityScore != null)
              Text("Similarity Score: ${similarityScore!.toStringAsFixed(2)}"),
            if (result.isNotEmpty)
              Text("Result: $result", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
