import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:agora/receipt_model.dart';
import 'package:agora/utils/color_constant.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

class UserSignatureScreen extends StatefulWidget {
  final Receipt receiptDetails;

  const UserSignatureScreen({super.key, required this.receiptDetails});

  @override
  State<UserSignatureScreen> createState() => _UserSignatureScreenState();
}

class _UserSignatureScreenState extends State<UserSignatureScreen> {
  String result = "";

  SignatureController controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    controller.addListener(() => log('Value changed'));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double? similarityScore;

  final picker = ImagePicker();

  Future<void> compareSignatures(Uint8List data) async {
    var uri = Uri.parse("http://192.168.43.47:5000/compare");

    final byteData = await rootBundle.load('assets/images/sign.jpg');
    final Uint8List image1Bytes = byteData.buffer.asUint8List();

    var request =
        http.MultipartRequest('POST', uri)
          ..files.add(
            http.MultipartFile.fromBytes(
              'signature1',
              image1Bytes,
              filename: 'signature1.png',
              contentType: http_parser.MediaType('image', 'jpg'),
            ),
          )
          ..files.add(
            http.MultipartFile.fromBytes(
              'signature2',
              data,
              filename: 'signature2.png',
              contentType: http_parser.MediaType('image', 'png'),
            ),
          );
    debugPrint(request.fields.toString());
    debugPrint(request.files[0].toString());

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);
      setState(() {
        similarityScore = json['similarity_score'];
        result = json['result'];
        log(result);
        if (result == 'similar') {
          sendReceiptApi();
        }
      });
    } else {
      setState(() {
        result = "Error comparing signatures.";
      });
    }
  }

  Future<void> sendReceiptApi() async {
    var uri = Uri.parse("http://192.168.43.216:4444/api/v1/receipt");
    try {
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},

        body: jsonEncode(widget.receiptDetails.toJson()),
      );

      if (response.statusCode == 201) {
        var json = jsonDecode(response.body);
        log(json.toString());
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> exportImage(BuildContext context) async {
    if (controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(key: Key('snackbarPNG'), content: Text('No content')),
      );
      return;
    }

    // Export with padding
    final image = await controller.toImage();

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const padding = 10.0;

    final paint = Paint()..color = Colors.white;
    final size = Size(image!.width + padding * 2, image.height + padding * 2);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    canvas.drawImage(image, Offset(padding, padding), Paint());

    final paddedImage = await recorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    final byteData = await paddedImage.toByteData(format: ImageByteFormat.png);
    final Uint8List? data = byteData?.buffer.asUint8List();

    if (data == null || !mounted) return;
    compareSignatures(data);

    // await push(context, SignatureComparePage(data: data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.primaryColor,
        centerTitle: true,
        title: const Text(
          'Digital Signature',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Signature(
        key: const Key('signature'),
        controller: controller,
        height: 300,
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: const BoxDecoration(color: Colors.teal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //SHOW EXPORTED IMAGE IN NEW ROUTE
              IconButton(
                key: const Key('exportPNG'),
                icon: const Icon(Icons.image),
                color: Colors.black,
                onPressed: () => exportImage(context),
                tooltip: 'Export Image',
              ),

              IconButton(
                icon: const Icon(Icons.undo),
                color: Colors.black,
                onPressed: () {
                  setState(() => controller.undo());
                },
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                color: Colors.black,
                onPressed: () {
                  setState(() => controller.redo());
                },
                tooltip: 'Redo',
              ),
              //CLEAR CANVAS
              IconButton(
                key: const Key('clear'),
                icon: const Icon(Icons.clear),
                color: Colors.black,
                onPressed: () {
                  setState(() => controller.clear());
                },
                tooltip: 'Clear',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future push(context, widget) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
      ),
    );
  }
}
