import 'package:flutter/material.dart';
import '../models/seller.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Seller? _currentSeller;
  bool _isLoading = false;

  Seller? get currentSeller => _currentSeller;
  bool get isLoading => _isLoading;

  // ================= SIGN UP =================

  Future<void> signUp({
    required String email,
    required String password,
    required String sellerName,
    required String businessName,
    required String businessAddress,
    required String phone,
    required String gstNumber,
    required String aadharNumber,
    required dynamic selfieImage,
    required dynamic aadharFrontImage,
    required dynamic aadharBackImage,
    required dynamic gstCertificateImage,
  }) async {
    try {
      _setLoading(true);

      await _authService.signUp(
        email: email,
        password: password,
        sellerName: sellerName,
        businessName: businessName,
        businessAddress: businessAddress,
        phone: phone,
        gstNumber: gstNumber,
        aadharNumber: aadharNumber,
        selfieImage: selfieImage,
        aadharFrontImage: aadharFrontImage,
        aadharBackImage: aadharBackImage,
        gstCertificateImage: gstCertificateImage,
      );

      _currentSeller = null;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= SIGN IN =================

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      final seller = await _authService.signIn(
        email: email,
        password: password,
      );


      _currentSeller = seller;

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= SIGN OUT =================

  Future<void> signOut() async {
    await _authService.signOut();
    _currentSeller = null;
    notifyListeners();
  }

  // ================= LOAD CURRENT SELLER =================

  Future<void> loadCurrentSeller() async {
    try {
      _setLoading(true);

      final seller = await _authService.getCurrentSeller();
      _currentSeller = seller;

    } finally {
      _setLoading(false);
    }
  }

  // ================= PRIVATE HELPER =================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}