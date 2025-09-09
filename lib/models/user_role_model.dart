import 'package:flutter/material.dart';

class UserRole {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const UserRole({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
