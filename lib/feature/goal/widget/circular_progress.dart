import 'package:flutter/material.dart';
import 'package:monsey/common/constant/colors.dart';

class CircularProgress extends StatefulWidget {
  const CircularProgress(
      {Key? key,
      required this.moneySaving,
      required this.moneyGoal,
      this.size = 48})
      : super(key: key);
  final double moneySaving;
  final double moneyGoal;
  final double size;
  @override
  State<CircularProgress> createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress>
    with TickerProviderStateMixin {
  late AnimationController controller;
  double moneySaving = 0;
  double moneyGoal = 0;
  @override
  void initState() {
    moneySaving = widget.moneySaving;
    moneyGoal = widget.moneyGoal;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        value: moneySaving / moneyGoal,
        backgroundColor: white.withOpacity(0.3),
        valueColor: const AlwaysStoppedAnimation(white),
      ),
    );
  }
}
