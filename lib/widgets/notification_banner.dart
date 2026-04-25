import 'package:flutter/material.dart';

class NotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final Duration duration;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBanner({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
    this.duration = const Duration(seconds: 5),
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_animation),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Dismissible(
          key: Key(widget.title + widget.message),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => _dismiss(),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications_active,
                color: widget.textColor ?? Colors.blue,
              ),
            ),
            title: Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.textColor ?? Colors.blue,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              widget.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: widget.textColor ?? Colors.blue,
                fontSize: 14,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.close, color: widget.textColor ?? Colors.blue),
              onPressed: _dismiss,
            ),
            onTap: _dismiss,
          ),
        ),
      ),
    );
  }
}
