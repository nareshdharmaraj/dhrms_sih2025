import 'package:flutter/material.dart';

class UserRole {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  UserRole({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      icon: _getIconFromString(json['icon'] ?? 'person'),
      color: Color(json['color'] ?? 0xFF4CAF50),
      route: json['route'] ?? '/',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'icon': _getStringFromIcon(icon),
      'color': color.value,
      'route': route,
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person;
      case 'medical_services':
        return Icons.medical_services;
      case 'admin_panel_settings':
        return Icons.admin_panel_settings;
      case 'local_hospital':
        return Icons.local_hospital;
      default:
        return Icons.person;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    if (icon == Icons.person) return 'person';
    if (icon == Icons.medical_services) return 'medical_services';
    if (icon == Icons.admin_panel_settings) return 'admin_panel_settings';
    if (icon == Icons.local_hospital) return 'local_hospital';
    return 'person';
  }
}
