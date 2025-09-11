import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePasswordVisibility;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePasswordVisibility,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(
            fontSize: AppConstants.largeFont,
            color: AppConstants.primaryText,
          ),
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText ?? labelText,
            labelStyle: TextStyle(
              color: AppConstants.mediumGrey,
              fontSize: AppConstants.mediumFont,
            ),
            hintStyle: TextStyle(
              color: AppConstants.hintText,
              fontSize: AppConstants.mediumFont,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppConstants.mediumGrey,
                    size: 20,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide(
                color: AppConstants.lightGrey,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide(
                color: AppConstants.lightGrey,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide(
                color: AppConstants.primaryGreen,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide(
                color: AppConstants.errorRed,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide(
                color: AppConstants.errorRed,
                width: 2.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide(
                color: AppConstants.lightGrey.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.mediumPadding,
              vertical: AppConstants.mediumPadding,
            ),
            errorStyle: const TextStyle(
              color: AppConstants.errorRed,
              fontSize: AppConstants.smallFont,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (isPassword) {
      return IconButton(
        onPressed: onTogglePasswordVisibility,
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: AppConstants.mediumGrey,
          size: 20,
        ),
      );
    } else if (suffixIcon != null) {
      return Icon(
        suffixIcon,
        color: AppConstants.mediumGrey,
        size: 20,
      );
    }
    return null;
  }
}

// Specialized text fields for different use cases
class CustomEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomEmailField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'Email Address',
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: focusNode,
      onChanged: onChanged,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
            }
            if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
    );
  }
}

class CustomPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomPhoneField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'Phone Number',
      prefixIcon: Icons.phone,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      focusNode: focusNode,
      onChanged: onChanged,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!RegExp(AppConstants.phonePattern).hasMatch(value)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  const CustomPasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText,
      prefixIcon: Icons.lock,
      isPassword: true,
      isPasswordVisible: _isPasswordVisible,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onTogglePasswordVisibility: () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
    );
  }
}
