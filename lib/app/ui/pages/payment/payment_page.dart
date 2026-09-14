import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:filozon_kodfu/app/models/product_model.dart';
import 'package:filozon_kodfu/app/ui/pages/payment/credit_card_page.dart';
import 'package:filozon_kodfu/app/controllers/address_controller.dart';
import 'package:filozon_kodfu/app/models/address_model.dart';

class PaymentPage extends StatefulWidget {
  final List<Product> cartProducts;
  final double totalAmount;

  const PaymentPage({
    Key? key,
    required this.cartProducts,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final AddressController addressController = Get.put(AddressController());
  Address? selectedAddress;
  String selectedPaymentMethod = 'credit_card';
  bool isCardConfirmed = false;

  @override
  void initState() {
    super.initState();
    // Adresler yüklendikten sonra ilk adresi seçili yap
    ever(addressController.addresses, (List<Address> addresses) {
      if (selectedAddress == null && addresses.isNotEmpty) {
        setState(() {
          selectedAddress = addresses.first;
        });
      }
    });
    // Eğer adresler zaten yüklüyse hemen ata
    if (addressController.addresses.isNotEmpty) {
      selectedAddress = addressController.addresses.first;
    }
  }

  void _showAddressSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF23243A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(() {
          final addresses = addressController.addresses;
          if (addresses.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Kayıtlı adres bulunamadı.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white12),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return ListTile(
                leading: const Icon(Icons.location_on, color: Color(0xFF6C63FF)),
                title: Text(address.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${address.province}, ${address.district}\n${address.neighborhood}, ${address.street}\n${address.phoneNumber}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                isThreeLine: true,
                trailing: selectedAddress?.id == address.id
                    ? const Icon(Icons.check_circle, color: Color(0xFF6C63FF))
                    : null,
                onTap: () {
                  setState(() {
                    selectedAddress = address;
                  });
                  Navigator.pop(context);
                },
              );
            },
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23243A),
        title: const Text(
          'Ödeme',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.1,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sipariş Özeti',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              // Ürünlerin özet listesi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF23243A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.cartProducts.map((product) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.image!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${product.price.toStringAsFixed(2)} ₺',
                                      style: const TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toplam Tutar:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.totalAmount.toStringAsFixed(2)} ₺',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ...ödeme yöntemi ve buton kaldırıldı...
              const Text(
                'Teslimat Adresi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (addressController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
                }
                if (addressController.addresses.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23243A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Kayıtlı adres bulunamadı. Profilinizden adres ekleyebilirsiniz.',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23243A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedAddress?.title ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: _showAddressSelectionDialog,
                            child: const Text('Değiştir'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selectedAddress != null
                            ? '${selectedAddress!.province}, ${selectedAddress!.district}\n${selectedAddress!.neighborhood}, ${selectedAddress!.street}\n${selectedAddress!.phoneNumber}'
                            : '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF23243A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Toplam',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${widget.totalAmount.toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedAddress == null) {
                  Get.snackbar(
                    'Uyarı',
                    'Lütfen bir teslimat adresi seçin.',
                    backgroundColor: const Color(0xFF23243A),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                // Devam Et: kredi kartı sayfasına yönlendir
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreditCardPage(
                      totalAmount: widget.totalAmount,
                      cartProducts: widget.cartProducts,
                      selectedAddress: selectedAddress!,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Devam Et',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 