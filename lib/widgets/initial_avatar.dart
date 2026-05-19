import 'package:flutter/material.dart';

class InitialAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  final double fontSize;

  const InitialAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.color,
    this.fontSize = 20,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color get avatarColor {
    if (color != null) return color!;
    final colors = [
      const Color(0xFFE91E8C),
      const Color(0xFF9C27B0),
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
