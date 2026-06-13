import 'package:flutter/material.dart';
import '../models/models.dart';
import '../mock/mock_service.dart';
import '../utils/theme.dart';

class NotificationsScreen extends StatefulWidget {
  final String? userId;

  const NotificationsScreen({super.key, this.userId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _svc = SupabaseService();
  late String _userId;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId ?? _svc.currentUser?.id ?? '';
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_userId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final items = await _svc.getNotifications(_userId);
      if (mounted) {
        setState(() {
          _notifications = items;
          _isLoading = false;
        });
      }
      await _svc.markAllRead(_userId);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _notifIcon(AppNotification n) {
    if (n.type == 'admin_alert') return Icons.info_outline_rounded;
    final t = n.title.toLowerCase();
    if (t.contains('approuv') || t.contains('check') || t.contains('confirm')) {
      return Icons.check_circle_outline;
    }
    if (t.contains('rejet') || t.contains('refus') || t.contains('cancel')) {
      return Icons.cancel_outlined;
    }
    if (t.contains('avertiss') || t.contains('suspendu') || t.contains('bloqu')) {
      return Icons.warning_amber_outlined;
    }
    return Icons.add_circle_outline;
  }

  Color _notifColor(AppNotification n) {
    if (n.type == 'admin_alert') return AppTheme.secondary;
    final t = n.title.toLowerCase();
    if (t.contains('approuv') || t.contains('check') || t.contains('confirm')) {
      return AppTheme.success;
    }
    if (t.contains('rejet') || t.contains('refus') || t.contains('cancel')) {
      return Colors.red;
    }
    if (t.contains('avertiss') || t.contains('suspendu') || t.contains('bloqu')) {
      return AppTheme.warning;
    }
    return AppTheme.primary;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (_, i) => _NotificationCard(
                    notification: _notifications[i],
                    icon: _notifIcon(_notifications[i]),
                    iconColor: _notifColor(_notifications[i]),
                    timeAgo: _timeAgo(_notifications[i].createdAt),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 40,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous n\'avez pas encore de notifications.',
            style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final IconData icon;
  final Color iconColor;
  final String timeAgo;

  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.iconColor,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread
            ? AppTheme.primary.withOpacity(0.04)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.divider,
          width: 1,
        ),
        boxShadow: isUnread ? AppTheme.cardShadow : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textMid, height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
