import 'package:flutter/material.dart';

class TapAnimationButton extends StatefulWidget {
  final String? text;
  final Icon? icon;
  final VoidCallback onPressed;
  const TapAnimationButton({
    Key? key,
    this.text,
    this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  //  State<LoginContent> createState() => _LoginContentState();
  State<TapAnimationButton> createState() => _TapAnimationButtonState();
}

class _TapAnimationButtonState extends State<TapAnimationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed();
        _animationController.forward(from: 0.0);
      },
      child: ScaleTransition(
        scale: _animationController,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            widget.text!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
