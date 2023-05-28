import 'package:flutter/material.dart';
import 'package:civic_user/presentation/utils/styles/app_styles.dart';

class DisplayTitleText extends StatelessWidget {
  const DisplayTitleText({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppStyles.inputAndDisplayTitleStyle,
    );
  }
}
