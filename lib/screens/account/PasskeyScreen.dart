import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PasskeyScreen extends StatefulWidget {
  const PasskeyScreen({super.key});

  @override
  State<PasskeyScreen> createState() => _PasskeyScreenState();
}

class _PasskeyScreenState extends State<PasskeyScreen> {

  TextEditingController pinController = TextEditingController();
  String enteredPin = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter PIN")),
      body: Padding(
        padding: const EdgeInsets.all(80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your 4-digit PIN",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // PIN Code Field
            PinCodeTextField(
              appContext: context,
              length: 4,
              controller: pinController,
              obscureText: true,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.blue.shade50,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.blue.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  enteredPin = value;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (enteredPin.length == 4) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text("Entered PIN: $enteredPin")),
                  // );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter all 4 digits")),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}