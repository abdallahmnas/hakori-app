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
}

class CommissionOrder {
  final String id;
  final String commissionNumber;
  final String date;
  final String status;
  final String statusBadge;
  final List<Product> items;
  final double totalUsd;
  final double totalNgn;
  final List<TrackingStep> trackingSteps;
  final String jewelerName;
  final String trackingNumber;
  final String estimatedDelivery;
  final String deliveryAddress;

  const CommissionOrder({
    required this.id,
    required this.commissionNumber,
    required this.date,
    required this.status,
    required this.statusBadge,
    required this.items,
    required this.totalUsd,
    required this.totalNgn,
    required this.trackingSteps,
    this.jewelerName = 'Jean-Luc Atelier (Place Vendôme)',
    this.trackingNumber = 'HK-SEC-9920194-VAULT',
    this.estimatedDelivery = 'October 12, 2026',
    this.deliveryAddress = 'Victoria Island Penthouse 4B, Lagos, Nigeria',
  });
}
