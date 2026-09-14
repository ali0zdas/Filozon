import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:filozon_kodfu/app/controllers/address_controller.dart';
import 'package:filozon_kodfu/app/models/address_model.dart';

class AddressesPage extends StatelessWidget {
  AddressesPage({Key? key}) : super(key: key);
  
  final AddressController addressController = Get.put(AddressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23243A),
        title: const Text('Adreslerim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (addressController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
        }
        
        if (addressController.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 72,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz adres eklenmemiş',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adres eklemek için aşağıdaki butona tıklayın',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: addressController.addresses.length,
          itemBuilder: (context, index) {
            final address = addressController.addresses[index];
            return _buildAddressCard(context, address);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
        onPressed: () => Get.to(() => AddEditAddressPage()),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF23243A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: Color(0xFF6C63FF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white60),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(() => AddEditAddressPage(address: address));
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, address);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Sil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAddressInfoRow(Icons.location_city, "${address.province} / ${address.district}"),
            const SizedBox(height: 8),
            _buildAddressInfoRow(Icons.home, "${address.neighborhood}, ${address.street}"),
            const SizedBox(height: 8),
            _buildAddressInfoRow(Icons.phone, address.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white60),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Address address) {
    Get.defaultDialog(
      backgroundColor: const Color(0xFF23243A),
      title: 'Adresi Sil',
      titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
      content: const Text(
        'Bu adresi silmek istediğinizden emin misiniz?',
        style: TextStyle(color: Colors.white70),
        textAlign: TextAlign.center,
      ),
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white,
      textCancel: 'İptal',
      textConfirm: 'Sil',
      buttonColor: Colors.red,
      onConfirm: () {
        addressController.deleteAddress(address.id!);
        Get.back();
      },
    );
  }
}

class AddEditAddressPage extends StatefulWidget {
  final Address? address;
  
  const AddEditAddressPage({Key? key, this.address}) : super(key: key);

  @override
  _AddEditAddressPageState createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final AddressController addressController = Get.find<AddressController>();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool get isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    
    // Düzenleme modunda alanları doldur
    if (isEditing) {
      _titleController.text = widget.address!.title;
      _provinceController.text = widget.address!.province;
      _districtController.text = widget.address!.district;
      _neighborhoodController.text = widget.address!.neighborhood;
      _streetController.text = widget.address!.street;
      _phoneController.text = widget.address!.phoneNumber;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23243A),
        title: Text(
          isEditing ? 'Adresi Düzenle' : 'Yeni Adres Ekle',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _titleController,
                labelText: 'Adres Başlığı',
                hintText: 'Ev, İş, vb.',
                icon: Icons.bookmark_border,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adres başlığı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _provinceController,
                labelText: 'İl',
                hintText: 'İstanbul, Ankara, vb.',
                icon: Icons.location_city,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen il girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _districtController,
                labelText: 'İlçe',
                hintText: 'Kadıköy, Çankaya, vb.',
                icon: Icons.place,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen ilçe girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _neighborhoodController,
                labelText: 'Mahalle',
                hintText: 'Atatürk Mahallesi, vb.',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen mahalle girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _streetController,
                labelText: 'Sokak ve Açık Adres',
                hintText: 'Daire no, kat no dahil açık adres',
                icon: Icons.home,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen açık adres girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                labelText: 'Telefon Numarası',
                hintText: '05XX XXX XX XX',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen telefon numarası girin';
                  }
                  if (!value.startsWith('0') || value.length != 11) {
                    return 'Geçerli bir telefon numarası girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                onPressed: addressController.isLoading.value
                    ? null
                    : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: addressController.isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing ? 'Güncelle' : 'Kaydet',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        filled: true,
        fillColor: const Color(0xFF23243A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final Address address = Address(
        id: isEditing ? widget.address!.id : null,
        title: _titleController.text,
        province: _provinceController.text,
        district: _districtController.text,
        neighborhood: _neighborhoodController.text,
        street: _streetController.text,
        phoneNumber: _phoneController.text,
      );

      if (isEditing) {
        addressController.updateAddress(address);
      } else {
        addressController.addAddress(address);
      }
    }
  }
} 