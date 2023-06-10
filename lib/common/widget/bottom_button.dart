import 'package:flutter/material.dart';

import '../constant/colors.dart';

class BottomButton extends StatelessWidget {
  const BottomButton({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -0.5),
            color: Color.fromRGBO(0, 0, 0, 0.08),
          ),
          BoxShadow(
            blurRadius: 15,
            offset: Offset(0, -2),
            color: Color.fromRGBO(120, 121, 121, 0.06),
          )
        ],
        color: white,
      ),
      child: child,
    );
  }
}
