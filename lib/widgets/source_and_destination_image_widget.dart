import 'package:flutter/material.dart';
import 'package:map_app/widgets/dotted_line.dart';

class SourceAndDestinationImageWidget extends StatelessWidget {
  const SourceAndDestinationImageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Source Icon Image
        Image.asset(
          "assets/icons/start_location.png",
          height: 28,
          width: 28,
        ),
        // Dotted Line widget
        const DottedLine(),
        // Destination Icon Image
        Image.asset(
          "assets/icons/end_location.png",
          height: 28,
          width: 28,
        ),
      ],
    );
  }
}
