import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:filozon_kodfu/app/controllers/order_controller.dart';
import 'package:filozon_kodfu/app/models/product_model.dart';
import 'package:filozon_kodfu/app/models/address_model.dart';
import 'package:filozon_kodfu/app/models/order_model.dart';
import 'package:flutter/services.dart';

class CreditCardPage extends StatefulWidget {
  final double totalAmount;
  final List<Product> cartProducts;
  final Address selectedAddress;

  const CreditCardPage({
    Key? key,
    required this.totalAmount,
    required this.cartProducts,
    required this.selectedAddress,
  }) : super(key: key);

  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Kart sahibi adı için özel kontrolcü
  final TextEditingController _cardHolderController = TextEditingController();

  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.7), width: 2.0),
    );
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23243A),
        title: const Text(
          'Kredi Kartı ile Ödeme',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CreditCardWidget(
                    glassmorphismConfig:
                        useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    bankName: 'Bank of Filozon',
                    frontCardBorder:
                        !useGlassMorphism
                            ? Border.all(color: Colors.grey)
                            : null,
                    backCardBorder:
                        !useGlassMorphism
                            ? Border.all(color: Colors.grey)
                            : null,
                    showBackView: isCvvFocused,
                    obscureCardNumber: true,
                    obscureCardCvv: true,
                    isHolderNameVisible: true,
                    cardBgColor:
                        useBackgroundImage
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF23243A),
                    backgroundImage: null,
                    isSwipeGestureEnabled: true,
                    enableFloatingCard: true,
                    floatingConfig: FloatingConfig(
                      isGlareEnabled: true,
                      isShadowEnabled: true,
                      shadowConfig: FloatingShadowConfig(
                        color: Colors.black54,
                        blurRadius: 12,
                        offset: const Offset(5, 5),
                      ),
                    ),
                    onCreditCardWidgetChange:
                        (CreditCardBrand creditCardBrand) {},
                    customCardTypeIcons: const <CustomCardTypeIcon>[],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23243A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // Kredi kartı numarası alanı
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Kart Numarası',
                                hintText: 'XXXX XXXX XXXX XXXX',
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                hintStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: border,
                                enabledBorder: border,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(16),
                                CardNumberFormatter(),
                              ],
                              onChanged: (value) {
                                // Boşlukları kaldır
                                setState(() {
                                  cardNumber = value.replaceAll(' ', '');
                                });
                              },
                              onTap: () {
                                setState(() {
                                  isCvvFocused = false;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Kart numarası zorunlu';
                                }
                                if (value.replaceAll(' ', '').length < 16) {
                                  return 'Geçerli bir kart numarası giriniz';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Son kullanma tarihi
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Son Kullanma Tarihi',
                                hintText: 'AA/YY',
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                hintStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: border,
                                enabledBorder: border,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                ExpiryDateFormatter(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  expiryDate = value;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  isCvvFocused = false;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Son kullanma tarihi zorunlu';
                                }
                                if (value.length < 5) {
                                  return 'Geçerli bir tarih giriniz';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // CVV alanı
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                hintText: 'XXX',
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                hintStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: border,
                                enabledBorder: border,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  cvvCode = value;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  isCvvFocused = true;
                                });
                              },
                              onEditingComplete: () {
                                setState(() {
                                  isCvvFocused = false;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'CVV zorunlu';
                                }
                                if (value.length < 3) {
                                  return 'Geçerli bir CVV giriniz';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Kart sahibi adı - özel formatlayıcılar ile
                            TextFormField(
                              controller: _cardHolderController,
                              decoration: InputDecoration(
                                labelText: 'Kart Sahibi',
                                hintText: 'KART SAHİBİNİN ADI SOYADI',
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                hintStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: border,
                                enabledBorder: border,
                              ),
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-ZçÇğĞıİöÖşŞüÜ ]'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  cardHolderName = value.toUpperCase();
                                });
                              },
                              onTap: () {
                                setState(() {
                                  isCvvFocused = false;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Kart sahibi adı zorunlu';
                                }
                                if (!RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜ ]+$').hasMatch(value)) {
                                  return 'Sadece harf ve boşluk giriniz';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            Text(
                              'Ödenecek Tutar: ${widget.totalAmount.toStringAsFixed(2)} ₺',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  // Önce ödemeyi işle, sonra siparişi kaydet
                                  await _saveOrder();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 30,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Ödemeyi Tamamla',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Future<void> _saveOrder() async {
    try {
      // Sipariş numarası oluştur
      final now = DateTime.now();
      final orderId = 'ORD-${now.millisecondsSinceEpoch}';
      
      // Ürün ID'lerini al
      final productIds = widget.cartProducts.map((p) => p.id.toString()).toList();
      
      // Sipariş oluştur
      final order = Order(
        orderId: orderId,
        orderDate: now,
        orderCost: widget.totalAmount,
        cardNumber: '•••• •••• •••• ${cardNumber.length > 4 ? cardNumber.substring(cardNumber.length - 4) : ''}',
        address: widget.selectedAddress,
        productIds: productIds,
        status: 'completed',
      );
      
      // Siparişi kaydet
      final success = await orderController.addOrder(order);
      
      if (success) {
        // Başarılı mesajını göster
        _showPaymentSuccessDialog(context);
      } else {
        // Başarısız olduysa kullanıcıya bilgi ver
        Get.snackbar(
          'Uyarı',
          'Sipariş oluşturuldu ancak kaydedilirken bir sorun oluştu',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFA000),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Sipariş kaydedilirken hata: $e');
      Get.snackbar(
        'Hata',
        'Sipariş kaydedilirken bir hata oluştu: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
      );
    }
  }

  void _showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23243A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Ödeme Başarılı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kredi kartı ödemesi başarıyla tamamlandı!',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialog'u kapat
                  Navigator.of(
                    context,
                  ).popUntil((route) => route.isFirst); // Ana sayfaya dön
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Kart numarası için özel formatlayıcı
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Son kullanma tarihi için özel formatlayıcı
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
