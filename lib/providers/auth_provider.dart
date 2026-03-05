import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Seller? _currentSeller;
  bool _isLoading = false;

  Seller? get currentSeller => _currentSeller;
  bool get isLoading => _isLoading;

  StreamSubscription<DocumentSnapshot>? _sellerSubscription;

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

      // Auto login after signup
      await signIn(email: email, password: password);

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

      _listenToSellerChanges();

    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= UPDATE & RESUBMIT =================

  Future<void> updateSellerAndResubmit({
    required String sellerName,
    required String businessName,
    required String businessAddress,
    required String phone,
    required String gstNumber,
    required String aadharNumber,
    dynamic selfieImage,
    dynamic aadharFrontImage,
    dynamic aadharBackImage,
    dynamic gstCertificateImage,
  }) async {
    if (_currentSeller == null) {
      throw Exception("Seller not found");
    }

    try {
      _setLoading(true);

      await _authService.updateSellerAndResubmit(
        sellerId: _currentSeller!.id,
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

      // Firestore real-time listener will auto update seller

    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= REAL-TIME SELLER LISTENER =================

  void _listenToSellerChanges() {
    if (_currentSeller == null) return;

    _sellerSubscription?.cancel();

    _sellerSubscription = _firestore
        .collection('sellers')
        .doc(_currentSeller!.id)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      _currentSeller = Seller.fromMap(data, snapshot.id);

      notifyListeners();
    });
  }

  // ================= RESUBMIT WITHOUT EDIT =================

  Future<void> resubmitWithoutChanges() async {
    if (_currentSeller == null) return;

    try {
      await _firestore
          .collection('sellers')
          .doc(_currentSeller!.id)
          .update({
        'approvalStatus': 'pending',
        'rejectionReason': null,
        'statusUpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception("Failed to resubmit");
    }
  }

  // ================= LOAD CURRENT SELLER =================

  Future<void> loadCurrentSeller() async {
    try {
      _setLoading(true);

      final seller = await _authService.getCurrentSeller();
      _currentSeller = seller;

      if (_currentSeller != null) {
        _listenToSellerChanges();
      }

    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ================= SIGN OUT =================

  Future<void> signOut() async {
    await _sellerSubscription?.cancel();
    await _authService.signOut();
    _currentSeller = null;
    notifyListeners();
  }

  // ================= HELPER =================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sellerSubscription?.cancel();
    super.dispose();
  }
}