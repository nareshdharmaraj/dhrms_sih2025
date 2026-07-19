import 'package:flutter/material.dart';

/// Utility class to fix common layout overflow issues in the DHRMS app
class LayoutFixUtils {
  
  /// Creates a responsive container that adapts to screen size
  static Widget responsiveContainer({
    required Widget child,
    double? maxWidth,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final effectiveMaxWidth = maxWidth ?? screenWidth;
        
        return Container(
          width: screenWidth > effectiveMaxWidth ? effectiveMaxWidth : screenWidth,
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, // 4% of screen width
            vertical: 8,
          ),
          margin: margin,
          child: child,
        );
      },
    );
  }

  /// Creates a flexible text widget that handles overflow
  static Widget flexibleText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Flexible(
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines ?? 2,
        overflow: overflow ?? TextOverflow.ellipsis,
        softWrap: true,
      ),
    );
  }

  /// Creates a responsive row that wraps to column on small screens
  static Widget responsiveRowColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double breakpoint = 600,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > breakpoint) {
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children.map((child) => Expanded(child: child)).toList(),
          );
        } else {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
        }
      },
    );
  }

  /// Creates a safe scrollable column
  static Widget safeScrollableColumn({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: physics ?? const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: Column(
                  children: children,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Creates a responsive grid with automatic column count
  static Widget responsiveGrid({
    required List<Widget> children,
    double childAspectRatio = 1.0,
    double maxCrossAxisExtent = 200,
    double mainAxisSpacing = 8,
    double crossAxisSpacing = 8,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  /// Creates a responsive card that adapts its layout
  static Widget responsiveCard({
    required Widget child,
    double? elevation,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: elevation ?? 2,
          margin: margin ?? EdgeInsets.symmetric(
            horizontal: constraints.maxWidth * 0.02,
            vertical: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity,
            padding: padding ?? EdgeInsets.all(
              constraints.maxWidth > 600 ? 20 : 16,
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Creates a responsive button that adapts its size
  static Widget responsiveButton({
    required VoidCallback? onPressed,
    required String text,
    ButtonStyle? style,
    double minWidth = 120,
    double maxWidth = 200,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth * 0.8).clamp(minWidth, maxWidth);
        
        return SizedBox(
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: Text(text),
          ),
        );
      },
    );
  }

  /// Creates a responsive app bar with adaptive title
  static PreferredSizeWidget responsiveAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    return AppBar(
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 400;
          return Text(
            title,
            style: TextStyle(
              fontSize: isNarrow ? 16 : 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        },
      ),
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
    );
  }
}

/// Widget extensions for easier layout fixes
extension LayoutFixExtensions on Widget {
  
  /// Wraps widget in Flexible to prevent overflow
  Widget get flexible => Flexible(child: this);
  
  /// Wraps widget in Expanded to fill available space
  Widget get expanded => Expanded(child: this);
  
  /// Adds responsive padding based on screen size
  Widget responsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04; // 4% of screen width
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }
  
  /// Adds safe area padding
  Widget get safeArea => SafeArea(child: this);
  
  /// Makes widget scrollable if content overflows
  Widget get scrollable => SingleChildScrollView(child: this);
  
  /// Constrains widget width to prevent overflow
  Widget constrainWidth(double maxWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: this,
    );
  }
}

/// Common layout patterns as reusable widgets
class LayoutPatterns {
  
  /// Creates a standard form layout with proper spacing
  static Widget formLayout({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    double spacing = 16,
  }) {
    return LayoutFixUtils.safeScrollableColumn(
      padding: padding,
      children: [
        ...children.expand((child) => [
          child,
          SizedBox(height: spacing),
        ]).take(children.length * 2 - 1),
      ],
    );
  }

  /// Creates a header with title and optional subtitle
  static Widget sectionHeader({
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return LayoutFixUtils.responsiveContainer(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 16),
            action,
          ],
        ],
      ),
    );
  }

  /// Creates a loading state widget
  static Widget loadingState({
    String message = 'Loading...',
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Creates an empty state widget
  static Widget emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// Creates an error state widget
  static Widget errorState({
    required String title,
    String? subtitle,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Responsive breakpoints for consistent UI behavior
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
}
