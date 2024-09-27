import 'package:flutter/material.dart';

class DottedLine extends StatelessWidget {
  const DottedLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 2,
          ),
          Container(
            height: 4,
            width: 2,
            color: Colors.white,
          ),
          const SizedBox(
            height: 3,
          ),
          Container(
            height: 4,
            width: 2,
            color: Colors.white,
          ),
          Container(
            height: 4,
            width: 2,
            color: Colors.white,
          ),
          const SizedBox(
            height: 3,
          ),
          Container(
            height: 4,
            width: 2,
            color: Colors.white,
          )
        ],
      ),
    );
  }
}
