import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final double elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = AppConstants.mediumRadius,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.fontSize = AppConstants.largeFont,
    this.fontWeight = FontWeight.w600,
    this.padding,
    this.elevation = 0,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final backgroundColor = widget.backgroundColor ?? AppConstants.primaryGreen;
    final textColor = widget.textColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height ?? 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.elevation > 0
                  ? [
                      BoxShadow(
                        color: backgroundColor.withValues(alpha: 0.3),
                        blurRadius: widget.elevation,
                        offset: Offset(0, widget.elevation / 2),
                      ),
                    ]
                  : null,
            ),
            child: widget.isOutlined
                ? _buildOutlinedButton(backgroundColor, textColor, isEnabled)
                : _buildFilledButton(backgroundColor, textColor, isEnabled),
          ),
        );
      },
    );
  }

  Widget _buildFilledButton(Color backgroundColor, Color textColor, bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? _handlePress : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? backgroundColor : AppConstants.lightGrey,
        foregroundColor: isEnabled ? textColor : AppConstants.mediumGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        padding: widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.mediumPadding,
            ),
        elevation: 0,
      ),
      child: _buildButtonContent(textColor, isEnabled),
    );
  }

  Widget _buildOutlinedButton(Color backgroundColor, Color textColor, bool isEnabled) {
    return OutlinedButton(
      onPressed: isEnabled ? _handlePress : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: isEnabled ? backgroundColor : AppConstants.mediumGrey,
        side: BorderSide(
          color: isEnabled ? backgroundColor : AppConstants.lightGrey,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        padding: widget.padding ??
            const EdgeInsets.symmetric(
              horizontal: AppConstants.largePadding,
              vertical: AppConstants.mediumPadding,
            ),
      ),
      child: _buildButtonContent(backgroundColor, isEnabled),
    );
  }

  Widget _buildButtonContent(Color color, bool isEnabled) {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isOutlined ? color : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: widget.isOutlined ? color : Colors.white,
            ),
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            size: widget.fontSize + 2,
            color: widget.isOutlined ? color : Colors.white,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: widget.isOutlined
                  ? (isEnabled ? color : AppConstants.mediumGrey)
                  : Colors.white,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        color: widget.isOutlined
            ? (isEnabled ? color : AppConstants.mediumGrey)
            : Colors.white,
      ),
    );
  }

  void _handlePress() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onPressed?.call();
  }
}

// Specialized button variants
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppConstants.primaryGreen,
      textColor: Colors.white,
      isLoading: isLoading,
      icon: icon,
      width: width,
      elevation: 2,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppConstants.primaryGreen,
      textColor: AppConstants.primaryGreen,
      isLoading: isLoading,
      icon: icon,
      width: width,
      isOutlined: true,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppConstants.errorRed,
      textColor: Colors.white,
      isLoading: isLoading,
      icon: icon,
      width: width,
      elevation: 2,
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const SuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppConstants.successGreen,
      textColor: Colors.white,
      isLoading: isLoading,
      icon: icon,
      width: width,
      elevation: 2,
    );
  }
}

class FloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const FloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppConstants.primaryGreen,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppConstants.primaryGreen).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
