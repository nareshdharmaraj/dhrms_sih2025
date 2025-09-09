import 'package:flutter/material.dart';
import '../models/user_role_model.dart';

class RoleCardWidget extends StatefulWidget {
  final UserRole role;
  final bool isTablet;
  final VoidCallback onTap;

  const RoleCardWidget({
    super.key,
    required this.role,
    required this.isTablet,
    required this.onTap,
  });

  @override
  State<RoleCardWidget> createState() => _RoleCardWidgetState();
}

class _RoleCardWidgetState extends State<RoleCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

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
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(widget.isTablet ? 24.0 : 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isPressed ? 0.1 : 0.15),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 6),
                  ),
                ],
                border: Border.all(
                  color: widget.role.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildContent(),
                  ),
                  _buildArrow(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: widget.isTablet ? 70 : 60,
      height: widget.isTablet ? 70 : 60,
      decoration: BoxDecoration(
        color: widget.role.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.role.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        widget.role.icon,
        size: widget.isTablet ? 35 : 30,
        color: widget.role.color,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.role.title,
          style: TextStyle(
            fontSize: widget.isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.role.subtitle,
          style: TextStyle(
            fontSize: widget.isTablet ? 16 : 14,
            color: widget.role.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.role.description,
          style: TextStyle(
            fontSize: widget.isTablet ? 14 : 12,
            color: Colors.grey[600],
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildArrow() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.role.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.arrow_forward_ios,
        size: widget.isTablet ? 20 : 16,
        color: widget.role.color,
      ),
    );
  }
}
