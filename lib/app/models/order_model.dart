import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filozon_kodfu/app/models/address_model.dart';

class Order {
  final String orderId;
  final DateTime orderDate;
  final double orderCost;
  final String cardNumber;
  final Address address;
  final List<String> productIds;
  final String status;

  Order({
    required this.orderId,
    DateTime? orderDate,
    required this.orderCost,
    required this.cardNumber,
    required this.address,
    required this.productIds,
    this.status = 'pending',
  }) : orderDate = orderDate ?? DateTime.now();

  // CopyWith metodu
  Order copyWith({
    String? orderId,
    DateTime? orderDate,
    double? orderCost,
    String? cardNumber,
    Address? address,
    List<String>? productIds,
    String? status,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      orderDate: orderDate ?? this.orderDate,
      orderCost: orderCost ?? this.orderCost,
      cardNumber: cardNumber ?? this.cardNumber,
      address: address ?? this.address,
      productIds: productIds ?? List<String>.from(this.productIds),
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'orderDate': Timestamp.fromDate(orderDate),
      'orderCost': orderCost,
      'cardNumber': cardNumber,
      'address': address.toMap(),
      'productIds': productIds,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    try {
      return Order(
        orderId: map['orderId'] as String? ?? '',
        orderDate: map['orderDate'] != null && map['orderDate'] is Timestamp
            ? (map['orderDate'] as Timestamp).toDate()
            : DateTime.now(),
        orderCost: (map['orderCost'] as num?)?.toDouble() ?? 0.0,
        cardNumber: map['cardNumber'] as String? ?? '',
        address: map['address'] != null
            ? Address.fromMap(Map<String, dynamic>.from(map['address']))
            : Address.empty(),
        productIds: map['productIds'] != null
            ? List<String>.from(map['productIds'] as List)
            : <String>[],
        status: map['status'] as String? ?? 'pending',
      );
    } catch (e) {
      print('Error creating Order from map: $e');
      print('Map data: $map');
      rethrow;
    }
  }
  
  @override
  String toString() {
    return 'Order(orderId: $orderId, orderDate: $orderDate, orderCost: $orderCost, status: $status)';
  }
}
