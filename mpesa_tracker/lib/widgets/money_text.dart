import 'package:flutter/material.dart';
import '../main.dart';

class MoneyText extends StatelessWidget {
  final String value;
  final TextStyle? style;
  final TextAlign? textAlign;

  const MoneyText(
    this.value, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPrivacyMode,
      builder: (context, hidden, _) {
        return Text(
          hidden ? '•••••' : value,
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}