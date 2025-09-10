import 'package:flutter/material.dart';
import 'package:lotto_app/constants/app_constants.dart';

class ImprovedWidgets {
  // Modern Card Widget
  static Widget buildModernCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? elevation,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppConstants.spacingS),
      child: Material(
        color: backgroundColor ?? AppConstants.surfaceColor,
        elevation: elevation ?? 4,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppConstants.radiusL),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppConstants.radiusL),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.spacingM),
            child: child,
          ),
        ),
      ),
    );
  }

  // Modern Button
  static Widget buildModernButton({
    required String text,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
    bool isLoading = false,
    IconData? icon,
  }) {
    return Container(
      width: width,
      height: height ?? 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: backgroundColor != null
              ? [backgroundColor, backgroundColor.withOpacity(0.8)]
              : [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withOpacity(0.8)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color:
                (backgroundColor ?? AppConstants.primaryColor).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: textColor ?? Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: AppConstants.fontSizeM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Modern Text Field
  static Widget buildModernTextField({
    required TextEditingController controller,
    String? labelText,
    String? hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int? maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines ?? 1,
        style: const TextStyle(
          fontSize: AppConstants.fontSizeM,
          color: AppConstants.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppConstants.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: BorderSide(
              color: AppConstants.borderColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: BorderSide(
              color: AppConstants.primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: BorderSide(
              color: AppConstants.errorColor,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingM,
          ),
        ),
      ),
    );
  }

  // Status Badge
  static Widget buildStatusBadge({
    required String text,
    required Color backgroundColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: AppConstants.fontSizeS,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Loading Shimmer
  static Widget buildShimmer({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppConstants.radiusS),
      ),
    );
  }

  // Info Card
  static Widget buildInfoCard({
    required String title,
    required String value,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return buildModernCard(
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color:
                    (iconColor ?? AppConstants.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppConstants.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeS,
                    color: AppConstants.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeL,
                    color: AppConstants.textPrimary,
                    fontWeight: FontWeight.w600,
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
