import 'package:flutter/material.dart';
import 'package:lotto_app/constants/app_constants.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
  custom,
}

class NotificationSystem {
  static OverlayEntry? _currentOverlay;

  static void showNotification(
    BuildContext context,
    String message, {
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Color? customColor,
    IconData? customIcon,
  }) {
    // Hide any existing notification
    hideNotification();

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        type: type,
        duration: duration,
        onTap: onTap,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        customColor: customColor,
        customIcon: customIcon,
        onDismiss: hideNotification,
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);
  }

  static void hideNotification() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  // Convenience methods
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    showNotification(
      context,
      message,
      type: NotificationType.success,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showNotification(
      context,
      message,
      type: NotificationType.error,
      duration: duration,
      onTap: onTap,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    showNotification(
      context,
      message,
      type: NotificationType.warning,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    showNotification(
      context,
      message,
      type: NotificationType.info,
      duration: duration,
      onTap: onTap,
    );
  }
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Color? customColor;
  final IconData? customIcon;
  final VoidCallback onDismiss;

  const _NotificationWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.onTap,
    this.actionLabel,
    this.onActionPressed,
    this.customColor,
    this.customIcon,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return AppConstants.successColor;
      case NotificationType.error:
        return AppConstants.errorColor;
      case NotificationType.warning:
        return AppConstants.warningColor;
      case NotificationType.info:
        return AppConstants.infoColor;
      case NotificationType.custom:
        return widget.customColor ?? AppConstants.primaryColor;
    }
  }

  IconData _getIcon() {
    if (widget.customIcon != null) return widget.customIcon!;

    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.custom:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  child: Row(
                    children: [
                      Icon(
                        _getIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: AppConstants.spacingS),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppConstants.fontSizeM,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.actionLabel != null) ...[
                        const SizedBox(width: AppConstants.spacingS),
                        TextButton(
                          onPressed: widget.onActionPressed,
                          child: Text(
                            widget.actionLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      IconButton(
                        onPressed: _dismiss,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Toast notification for quick messages
class ToastNotification {
  static void show(
    BuildContext context,
    String message, {
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIcon(type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSizeS,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _getBackgroundColor(type),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppConstants.spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        duration: duration,
      ),
    );
  }

  static IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.custom:
        return Icons.notifications;
    }
  }

  static Color _getBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppConstants.successColor;
      case NotificationType.error:
        return AppConstants.errorColor;
      case NotificationType.warning:
        return AppConstants.warningColor;
      case NotificationType.info:
        return AppConstants.infoColor;
      case NotificationType.custom:
        return AppConstants.primaryColor;
    }
  }
}
