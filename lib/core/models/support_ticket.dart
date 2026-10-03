/// Support Ticket and Response Models matching API_DOCUMENTATION.md
class TicketResponseItem {
  final String id;
  final String sender; // 'customer', 'admin', 'staff'
  final String? senderName;
  final String message;
  final String createdAt;

  const TicketResponseItem({
    required this.id,
    required this.sender,
    this.senderName,
    required this.message,
    required this.createdAt,
  });

  factory TicketResponseItem.fromJson(Map<String, dynamic> json) {
    return TicketResponseItem(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? 'customer',
      senderName: json['senderName']?.toString(),
      message: json['message']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      if (senderName != null) 'senderName': senderName,
      'message': message,
      'createdAt': createdAt,
    };
  }
}

class SupportTicket {
  final String id;
  final String ticketNumber;
  final String? userId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final String subject;
  final String category;
  final String priority;
  final String status;
  final String? orderId;
  final String message;
  final String? assignedStaff;
  final List<TicketResponseItem> responses;
  final String? createdAt;
  final String? updatedAt;

  const SupportTicket({
    required this.id,
    required this.ticketNumber,
    this.userId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.subject,
    required this.category,
    this.priority = 'NORMAL',
    this.status = 'OPEN',
    this.orderId,
    required this.message,
    this.assignedStaff,
    this.responses = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final rawResponses = json['responses'];
    List<TicketResponseItem> parsedResponses = [];
    if (rawResponses is List) {
      parsedResponses = rawResponses
          .map((r) => TicketResponseItem.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return SupportTicket(
      id: json['id']?.toString() ?? '',
      ticketNumber: json['ticketNumber']?.toString() ?? 'HAK-000000',
      userId: json['userId']?.toString(),
      customerName: json['customerName']?.toString() ?? '',
      customerEmail: json['customerEmail']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString(),
      subject: json['subject']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      priority: json['priority']?.toString() ?? 'NORMAL',
      status: json['status']?.toString() ?? 'OPEN',
      orderId: json['orderId']?.toString(),
      message: json['message']?.toString() ?? '',
      assignedStaff: json['assignedStaff']?.toString(),
      responses: parsedResponses,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      if (userId != null) 'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      if (customerPhone != null) 'customerPhone': customerPhone,
      'subject': subject,
      'category': category,
      'priority': priority,
      'status': status,
      if (orderId != null) 'orderId': orderId,
      'message': message,
      if (assignedStaff != null) 'assignedStaff': assignedStaff,
      'responses': responses.map((r) => r.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
