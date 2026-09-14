import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrdersPanel extends StatefulWidget {
  const OrdersPanel({Key? key}) : super(key: key);

  @override
  _OrdersPanelState createState() => _OrdersPanelState();
}

class _OrdersPanelState extends State<OrdersPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '\$',
    decimalDigits: 2,
  );

  // Function to get all orders from all users
  Stream<List<Map<String, dynamic>>> _getAllOrders() {
    debugPrint('Starting to fetch all orders...');
    return _firestore
        .collection('users')
        .snapshots()
        .asyncMap((usersSnapshot) async {
      List<Map<String, dynamic>> allOrders = [];
      debugPrint('Found ${usersSnapshot.docs.length} users in the database');
      
      // Tüm kullanıcılar için döngü
      for (var userDoc in usersSnapshot.docs) {
        try {
          debugPrint('Processing user: ${userDoc.id}');
          
          // Kullanıcının userData koleksiyonunu al
          final userDataSnapshot = await userDoc.reference
              .collection('userData')
              .doc('Orders')
              .collection('items')
              .get();
              
          debugPrint('Found ${userDataSnapshot.docs.length} orders for user ${userDoc.id}');
          
          // Kullanıcı bilgilerini al
          final userData = (await userDoc.reference.get()).data();
          
          // Her sipariş için
          for (var orderDoc in userDataSnapshot.docs) {
            try {
              final orderData = orderDoc.data();
              debugPrint('Processing order ${orderDoc.id}: $orderData');
              
              // Kullanıcı adı ve e-postasını al
              String userName = 'Misafir Kullanıcı';
              String userEmail = '';
              
              if (userData != null) {
                final name = userData['name']?.toString() ?? '';
                final surname = userData['surname']?.toString() ?? '';
                userName = '$name $surname'.trim();
                if (userName.isEmpty) userName = 'İsimsiz Kullanıcı';
                userEmail = userData['email']?.toString() ?? '';
              }
              
              // Sipariş verilerini logla
              debugPrint('Order data: $orderData');
              
              // orderCost alanını al
              final orderCost = (orderData['orderCost'] as num?)?.toDouble() ?? 0.0;
              debugPrint('Order cost for ${orderDoc.id}: $orderCost');
              
              allOrders.add({
                ...orderData,
                'orderId': orderDoc.id,
                'userId': userDoc.id,
                'userName': userName,
                'userEmail': userEmail,
                'totalAmount': orderCost, // orderCost'u totalAmount olarak kullan
              });
              
            } catch (e) {
              debugPrint('Error processing order ${orderDoc.id}: $e');
            }
          }
          
        } catch (e) {
          debugPrint('Error processing user ${userDoc.id}: $e');
        }
      }
      
      debugPrint('Total orders found: ${allOrders.length}');
      
      // Tarihe göre sırala (en yeni en üstte)
      allOrders.sort((a, b) {
        final aDate = a['orderDate'] as Timestamp?;
        final bDate = b['orderDate'] as Timestamp?;
        return (bDate ?? Timestamp.now()).compareTo(aDate ?? Timestamp.now());
      });
      
      return allOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Tüm Siparişler',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 59, 33, 104), Color.fromARGB(255, 15, 1, 37)],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
            onPressed: () {
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 50, 28, 89), Color.fromARGB(255, 0, 0, 0)],
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getAllOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Bir hata oluştu: ${snapshot.error}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Henüz sipariş bulunmuyor',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Refresh the data
                        setState(() {});
                      },
                      child: const Text('Yenile'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                final orderDate = (order['orderDate'] as Timestamp).toDate();
                final orderId = order['orderId'] ?? 'unknown';

                return _buildOrderCard(order, orderDate, orderId);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, DateTime orderDate, String orderId) {
    final items = (order['items'] is List) ? (order['items'] as List).whereType<Map<String, dynamic>>().toList() : <Map<String, dynamic>>[];
    final userName = (order['userName']?.toString().trim().isNotEmpty == true) 
        ? order['userName'].toString().trim() 
        : 'Misafir Kullanıcı';
    final userEmail = order['userEmail']?.toString() ?? '';
    final status = (order['status']?.toString().toLowerCase() ?? 'pending').toLowerCase();
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sipariş #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: GoogleFonts.poppins(
                          color: _getStatusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Customer Info
                Text(
                  'Müşteri: $userName',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                
                if (userEmail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'E-posta: $userEmail',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Order Date
                Text(
                  'Tarih: ${DateFormat('dd.MM.yyyy HH:mm').format(orderDate)}',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1, thickness: 1),
                const SizedBox(height: 12),
                
                // Order Items
                if (items.isNotEmpty) ...[
                  ...items.map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '• ${item['name']?.toString() ?? 'Bilinmeyen Ürün'} x${item['quantity']?.toString() ?? '1'}',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                ],
                
                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Toplam Tutar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(
                        (order['totalAmount'] is num) 
                          ? order['totalAmount'] 
                          : 0.0
                      ),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Tamamlandı';
      case 'processing':
        return 'İşleniyor';
      case 'cancelled':
        return 'İptal Edildi';
      case 'shipped':
        return 'Kargoda';
      default:
        return 'Beklemede';
    }
  }
}
