import 'dart:convert';
import 'package:agora/button_component.dart';
import 'package:agora/receipt_model.dart';
import 'package:agora/receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key});

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  File? _image;
  bool isLoadingReceipt = false;
  Receipt? receiptData;
  final picker = ImagePicker();

  Future<void> pickImage(bool isGallery) async {
    final pickedFile = await picker.pickImage(
      source: isGallery ? ImageSource.gallery : ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  void updateLoadingReceipt() {
    setState(() {
      isLoadingReceipt = !isLoadingReceipt;
    });
  }

  Future<void> imageToText(File image) async {
    try {
      updateLoadingReceipt();
      Gemini.instance
          .prompt(
            parts: [
              Part.uint8List(image.readAsBytesSync()),
              Part.text("""
  Here is my receipt. I want to extract the following information and return it in JSON format:

Company name

A list of all items with:

Item name

Quantity (if available)

Unit price (if available)

Item amount (if available)

Total quantity

Total price

Tax (if available)

Subtotal (if available)

Date of the receipt

Please provide the output in the following JSON structure:
{
  "company_name": "string",
  "items": [
    {
      "item": "string",
      "quantity": "number (integer, optional)",
      "unit_price": "number (float, optional)",
      "item_amount": "number (float, optional)"
    }
  ],
  "total_quantity": "number (integer)",
  "total_price": "number (float)",
  "tax": "number (float, optional)",
  "subtotal": "number (float, optional)",
  "date": "string (format: dd.mm.yyyy or similar)"
}
    """),
            ],
          )
          .then((value) {
            updateLoadingReceipt();
            print(value?.output);

            final rawOutput = value?.output?.trim();
            if (rawOutput == null || rawOutput.isEmpty) {
              throw FormatException('Empty response from Gemini.');
            }

            // Remove markdown-style code block ```json ... ```
            final cleanedJson = _extractJsonString(rawOutput);

            // Decode JSON safely
            final Map<String, dynamic> jsonMap = jsonDecode(cleanedJson);

            receiptData = Receipt.fromJson(jsonMap);
            if (receiptData != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ReceiptScreen(
                        receiptDetails: receiptData ?? Receipt(),
                      ),
                ),
              );
            }
          })
          .catchError((e) {
            updateLoadingReceipt();

            print('error $e');
          });
    } catch (e) {
      updateLoadingReceipt();

      debugPrint(e.toString());
    }
  }

  String _extractJsonString(String raw) {
    // If wrapped in triple backticks
    if (raw.contains('```')) {
      final regex = RegExp(r'```(?:json)?([\s\S]*?)```');
      final match = regex.firstMatch(raw);
      if (match != null) {
        return match.group(1)?.trim() ?? '{}';
      }
    }

    // Fallback: try to find the first '{' and parse from there
    final startIndex = raw.indexOf('{');
    final endIndex = raw.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return raw.substring(startIndex, endIndex + 1);
    }

    // Couldn't find valid JSON
    throw FormatException('Could not extract JSON from the response');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(receiptData?.toJson().toString());
    return Scaffold(
      appBar: AppBar(title: Text('Receipt Hacker')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              height: 550,
              child: Center(
                child: SingleChildScrollView(
                  child:
                      _image == null
                          ? Text('Upload receipt')
                          : Image.file(_image!),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  print('Pick Image');
                  pickImage(true);
                },
                child: Icon(Icons.attach_file),
              ),
              FloatingActionButton(
                onPressed: () {
                  print('Take Picture');
                  pickImage(false);
                },
                child: Icon(Icons.camera),
              ),
            ],
          ),
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: ButtonComponent(
              isLoading: isLoadingReceipt,
              isDisabled: _image == null,
              text: "Proceed Receipt",
              onPressed: () async {
                await imageToText(_image!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
