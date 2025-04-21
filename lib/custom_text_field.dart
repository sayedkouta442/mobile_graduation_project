import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon = null,
    required this.prefixIcon,
    this.obscureText = false,
    required this.validator,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      validator: widget.validator,
      controller: widget.controller, // controller
      style: TextStyle(fontSize: 16),
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),

        fillColor:
            isDarkMode
                ? Colors.white.withOpacity(.03)
                : Colors.black.withOpacity(.03),
        filled: true,
        prefixIcon: Icon(widget.prefixIcon, color: Colors.blue),

        hintText: widget.hintText,
        suffixIcon:
            widget.hintText.toLowerCase().contains("password")
                ? GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.obscureText = !widget.obscureText;
                    });
                  },
                  child: Icon(
                    widget.obscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                )
                : null, // suffix icon
        contentPadding: EdgeInsets.all(20),
        hintStyle: TextStyle(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(.3)
                  : Colors.black.withOpacity(.3),
        ),
      ),
    );
  }
}
