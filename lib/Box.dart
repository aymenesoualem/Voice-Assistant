import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  const Box({super.key,required this.couleur, required this.header});
  final Color couleur;
  final String header;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(header),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(200),
      color: couleur),
      
    );
  }
}