import 'package:agora/button_component.dart';
import 'package:agora/receipt_model.dart';
import 'package:agora/signature_screen.dart';
import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  final Receipt receiptDetails;

  const ReceiptScreen({super.key, required this.receiptDetails});

  Widget buildTextField(String label, dynamic value) {
    if (value == null) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: TextEditingController(text: value.toString()),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Receipt Details")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField("Company Name", receiptDetails.companyName),
              buildTextField("Date", receiptDetails.date),
              buildTextField("Subtotal", receiptDetails.subtotal),
              buildTextField("Tax", receiptDetails.tax),
              buildTextField("Total Price", receiptDetails.totalPrice),
              buildTextField("Total Quantity", receiptDetails.totalQuantity),
              const SizedBox(height: 10),
              const Text(
                "Items",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: receiptDetails.items?.length,
                itemBuilder: (context, index) {
                  final item = receiptDetails.items![index];
                  return ListTile(
                    title: Text(item.item ?? ""),
                    subtitle: Text(
                      "Qty: ${item.quantity}, Price: ${item.unitPrice}, Amount: ${item.itemAmount}",
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ButtonComponent(
                  text: "Submit Receipt",
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserSignatureScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
