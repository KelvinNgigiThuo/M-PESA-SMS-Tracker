import 'package:flutter/material.dart';
import '../main.dart';

class MoneyText extends StatelessWidget {
  final String value;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? hidden;

  const MoneyText(
    this.value, {
    super.key,
    this.style,
    this.textAlign,
    this.hidden,
  });

  @override
  Widget build(BuildContext context) {
    if (hidden != null) {
      return Text(
        hidden! ? '•••••' : value,
        style: style,
        textAlign: textAlign,
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isPrivacyMode,
      builder: (context, globalHidden, _) {
        return Text(
          globalHidden ? '•••••' : value,
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}
