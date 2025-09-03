// import 'package:flutter/material.dart';

// class WelcomeButton extends StatelessWidget {
//   const WelcomeButton({
//     super.key,
//     this.buttonText,
//     this.onTap,
//     this.color,
//     this.textColor,
//     this.bRadius,
//     this.borderColor
//   });
//   final String? buttonText;
//   final Widget? onTap;
//   final Color? color;
//   final Color? textColor;
//   final BorderRadius? bRadius;
//   final Color? borderColor;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(context, MaterialPageRoute(builder: (e) => onTap!));
//       },
//       child: Container(
//         padding: const EdgeInsets.all(15.0),
//         decoration: BoxDecoration(
//           color: color!,
//           borderRadius: bRadius!,
//           border: Border.all(color: borderColor!, width: 1),
//         ),
//         child: Text(
//           buttonText!,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 20.0,
//             fontWeight: FontWeight.bold,
//             color: textColor!,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class WelcomeButton extends StatefulWidget {
  const WelcomeButton({
    super.key,
    this.buttonText,
    this.onTap,
    this.color,
    this.textColor,
    this.bRadius,
    this.borderColor,
  });

  final String? buttonText;
  final Widget? onTap;
  final Color? color;
  final Color? textColor;
  final BorderRadius? bRadius;
  final Color? borderColor;

  @override
  State<WelcomeButton> createState() => _WelcomeButtonState();
}

class _WelcomeButtonState extends State<WelcomeButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  double get _scale {
    if (_isPressed) return 0.95; // Slight shrink on press
    if (_isHovered) return 1.05; // Grow on hover
    return 1.0; // Normal
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (e) => widget.onTap!),
          );
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: widget.color!,
              borderRadius: widget.bRadius!,
              border: Border.all(color: widget.borderColor!, width: 1),
            ),
            child: Text(
              widget.buttonText!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: widget.textColor!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
