import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Inputfield extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  bool useMargin;
  bool isObscuredText;
  final String? obscureCharacter;
  final InputDecoration? decoration;
  final bool useOutlineBorder; // Changed to bool for condition check
  final Widget? prefixIcon;
  final String hintText;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffixIcon;
  Widget? icon;
  final String? Function(String?)? validator;

  Inputfield({
    super.key,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.useMargin = true,
    this.isObscuredText = true,
    this.decoration,
    this.useOutlineBorder = true,
    this.prefixIcon,
    required this.hintText,
    this.contentPadding,
    this.suffixIcon,
    this.icon,
    this.obscureCharacter,
    this.validator,
  });

  @override
  State<Inputfield> createState() => _InputfieldState();
}

class _InputfieldState extends State<Inputfield> {
  void toggle() {
    setState(() {
      widget.isObscuredText = !widget.isObscuredText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.useMargin == true
          ? EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.015,
              bottom: MediaQuery.of(context).size.height * 0.015,
            )
          : null,
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: !widget.isObscuredText,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFFFFFFFF),
          hintText: widget.hintText, // Default hintText
          prefixIcon: widget.prefixIcon, // Default prefixIcon
          contentPadding: widget.contentPadding,
          enabledBorder: widget.useOutlineBorder == true
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)), // Rounded border
                  borderSide: BorderSide(width: 2.0, color: Color(0xFF435334)),
                )
              : UnderlineInputBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)), // Rounded top border
                  borderSide: BorderSide(color: Color(0xFF435334)),
                ),
          focusedBorder: widget.useOutlineBorder == true
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)), // Rounded border
                  borderSide: BorderSide(width: 2.0, color: Color(0xFF435334)),
                )
              : UnderlineInputBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)), // Rounded top border
                  borderSide: BorderSide(color: Color(0xFF435334)),
                ),
          hintStyle:
                TextStyle(
                  fontFamily: "Livvic",
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFA6B37D),
                  fontSize: MediaQuery.of(context).size.height * 0.02,
                ),
          errorStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.015,
          ),
        ),
        cursorColor: Colors.black,
        // validator: widget.validator,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        // onChanged: (text){
        //   print("text:  $text");
        // },
      ),
      
    );
  }
}