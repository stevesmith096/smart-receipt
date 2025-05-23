import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:agora/signature_matching.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class UserSignatureScreen extends StatefulWidget {
  const UserSignatureScreen({super.key});

  @override
  State<UserSignatureScreen> createState() => _UserSignatureScreenState();
}

class _UserSignatureScreenState extends State<UserSignatureScreen> {
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

    await push(context, SignatureComparePage(data: data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
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
