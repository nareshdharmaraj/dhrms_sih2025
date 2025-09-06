import 'package:flutter/material.dart';
import '../../core/constants/app_styles.dart';

/// Custom elevated button with app styling
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: _buildIcon(),
        label: _buildLabel(),
        style: OutlinedButton.styleFrom(
          foregroundColor: backgroundColor ?? AppColors.primaryBlue,
          side: BorderSide(color: backgroundColor ?? AppColors.primaryBlue),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryBlue,
        foregroundColor: foregroundColor ?? AppColors.white,
      ),
    );
  }

  Widget _buildIcon() {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return icon != null ? Icon(icon) : const SizedBox.shrink();
  }

  Widget _buildLabel() {
    return Text(text);
  }
}

/// Custom card with app styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: AppDimensions.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: Padding(
                padding:
                    padding ??
                    const EdgeInsets.all(AppDimensions.paddingMedium),
                child: child,
              ),
            )
          : Padding(
              padding:
                  padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
              child: child,
            ),
    );
  }
}

/// Status indicator widget
class StatusIndicator extends StatelessWidget {
  final String status;
  final Color? color;
  final IconData? icon;

  const StatusIndicator({
    super.key,
    required this.status,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = color ?? _getStatusColor();
    IconData statusIcon = icon ?? _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: AppTextStyles.bodySmall.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'good':
      case 'healthy':
      case 'normal':
      case 'completed':
        return AppColors.success;
      case 'warning':
      case 'moderate':
      case 'pending':
        return AppColors.warning;
      case 'critical':
      case 'emergency':
      case 'high':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'good':
      case 'healthy':
      case 'normal':
      case 'completed':
        return Icons.check_circle;
      case 'warning':
      case 'moderate':
      case 'pending':
        return Icons.warning;
      case 'critical':
      case 'emergency':
      case 'high':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}

/// Loading overlay widget
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: AppDimensions.marginMedium),
                    Text(
                      message!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.grey400),
            const SizedBox(height: AppDimensions.marginMedium),
            Text(
              title,
              style: AppTextStyles.headline6.copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.marginSmall),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppDimensions.marginLarge),
              AppButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Health metric display widget
class HealthMetric extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isNormal;
  final IconData? icon;

  const HealthMetric({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.isNormal,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = isNormal ? AppColors.success : AppColors.error;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: statusColor, size: 20),
              const SizedBox(width: AppDimensions.marginSmall),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ),
              StatusIndicator(
                status: isNormal ? 'Normal' : 'Abnormal',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          RichText(
            text: TextSpan(
              text: value,
              style: AppTextStyles.headline5.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
