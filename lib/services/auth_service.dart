import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/seller.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ================= IMAGE UPLOAD =================

  Future<String> uploadImage(
      dynamic image,
      String userId,
      String type,
      String sellerName,
      ) async {
    String sanitize(String s) {
      return s
          .toLowerCase()
          .replaceAll(RegExp(r"[^a-z0-9_\- ]"), '')
          .replaceAll(' ', '_');
    }

    final fileName = '${sanitize(sellerName)}_$type.jpg';
    final ref =
    _storage.ref().child('SellerDocuments/$userId/$fileName');

    if (kIsWeb) {
      Uint8List bytes;

      if (image is Uint8List) {
        bytes = image;
      } else if (image is XFile) {
        bytes = await image.readAsBytes();
      } else {
        throw Exception('Unsupported image type for web');
      }

      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    } else {
      if (image is File) {
        await ref.putFile(image);
      } else if (image is XFile) {
        await ref.putFile(File(image.path));
      } else {
        throw Exception('Unsupported image type');
      }
    }

    return await ref.getDownloadURL();
  }

  // ================= SIGN UP =================

  Future<UserCredential> signUp({
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

    final userCredential = await _auth
        .createUserWithEmailAndPassword(
        email: email, password: password);

    final userId = userCredential.user!.uid;


    final selfieUrl = await uploadImage(
        selfieImage, userId, 'selfie', sellerName);

    final aadharFrontUrl = await uploadImage(
        aadharFrontImage, userId, 'aadhar_front', sellerName);

    final aadharBackUrl = await uploadImage(
        aadharBackImage, userId, 'aadhar_back', sellerName);

    final gstCertificateUrl = await uploadImage(
        gstCertificateImage,
        userId,
        'gst_certificate',
        sellerName);


    Seller seller = Seller(
      id: userId,
      sellerName: sellerName,
      email: email,
      businessName: businessName,
      businessAddress: businessAddress,
      phone: phone,
      gstNumber: gstNumber,
      aadharNumber: aadharNumber,
      selfieImage: selfieUrl,
      aadharFrontImage: aadharFrontUrl,
      aadharBackImage: aadharBackUrl,
      gstCertificateImage: gstCertificateUrl,
      approvalStatus: 'pending',
      createdAt: Timestamp.now(),
    );


    await _firestore
        .collection('sellers')
        .doc(userId)
        .set({
      ...seller.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  // ================= SIGN IN =================

  Future<Seller> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth
        .signInWithEmailAndPassword(
        email: email, password: password);

    final uid = userCredential.user!.uid;

    final doc =
    await _firestore.collection('sellers').doc(uid).get();

    if (!doc.exists) {
      await _auth.signOut();
      throw Exception('SELLER_NOT_FOUND');
    }

    final seller = Seller.fromMap(
        doc.data() as Map<String, dynamic>, doc.id);

    switch (seller.approvalStatus) {
      case 'approved':
        return seller;

      case 'pending':
        await _auth.signOut();
        throw Exception('PENDING_APPROVAL');

      case 'rejected':
        await _auth.signOut();
        throw Exception('ACCOUNT_REJECTED');

      default:
        await _auth.signOut();
        throw Exception('UNKNOWN_STATUS');
    }
  }

  // ================= SIGN OUT =================

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ================= GET CURRENT SELLER =================

  Future<Seller?> getCurrentSeller() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc =
    await _firestore.collection('sellers').doc(user.uid).get();

    if (!doc.exists) return null;

    return Seller.fromMap(
        doc.data() as Map<String, dynamic>, doc.id);
  }
}