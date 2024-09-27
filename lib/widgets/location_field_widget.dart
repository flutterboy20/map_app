import 'package:flutter/material.dart';

class LocationFieldWidget extends StatelessWidget {
  final String location;
  const LocationFieldWidget({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.8,
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
        left: 20,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xff525458),
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Text(
        location,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
