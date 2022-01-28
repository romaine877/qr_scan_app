import 'package:flutter/material.dart';

class QrModal extends StatelessWidget {
  final String qrData;

  const QrModal({Key? key, required this.qrData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffeef2ff),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Card(child: Text(qrData),),
    );
  }
}
