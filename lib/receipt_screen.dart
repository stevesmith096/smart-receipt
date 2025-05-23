import 'dart:math';

import 'package:agora/button_component.dart';
import 'package:agora/receipt_model.dart';
import 'package:agora/signature_screen.dart';
import 'package:agora/utils/color_constant.dart';
import 'package:flutter/material.dart';

class ReceiptScreen extends StatefulWidget {
  Receipt? receiptDetails;
  final List<String> validationIssues;

  ReceiptScreen({
    super.key,
    this.receiptDetails,
    required this.validationIssues,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  Widget buildTextField(String label, dynamic value) {
    if (value == null) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: TextEditingController(text: value.toString()),
        readOnly: true,

        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorConstant.primaryColor),
          ),

          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  String? selectedValue;
  List<String> items = [
    'Other',
    'Utilities',
    'Office Supplies',
    'Travel',
    'Meals & Entertainment',
    'Maintenance',
    'Rent',
    'Wages & Salaries',
    'General Expenses',
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedValue = "Other";
      widget.receiptDetails = widget.receiptDetails?.copyWith(
        category: "Other",
      );
      setState(() {});
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
          'Receipt Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (widget.receiptDetails?.companyName?.isNotEmpty ?? false)
                  ? buildTextField(
                    "Company Name",
                    widget.receiptDetails?.companyName,
                  )
                  : SizedBox(),
              (widget.receiptDetails?.date != null)
                  ? buildTextField("Date", widget.receiptDetails?.date)
                  : SizedBox(),
              (widget.receiptDetails?.subtotal != null)
                  ? buildTextField("Subtotal", widget.receiptDetails?.subtotal)
                  : SizedBox(),
              (widget.receiptDetails?.tax != null)
                  ? buildTextField("Tax", widget.receiptDetails?.tax)
                  : SizedBox(),
              (widget.receiptDetails?.totalPrice != null)
                  ? buildTextField(
                    "Total Price",
                    widget.receiptDetails?.totalPrice,
                  )
                  : SizedBox(),
              (widget.receiptDetails?.totalQuantity != null &&
                      widget.receiptDetails?.totalQuantity != 0)
                  ? buildTextField(
                    "Total Quantity",
                    widget.receiptDetails?.totalQuantity,
                  )
                  : SizedBox(),
              (widget.receiptDetails?.serviceCharge != null)
                  ? buildTextField(
                    "Service Charges",
                    widget.receiptDetails?.serviceCharge,
                  )
                  : SizedBox(),
              (widget.receiptDetails?.totalQuantity != null)
                  ? buildTextField(
                    "Total Quantity",
                    widget.receiptDetails?.totalQuantity,
                  )
                  : SizedBox(),

              const SizedBox(height: 10),
              const Text(
                "Items",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.receiptDetails?.items?.length,
                itemBuilder: (context, index) {
                  final item = widget.receiptDetails?.items![index];
                  return ListTile(
                    title: Text(item?.item ?? ""),
                    subtitle: Text(
                      "${item?.quantity != 0 ? "Qty: ${item?.quantity}," : ""} Price: ${item?.unitPrice}, Amount: ${item?.itemAmount}",
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButton<String>(
                  value: selectedValue,

                  icon: Icon(Icons.arrow_drop_down),
                  elevation: 16,
                  style: TextStyle(
                    color: ColorConstant.primaryColor,
                    fontSize: 16,
                  ),
                  underline: Container(
                    height: 2,
                    color: ColorConstant.primaryColor,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                    widget.receiptDetails = widget.receiptDetails?.copyWith(
                      category: selectedValue,
                    );
                  },
                  items:
                      items.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(height: 10),

              ValidationIssuesWidget(validationIssues: widget.validationIssues),
              SizedBox(height: 30),

              ButtonComponent(
                text: "Submit Receipt",
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UserSignatureScreen(
                            receiptDetails: widget.receiptDetails ?? Receipt(),
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ValidationIssuesWidget extends StatelessWidget {
  final List<String> validationIssues;

  const ValidationIssuesWidget({Key? key, required this.validationIssues})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (validationIssues.isEmpty) {
      return const SizedBox(); // or Text('No issues found')
    }

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: validationIssues.length,
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.black)),
                    Expanded(
                      child: Text(
                        validationIssues[index],
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
