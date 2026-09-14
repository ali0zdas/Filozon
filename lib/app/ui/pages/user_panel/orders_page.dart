import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:filozon_kodfu/app/controllers/order_controller.dart';

class OrdersPage extends StatelessWidget {
  final OrderController orderController = Get.put(OrderController());

  OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Siparişleri yükle
    orderController.fetchOrders();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF23243A),
        title: const Text('Siparişlerim', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF181A20),
      body: Obx(() {
        if (orderController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (orderController.orders.isEmpty) {
          return const Center(
            child: Text('Henüz siparişiniz yok.', style: TextStyle(color: Colors.white70)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderController.orders.length,
          itemBuilder: (context, index) {
            final order = orderController.orders[index];
            return Card(
              color: const Color(0xFF23243A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  'Sipariş No: ${order.orderId}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tarih: ${order.orderDate.toLocal().toString().substring(0, 16)}', style: const TextStyle(color: Colors.white60)),
                    Text('Tutar: ₺${order.orderCost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white60)),
                    Text('Durum: ${order.status}', style: const TextStyle(color: Colors.white60)),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
                onTap: () {
                  // Detay sayfası eklenebilir
                },
              ),
            );
          },
        );
      }),
    );
  }
}
