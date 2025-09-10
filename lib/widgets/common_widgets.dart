import 'package:flutter/material.dart';
import 'package:lotto_app/constants/app_constants.dart';
import 'package:lotto_app/theme/app_theme.dart';

class CommonWidgets {
  // Common loading widget
  static Widget loadingWidget({String? message, double? size}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 50,
            height: size ?? 50,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.spacingM),
            Text(
              message,
              style: TextStyle(
                fontSize: AppConstants.fontSizeM,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Common error widget
  static Widget errorWidget({
    required String message,
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: AppConstants.iconSizeXXL,
              color: AppConstants.errorColor,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeM,
                color: AppConstants.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.spacingL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('ลองใหม่'),
                style: AppTheme.primaryButtonStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Common empty state widget
  static Widget emptyStateWidget({
    required String message,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: AppConstants.iconSizeXXL,
              color: AppConstants.textHint,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeM,
                color: AppConstants.textSecondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppConstants.spacingL),
              action,
            ],
          ],
        ),
      ),
    );
  }

  // Common card widget
  static Widget cardWidget({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? elevation,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: margin ?? const EdgeInsets.all(AppConstants.spacingS),
      color: color ?? AppConstants.surfaceColor,
      elevation: elevation ?? 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppConstants.spacingM),
          child: child,
        ),
      ),
    );
  }

  // Common section header
  static Widget sectionHeader({
    required String title,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  // Common divider
  static Widget divider({double? height, Color? color}) {
    return Divider(
      height: height ?? 1,
      color: color ?? AppConstants.textHint,
      thickness: 1,
    );
  }

  // Common spacing
  static Widget spacing({double? height, double? width}) {
    return SizedBox(
      height: height,
      width: width,
    );
  }

  // Common icon button
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? color,
    double? size,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  // Common text button
  static Widget textButton({
    required String text,
    required VoidCallback onPressed,
    Color? color,
    bool isPrimary = false,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: isPrimary
          ? AppTheme.primaryButtonStyle
          : AppTheme.secondaryButtonStyle,
      child: Text(text),
    );
  }

  // Common elevated button
  static Widget elevatedButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isPrimary = true,
    bool isSuccess = false,
    bool isError = false,
    Widget? icon,
  }) {
    ButtonStyle style;
    if (isError) {
      style = AppTheme.errorButtonStyle;
    } else if (isSuccess) {
      style = AppTheme.successButtonStyle;
    } else if (isPrimary) {
      style = AppTheme.primaryButtonStyle;
    } else {
      style = AppTheme.secondaryButtonStyle;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon,
                      const SizedBox(width: AppConstants.spacingS),
                      Text(text),
                    ],
                  )
                : Text(text),
      ),
    );
  }

  // Common text field
  static Widget textField({
    required TextEditingController controller,
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    VoidCallback? onSuffixIconTap,
    int? maxLines,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconTap,
              )
            : null,
      ),
    );
  }

  // Common app bar
  static PreferredSizeWidget appBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppConstants.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
    );
  }

  // Common bottom navigation bar
  static Widget bottomNavigationBar({
    required int currentIndex,
    required Function(int) onTap,
    required List<BottomNavigationBarItem> items,
  }) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppConstants.primaryColor,
      unselectedItemColor: AppConstants.textSecondary,
    );
  }
}
