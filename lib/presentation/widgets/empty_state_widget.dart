import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? iconColor;
  final double iconSize;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.iconColor,
    this.iconSize = 80.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData? icon;

  const ErrorStateWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: icon ?? Icons.error_outline,
      title: title,
      subtitle: subtitle,
      actionText: actionText,
      onActionPressed: onActionPressed,
      iconColor: Colors.red[400],
    );
  }
}

class NoDataWidget extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const NoDataWidget({
    Key? key,
    required this.message,
    this.actionText,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: message,
      subtitle: '暂无数据',
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }
}

class NoNetworkWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoNetworkWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: '网络连接失败',
      subtitle: '请检查网络连接后重试',
      actionText: '重试',
      onActionPressed: onRetry,
      iconColor: Colors.orange[400],
    );
  }
} 