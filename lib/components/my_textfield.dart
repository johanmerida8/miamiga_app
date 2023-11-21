import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String text;
  final bool obscureText;
  final bool isEnabled;
  final bool isVisible;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.text,
    required this.obscureText,
    required this.isEnabled,
    required this.isVisible,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool isFocused;
  late bool isPasswordVisible;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isFocused = false;
    isPasswordVisible = false;
  }

  void setFocused(bool focused) {
    if (isFocused != focused) {
      setState(() {
        isFocused = focused;
      });
    }
  }

  void setPasswordVisibility(bool visible) {
    if (isPasswordVisible != visible) {
      setState(() {
        isPasswordVisible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  color: isFocused ? Colors.black : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: widget.controller,
                    obscureText: widget.obscureText && !isPasswordVisible,
                    onChanged: widget.onChanged,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      hintText: widget.hintText,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                    enabled: widget.isEnabled,
                    onTap: () {
                      setFocused(true);
                    },
                    onSubmitted: (value) {
                      setFocused(false);
                    },
                    onEditingComplete: () {
                      setFocused(false);
                    },
                  ),
                  if (widget.obscureText)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setPasswordVisibility(!isPasswordVisible);
                        },
                        child: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
