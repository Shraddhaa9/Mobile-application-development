import 'package:flutter/material.dart';

class MultiIcons extends StatelessWidget {
  List<Icon> icons;

  MultiIcons({required this.icons});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      spacing: 4.0,
      children: icons,
    );
  }
}

class IconButtonWithText extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onPressed;

  const IconButtonWithText({
    Key? key,
    required this.icon,
    required this.title,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
