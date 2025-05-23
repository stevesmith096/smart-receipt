import 'dart:convert';
import 'package:agora/button_component.dart';
import 'package:agora/receipt_model.dart';
import 'package:agora/receipt_screen.dart';
import 'package:agora/utils/color_constant.dart';
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
  List<String> validationIssues = [];

  Future<void> pickImage(bool isGallery) async {
    final pickedFile = await picker.pickImage(
      source: isGallery ? ImageSource.gallery : ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        validationIssues =
            []; // Reset validation issues when new image is selected
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

  // Enhanced validation methods
  List<String> _validateBasicStructure(Receipt receipt) {
    final errors = <String>[];

    if (receipt.companyName?.isEmpty ?? true)
      errors.add("Missing company name");
    if (receipt.items?.isEmpty ?? true) errors.add("No items listed");
    if (receipt.totalPrice == null || receipt.totalPrice == 0)
      errors.add("Missing total price");
    if (receipt.date?.isEmpty ?? true) errors.add("Missing date");

    final datePattern = RegExp(r'^\d{2}[./-]\d{2}[./-]\d{4}$');
    if (receipt.date == null || !datePattern.hasMatch(receipt.date!)) {
      errors.add("Invalid date format (expected dd.mm.yyyy)");
    }

    return errors;
  }

  void _validateMathCalculations(
    Receipt receipt,
    List<String> errors,
    List<String> warnings,
  ) {
    final items = receipt.items ?? [];

    double calculatedTotal = 0;
    for (var item in items) {
      final amount =
          item.itemAmount ?? (item.unitPrice ?? 0) * (item.quantity ?? 1);
      calculatedTotal += amount;
    }

    final subtotal = receipt.subtotal ?? calculatedTotal;
    final tax = receipt.tax ?? 0;
    final serviceCharge = receipt.serviceCharge ?? 0;
    final expectedTotal = subtotal + tax + serviceCharge;
    final declaredTotal = receipt.totalPrice ?? 0;
    final totalDifference = (expectedTotal - declaredTotal).abs();

    // Detect mismatch only if significant (> 1.0 to allow for rounding or unknown service charges)
    if (totalDifference > 1.0) {
      errors.add(
        "Total price mismatch (subtotal + tax + service charge = ${expectedTotal.toStringAsFixed(2)}, declared: ${declaredTotal.toStringAsFixed(2)})",
      );
    } else if (receipt.serviceCharge == null && totalDifference > 0.5) {
      warnings.add(
        "Possible missing service charge of approx ${totalDifference.toStringAsFixed(2)}",
      );
    }

    if ((receipt.tax ?? 0) == 0) {
      warnings.add("Tax amount is missing or zero");
    }

    if (items.isEmpty) {
      warnings.add("No items found in receipt");
    }

    // Round total suspicious detection
    if (declaredTotal % 10 == 0) {
      warnings.add(
        "Suspicious round total amount (common in fabricated receipts)",
      );
    }
  }

  List<String> _detectPotentialFraud(Receipt receipt) {
    final redFlags = <String>[];

    if ((receipt.totalPrice ?? 0) % 1 == 0) {
      redFlags.add(
        "Suspicious round total amount (common in fabricated receipts)",
      );
    }

    final itemNames =
        receipt.items
            ?.map((i) => i.item?.toLowerCase())
            .whereType<String>()
            .toList() ??
        [];
    final uniqueItems = Set.from(itemNames);

    if (uniqueItems.length != itemNames.length) {
      redFlags.add("Duplicate items detected");
    }

    for (var item in receipt.items ?? []) {
      if (item.unitPrice != null && item.unitPrice! <= 0) {
        redFlags.add("Invalid price for ${item.item}");
      }
      if (item.quantity != null && item.quantity! <= 0) {
        redFlags.add("Invalid quantity for ${item.item}");
      }
    }

    try {
      final dateParts = receipt.date?.split(RegExp(r'[./-]'));
      final parsedDate = DateTime(
        int.parse(dateParts![2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
      );

      final now = DateTime.now();
      if (parsedDate.isAfter(now)) {
        redFlags.add("Future date detected");
      }

      final difference = now.difference(parsedDate).inDays;
      if (difference > 20) {
        redFlags.add("Receipt date is older than 20 days");
      }
    } catch (e) {
      redFlags.add("Invalid date format");
    }

    return redFlags;
  }

  String get enhancedPrompt => """
You are an advanced receipt analysis assistant. Analyze this receipt and extract the following information:

**Required Fields:**
- company_name (string)
- items (array of objects with: item, quantity, unit_price, item_amount)
- total_price (number)
- date (string in dd.mm.yyyy format)

**Validation Checks:**
1. Mathematical consistency:
   - Ensure total_price = sum(item_amounts) + tax + service_charge
   - Flag any discrepancies > 1% of total
2. Fraud detection:
   - Check for duplicate items
   - Verify date is not in future
   - Detect suspicious round numbers
3. Completeness:
   - Ensure all required fields are present
   - Validate item details

**Output Format:**
{
  "company_name": "string",
  "items": [
    {
      "item": "string",
      "quantity": number,
      "unit_price": number,
      "item_amount": number
    }
  ],
  "subtotal": number,
  "tax": number,
  "service_charge": number,
  "total_price": number,
  "date": "dd.mm.yyyy",
  "validation": {
    "warnings": ["string"],
    "potential_issues": ["string"],
    "security_features": ["string"]
  }
}

**Special Instructions:**
- Be precise with numerical values
- Flag even minor inconsistencies
- Note any signs of tampering
- Detect security features if present
""";

  Future<void> imageToText(File image) async {
    try {
      updateLoadingReceipt();

      final response = await Gemini.instance.prompt(
        parts: [
          Part.uint8List(image.readAsBytesSync()),
          Part.text(enhancedPrompt),
        ],
      );

      updateLoadingReceipt();

      final rawOutput = response?.output?.trim();
      if (rawOutput == null || rawOutput.isEmpty) {
        throw FormatException('Empty response from Gemini.');
      }

      final cleanedJson = _extractJsonString(rawOutput);
      final jsonMap = jsonDecode(cleanedJson);
      receiptData = Receipt.fromJson(jsonMap);

      if (receiptData != null) {
        // Perform all validations
        final basicErrors = _validateBasicStructure(receiptData!);
        final mathErrors = <String>[];
        final fraudIndicators = _detectPotentialFraud(receiptData!);

        // Combine all validation results
        validationIssues = [
          ...basicErrors,
          ...?mathErrors,
          ...fraudIndicators,
          ...?receiptData?.validation?.warnings,
          ...?receiptData?.validation?.potentialIssues,
        ];

        // Log to console
        debugPrint('=== Receipt Validation Report ===');
        debugPrint('Company: ${receiptData!.companyName}');
        debugPrint('Date: ${receiptData!.date}');
        debugPrint('Total: ${receiptData!.totalPrice}');

        if (validationIssues.isNotEmpty) {
          debugPrint('\n⚠️ Validation Issues:');
          validationIssues.forEach((issue) => debugPrint('- $issue'));
        } else {
          debugPrint('\n✅ Receipt is valid');
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReceiptScreen(
                  receiptDetails: receiptData!,
                  validationIssues: validationIssues,
                ),
          ),
        );
      }
    } catch (e) {
      updateLoadingReceipt();
      debugPrint('Error processing receipt: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing receipt: ${e.toString()}')),
      );
    }
  }

  String _extractJsonString(String raw) {
    if (raw.contains('```')) {
      final regex = RegExp(r'```(?:json)?([\s\S]*?)```');
      final match = regex.firstMatch(raw);
      if (match != null) {
        return match.group(1)?.trim() ?? '{}';
      }
    }

    final startIndex = raw.indexOf('{');
    final endIndex = raw.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return raw.substring(startIndex, endIndex + 1);
    }

    throw FormatException('Could not extract JSON from the response');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ColorConstant.primaryColor,
        centerTitle: true,
        title: const Text(
          'Smart Receipt',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
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
                backgroundColor: ColorConstant.primaryColor,

                onPressed: () {
                  print('Pick Image');
                  pickImage(true);
                },
                child: Icon(Icons.attach_file, color: Colors.white),
              ),
              FloatingActionButton(
                backgroundColor: ColorConstant.primaryColor,
                onPressed: () {
                  print('Take Picture');
                  pickImage(false);
                },
                child: Icon(Icons.camera, color: Colors.white),
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
