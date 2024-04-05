import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    required this.text,
    required this.size,
    required this.textColor,
    required this.fontWeight,
    this.align = TextAlign.start,
    // this.noOfLines,


    Key? key,
  }) : super(key: key);

  final String text;
  final double size;
  final Color textColor;
  final FontWeight fontWeight;
  final TextAlign align;
  // final int? noOfLines;


  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
          color: textColor,
          fontSize: size,
          fontWeight: fontWeight,
          letterSpacing: 0.2,
          fontFamily: GoogleFonts.poppins().fontFamily),
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.ellipsis,
        // maxLines: noOfLines,
        textScaler: const TextScaler.linear(1.0),
      ),
    );
  }
}
