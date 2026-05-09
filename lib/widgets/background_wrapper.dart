import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  const BackgroundWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/bg.jpeg",
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(color: const Color(0xFF0D1B2A)),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.75)),
        child,
      ],
    );
  }
}
