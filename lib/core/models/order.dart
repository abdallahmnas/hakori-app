import 'product.dart';

class TrackingStep {
  final String title;
  final String description;
  final String timestamp;
  final bool isCompleted;
  final bool isCurrent;

  const TrackingStep({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
    this.isCurrent = false,
  });

  factory TrackingStep.fromJson(Map<String, dynamic> json) {
    return TrackingStep(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'isCompleted': isCompleted,
      'isCurrent': isCurrent,
    };
  }
}

class CommissionOrder {
  final String id;
  final String orderNumber;
  final String date;
  final String status;
  final String statusBadge;
  final List<Product> items;
  final double total;
  final String currency;
  final List<TrackingStep> trackingSteps;
  final String jewelerName;
  final String trackingNumber;
  final String estimatedDelivery;
  final String deliveryAddress;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? specimen;
  final String? paymentUrl;
  final String? flwRef;
  final String? cadRenderUrl;
  final String? paymentStatus;
  final int pipelineStage;

  const CommissionOrder({
    required this.id,
    String? orderNumber,
    String? commissionNumber,
    required this.date,
    required this.status,
    required this.statusBadge,
    required this.items,
    double? total,
    double? totalUsd,
    double? totalNgn,
    this.currency = 'USD',
    required this.trackingSteps,
    this.jewelerName = 'Jean-Luc Atelier (Place Vendôme)',
    this.trackingNumber = 'HK-SEC-9920194-VAULT',
    this.estimatedDelivery = 'October 12, 2026',
    this.deliveryAddress = 'Victoria Island Penthouse 4B, Lagos, Nigeria',
    this.client,
    this.specimen,
    this.paymentUrl,
    this.flwRef,
    this.cadRenderUrl,
    this.paymentStatus,
    this.pipelineStage = 1,
  })  : orderNumber = orderNumber ?? commissionNumber ?? 'HK-0000',
        total = total ?? totalUsd ?? (totalNgn != null ? totalNgn / 1550.0 : 0.0);

  // UI Backward Compatibility Getters
  String get commissionNumber => orderNumber;
  double get totalUsd => total;
  double get totalNgn => total * 1550.0;

  String get specimenTitle {
    if (specimen != null) {
      final t = specimen!['title']?.toString() ?? specimen!['name']?.toString();
      if (t != null && t.isNotEmpty) return t;
    }
    if (items.isNotEmpty) return items.first.title;
    return 'Bespoke Atelier Commission';
  }

  String get specimenImage {
    if (cadRenderUrl != null && cadRenderUrl!.isNotEmpty) return cadRenderUrl!;
    if (items.isNotEmpty && items.first.imageUrl.isNotEmpty) return items.first.imageUrl;
    return 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop';
  }

  factory CommissionOrder.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['total'] ?? json['totalAmount'] ?? json['totalUsd'] ?? 0;
    final double parsedTotal = (rawTotal is num)
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal.toString()) ?? 0.0;

    final rawSteps = json['trackingSteps'];
    List<TrackingStep> steps = [];
    if (rawSteps is List && rawSteps.isNotEmpty) {
      steps = rawSteps
          .map((s) => TrackingStep.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    if (steps.isEmpty) {
      final statusLower = (json['orderStatus']?.toString() ?? json['status']?.toString() ?? '').toLowerCase();
      steps = [
        const TrackingStep(
          title: 'Escrow Secured & CAD Verified',
          description: 'Payment confirmed via Flutterwave escrow. 3D intraoral CAD model verified by master jeweler.',
          timestamp: 'Confirmed',
          isCompleted: true,
          isCurrent: false,
        ),
        TrackingStep(
          title: 'Precision Lost-Wax Investment Casting',
          description: 'Hand-poured 18K solid royal gold ingot casting in progress.',
          timestamp: 'In Progress',
          isCompleted: statusLower.contains('production') || statusLower.contains('shipped') || statusLower.contains('delivered') || statusLower.contains('completed'),
          isCurrent: statusLower.contains('production') || statusLower.contains('processing'),
        ),
        TrackingStep(
          title: 'Microscopic Pavé Diamond Setting',
          description: 'Hand-setting VVS1 colorless melee diamonds under 40x Leica microscope.',
          timestamp: 'Next',
          isCompleted: statusLower.contains('shipped') || statusLower.contains('delivered') || statusLower.contains('completed'),
          isCurrent: false,
        ),
        TrackingStep(
          title: 'Armored Vault Courier Transit',
          description: 'Dispatched via Brink\'s Armored Courier with GPS telemetry.',
          timestamp: 'Estimated Delivery',
          isCompleted: statusLower.contains('delivered') || statusLower.contains('completed'),
          isCurrent: statusLower.contains('shipped'),
        ),
      ];
    }

    final rawItems = json['items'];
    List<Product> parsedItems = [];
    if (rawItems is List && rawItems.isNotEmpty) {
      parsedItems = rawItems
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // When items array is empty but specimen map is provided:
    if (parsedItems.isEmpty && json['specimen'] != null && json['specimen'] is Map) {
      final spec = json['specimen'] as Map<String, dynamic>;
      final specTitle = spec['title']?.toString() ?? spec['name']?.toString() ?? 'Bespoke Haute Commission';
      final specDetails = spec['specDetails']?.toString() ?? '';
      final specPurity = spec['caratOrPurity']?.toString() ?? spec['purity']?.toString() ?? '18K Solid Gold';
      final specCategory = spec['subType']?.toString() ?? 'Haute Series';
      final cadImage = json['cadRenderUrl']?.toString() ??
          spec['cadRenderUrl']?.toString() ??
          spec['imageUrl']?.toString() ??
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop';

      parsedItems = [
        Product(
          id: json['id']?.toString() ?? 'spec_1',
          name: specTitle,
          title: specTitle,
          description: specDetails,
          price: parsedTotal,
          material: specPurity,
          category: specCategory,
          images: [cadImage],
        )
      ];
    }

    final statusStr = json['orderStatus']?.toString() ?? json['status']?.toString() ?? 'PROCESSING';
    final cadUrl = json['cadRenderUrl']?.toString();

    // Client delivery address fallback
    final clientMap = json['client'] as Map<String, dynamic>?;
    final shipping = json['shippingAddress']?.toString() ??
        json['deliveryAddress']?.toString() ??
        (clientMap?['address'] != null ? clientMap!['address'].toString() : 'Victoria Island Penthouse 4B, Lagos, Nigeria');

    return CommissionOrder(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? json['commissionNumber']?.toString() ?? (json['id'] != null ? '${json['id']}' : '#HK-${DateTime.now().year}-0001'),
      date: json['date']?.toString() ?? json['createdAt']?.toString() ?? 'Oct 02, 2026',
      status: statusStr,
      statusBadge: statusStr.toUpperCase(),
      items: parsedItems,
      total: parsedTotal,
      currency: json['currency']?.toString() ?? 'USD',
      trackingSteps: steps,
      jewelerName: json['jewelerName']?.toString() ?? 'Jean-Luc Atelier (Place Vendôme)',
      trackingNumber: json['trackingNumber']?.toString() ?? json['flwRef']?.toString() ?? 'HK-SEC-9920194-VAULT',
      estimatedDelivery: json['estimatedDelivery']?.toString() ?? 'October 12, 2026',
      deliveryAddress: shipping,
      client: clientMap,
      specimen: json['specimen'] as Map<String, dynamic>?,
      paymentUrl: json['paymentUrl']?.toString(),
      flwRef: json['flwRef']?.toString(),
      cadRenderUrl: cadUrl,
      paymentStatus: json['paymentStatus']?.toString(),
      pipelineStage: (json['pipelineStage'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'date': date,
      'status': status,
      'items': items.map((i) => i.toJson()).toList(),
      'total': total,
      'currency': currency,
      'trackingSteps': trackingSteps.map((s) => s.toJson()).toList(),
      'jewelerName': jewelerName,
      'trackingNumber': trackingNumber,
      'estimatedDelivery': estimatedDelivery,
      'shippingAddress': deliveryAddress,
      if (client != null) 'client': client,
      if (specimen != null) 'specimen': specimen,
      if (paymentUrl != null) 'paymentUrl': paymentUrl,
      if (flwRef != null) 'flwRef': flwRef,
      if (cadRenderUrl != null) 'cadRenderUrl': cadRenderUrl,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      'pipelineStage': pipelineStage,
    };
  }
}
