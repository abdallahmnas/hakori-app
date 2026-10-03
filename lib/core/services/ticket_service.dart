import '../constants/api_constants.dart';
import '../models/support_ticket.dart';
import 'api_client.dart';

/// Support Ticket Service matching API_DOCUMENTATION.md
class TicketService {
  final ApiClient _client;

  TicketService(this._client);

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
