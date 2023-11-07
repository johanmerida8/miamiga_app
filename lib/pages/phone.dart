import 'package:flutter/material.dart';

class MyPhoneField extends StatefulWidget {
  final String verificationId;
  const MyPhoneField({
    super.key,
    required this.verificationId,
  });

  @override
  State<MyPhoneField> createState() => _MyPhoneFieldState();
}

class _MyPhoneFieldState extends State<MyPhoneField> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
      ),
      body: Column(
        children: [

        ],
      ),
    );
  }
}