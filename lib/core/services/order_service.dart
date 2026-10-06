import '../constants/api_constants.dart';
import '../models/order.dart';
import 'api_client.dart';
// removed mock data import

/// Orders & Payments API Service matching API_DOCUMENTATION.md
class OrderService {
  final ApiClient _client;

  OrderService(this._client);

  /// Place New Bespoke Commission Order (Flutterwave escrow checkout)
  Future<CommissionOrder> placeOrder({
    required Map<String, dynamic> client,
    required Map<String, dynamic> specimen,
    required double total,
    String currency = 'USD',
    required String shippingAddress,
  }) async {
    final response = await _client.post(
      ApiConstants.orders,
      data: {
        'client': client,
        'specimen': specimen,
        'total': total,
        'currency': currency,
        'shippingAddress': shippingAddress,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final orderMap = data['order'] as Map<String, dynamic>? ?? data;

    // Attach payment checkout URL and Flutterwave reference if returned
    final merged = Map<String, dynamic>.from(orderMap);
    if (data['paymentUrl'] != null) merged['paymentUrl'] = data['paymentUrl'];
    if (data['flwRef'] != null) merged['flwRef'] = data['flwRef'];

    return CommissionOrder.fromJson(merged);
  }

  /// Get Patron Order History (0-based pagination)
  Future<List<CommissionOrder>> getMyOrders({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final query = <String, dynamic>{
        'currentPage': page,
        'page': page,
        'itemsPerPage': pageSize,
        'pageSize': pageSize,
      };
      final response = await _client.get(
        ApiConstants.myOrders,
        queryParameters: query,
      );
      final respData = response.data;
      List items = [];
      if (respData is List) {
        items = respData;
      } else if (respData is Map) {
        final data = respData['data'];
        if (data is List) {
          items = data;
        } else if (data is Map && data['orders'] is List) {
          items = data['orders'] as List;
        } else if (data is Map && data['items'] is List) {
          items = data['items'] as List;
        } else if (respData['orders'] is List) {
          items = respData['orders'] as List;
        }
      }

      if (items.isNotEmpty) {
        return items
            .map((o) => CommissionOrder.fromJson(o as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get Order Details by ID
  Future<CommissionOrder> getOrderDetails(String id) async {
    try {
      final response = await _client.get(ApiConstants.orderDetail(id));
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      final orderMap = data['order'] as Map<String, dynamic>? ?? data;
      return CommissionOrder.fromJson(orderMap);
    } catch (_) {
      throw ApiException(message: "Order details not found", isNetworkError: false);
    }
  }

  /// Cancel Pending Commission
  Future<CommissionOrder> cancelOrder(String id) async {
    final response = await _client.post(ApiConstants.cancelOrder(id));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final orderMap = data['order'] as Map<String, dynamic>? ?? data;
    return CommissionOrder.fromJson(orderMap);
  }

  /// Verify Flutterwave Payment Session
  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    final response = await _client.get(ApiConstants.verifyPayment(reference));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return data;
  }
}
