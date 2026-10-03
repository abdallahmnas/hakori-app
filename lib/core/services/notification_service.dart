import '../constants/api_constants.dart';
import '../models/notification_item.dart';
import 'api_client.dart';

/// Patron Notifications API Service matching API_DOCUMENTATION.md
class NotificationService {
  final ApiClient _client;

  NotificationService(this._client);

  /// Get Patron Notifications Feed
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await _client.get(ApiConstants.notifications);
      final data = response.data['data'];
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['notifications'] is List) {
        items = data['notifications'] as List;
      }
      return items
          .map((n) => NotificationItem.fromJson(n as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Mark Notification as Read
  Future<void> markAsRead(String id) async {
    try {
      await _client.put(ApiConstants.markNotificationRead(id));
    } catch (_) {}
  }

  /// Mark All Notifications as Read
  Future<void> markAllAsRead() async {
    try {
      await _client.put(ApiConstants.markAllNotificationsRead);
    } catch (_) {}
  }
}
