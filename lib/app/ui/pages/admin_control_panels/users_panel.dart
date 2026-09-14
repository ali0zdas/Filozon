import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UsersPanel extends StatefulWidget {
  const UsersPanel({Key? key}) : super(key: key);

  @override
  _UsersPanelState createState() => _UsersPanelState();
}

class _UsersPanelState extends State<UsersPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  // Function to get all users
  Stream<List<Map<String, dynamic>>> _getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'email': data['email'] ?? 'Bilinmeyen',
          'name': '${data['name'] ?? ''} ${data['surname'] ?? ''}'.trim(),
          'createdAt': data['createdAt'],
          'isAdmin': data['isAdmin'] ?? false,
          'phone': data['phone'] ?? 'Belirtilmemiş',
        };
      }).toList();
    });
  }

  // Function to toggle admin status
  Future<void> _toggleAdminStatus(String userId, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': !currentStatus,
      });
      Get.snackbar(
        'Başarılı',
        'Kullanıcı yetkisi güncellendi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Bir hata oluştu: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Kullanıcı Yönetimi',
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
              colors: [Color(0xFF3B2168), Color(0xFF0F0125)],
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 34, 18, 63), Color(0xFF0F0125)],
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getAllUsers(),
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
                child: Text(
                  'Henüz kullanıcı bulunmuyor',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                final createdAt = user['createdAt'] != null
                    ? (user['createdAt'] as Timestamp).toDate()
                    : null;

                return _buildUserCard(user, createdAt);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, DateTime? createdAt) {
    return Container(
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
          color: Colors.white.withOpacity(0.2),
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
                // User Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'].isNotEmpty ? user['name'] : 'İsimsiz Kullanıcı',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['email'],
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Admin Toggle
                    Column(
                      children: [
                        Text(
                          user['isAdmin'] ? 'Yönetici' : 'Kullanıcı',
                          style: GoogleFonts.poppins(
                            color: user['isAdmin'] ? Colors.amber : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: user['isAdmin'],
                          onChanged: (value) => _toggleAdminStatus(user['id'], user['isAdmin']),
                          activeColor: Colors.amber,
                          activeTrackColor: Colors.amber.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const Divider(color: Colors.white24, height: 24, thickness: 1),
                
                // Additional Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Telefon: ${user['phone']}',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        'Kayıt: ${_dateFormat.format(createdAt)}',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
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
}
