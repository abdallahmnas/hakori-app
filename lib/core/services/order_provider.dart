import 'package:flutter/foundation.dart';
import '../models/order.dart';
import 'order_service.dart';
import 'api_client.dart';

enum OrderStateStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Patron Commissions & Order History Provider
class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;

  OrderStateStatus _status = OrderStateStatus.initial;
  List<CommissionOrder> _orders = [];
  String? _errorMessage;
  CommissionOrder? _lastCreatedOrder;

  OrderProvider(this._orderService);

  OrderStateStatus get status => _status;
  bool get isLoading => _status == OrderStateStatus.loading;
  List<CommissionOrder> get orders => _orders;
  String? get errorMessage => _errorMessage;
  CommissionOrder? get lastCreatedOrder => _lastCreatedOrder;

  List<CommissionOrder> get activeOrders => _orders
      .where((o) => o.status != 'Delivered' && o.status != 'Cancelled')
      .toList();

  List<CommissionOrder> get completedOrders => _orders
      .where((o) => o.status == 'Delivered' || o.status == 'Settled')
      .toList();

  Future<void> fetchOrders({bool silent = false}) async {
    if (!silent) {
      _status = OrderStateStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final fetched = await _orderService.getMyOrders();
      _orders = fetched;
      _status = OrderStateStatus.loaded;
      _errorMessage = null;
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = OrderStateStatus.error;
      notifyListeners();
    } catch (_) {
      _errorMessage = 'Failed to load commissions.';
      _status = OrderStateStatus.error;
      notifyListeners();
    }
  }

  Future<CommissionOrder?> placeOrder({
    required Map<String, dynamic> client,
    required Map<String, dynamic> specimen,
    required double total,
    String currency = 'USD',
    required String shippingAddress,
  }) async {
    _status = OrderStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderService.placeOrder(
        client: client,
        specimen: specimen,
        total: total,
        currency: currency,
        shippingAddress: shippingAddress,
      );
      _lastCreatedOrder = order;
      _orders.insert(0, order);
      _status = OrderStateStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return order;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = OrderStateStatus.error;
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = 'Could not place commission order.';
      _status = OrderStateStatus.error;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelOrder(String id) async {
    try {
      final updated = await _orderService.cancelOrder(id);
      final index = _orders.indexWhere((o) => o.id == id);
      if (index >= 0) {
        _orders[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
