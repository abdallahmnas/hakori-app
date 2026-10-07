import '../constants/api_constants.dart';
import '../models/support_ticket.dart';
import 'api_client.dart';

/// Support Ticket Service matching API_DOCUMENTATION.md
class TicketService {
  final ApiClient _client;

  TicketService(this._client);

  /// Get List of Support Tickets
  Future<List<SupportTicket>> getMyTickets({int page = 0, int pageSize = 20}) async {
    try {
      final response = await _client.get(
        ApiConstants.tickets,
        queryParameters: {
          'page': page,
          'currentPage': page,
          'pageSize': pageSize,
          'itemsPerPage': pageSize,
        },
      );
      final raw = response.data;
      List list = [];
      if (raw is List) {
        list = raw;
      } else if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          list = data;
        } else if (data is Map && data['tickets'] is List) {
          list = data['tickets'] as List;
        } else if (data is Map && data['items'] is List) {
          list = data['items'] as List;
        } else if (raw['tickets'] is List) {
          list = raw['tickets'] as List;
        }
      }

      return list
          .map((item) => SupportTicket.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Create Customer Support Ticket
  Future<SupportTicket> createTicket({
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    required String subject,
    String category = 'Order Inquiry',
    String priority = 'NORMAL',
    String? orderId,
    required String message,
  }) async {
    final response = await _client.post(
      ApiConstants.tickets,
      data: {
        'customerName': customerName.trim(),
        'customerEmail': customerEmail.trim(),
        if (customerPhone != null && customerPhone.isNotEmpty) 'customerPhone': customerPhone.trim(),
        'subject': subject.trim(),
        'category': category,
        'priority': priority,
        if (orderId != null && orderId.isNotEmpty) 'orderId': orderId.trim(),
        'message': message.trim(),
      },
    );

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final tMap = data['ticket'] as Map<String, dynamic>? ?? data;
    return SupportTicket.fromJson(tMap);
  }

  /// Get Support Ticket & Thread History
  Future<SupportTicket> getTicketDetails(String id) async {
    final response = await _client.get(ApiConstants.ticketDetail(id));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final tMap = data['ticket'] as Map<String, dynamic>? ?? data;
    return SupportTicket.fromJson(tMap);
  }

  /// Customer Reply to Ticket Thread
  Future<SupportTicket> replyToTicket({
    required String id,
    required String message,
  }) async {
    final response = await _client.post(
      ApiConstants.ticketReply(id),
      data: {'message': message.trim()},
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final tMap = data['ticket'] as Map<String, dynamic>? ?? data;
    return SupportTicket.fromJson(tMap);
  }
}
