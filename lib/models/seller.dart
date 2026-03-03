import 'package:cloud_firestore/cloud_firestore.dart';

class Seller {
  final String id;
  final String sellerName;
  final String email;
  final String businessName;
  final String businessAddress;
  final String phone;
  final String gstNumber;
  final String aadharNumber;
  final String selfieImage;
  final String aadharFrontImage;
  final String aadharBackImage;
  final String gstCertificateImage;

  // ✅ Approval
  final String approvalStatus; // pending / approved / rejected
  final Timestamp? createdAt; // 🔥 Added
  final Timestamp? statusUpdatedAt; // 🔥 Added (future use)

  // 🔥 Store & Business Details
  final String storeName;
  final String storeDescription;
  final String storeLogo;
  final double rating;
  final int reviewCount;
  final String bankAccountNumber;
  final String bankIFSC;
  final String bankHolderName;
  final String gstStatus;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final double averageRating;
  final String verificationStatus;

  Seller({
    required this.id,
    required this.sellerName,
    required this.email,
    required this.businessName,
    required this.businessAddress,
    required this.phone,
    required this.gstNumber,
    required this.aadharNumber,
    required this.selfieImage,
    required this.aadharFrontImage,
    required this.aadharBackImage,
    required this.gstCertificateImage,

    this.approvalStatus = 'pending',
    this.createdAt,
    this.statusUpdatedAt,

    this.storeName = '',
    this.storeDescription = '',
    this.storeLogo = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.bankAccountNumber = '',
    this.bankIFSC = '',
    this.bankHolderName = '',
    this.gstStatus = '',
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.averageRating = 0.0,
    this.verificationStatus = 'unverified',
  });

  // ================= STATUS HELPERS =================

  bool get isApproved => approvalStatus == 'approved';
  bool get isPending => approvalStatus == 'pending';
  bool get isRejected => approvalStatus == 'rejected';

  // ================= TO MAP =================

  Map<String, dynamic> toMap() {
    return {
      'sellerName': sellerName,
      'email': email,
      'businessName': businessName,
      'businessAddress': businessAddress,
      'phone': phone,
      'gstNumber': gstNumber,
      'aadharNumber': aadharNumber,
      'selfieImage': selfieImage,
      'aadharFrontImage': aadharFrontImage,
      'aadharBackImage': aadharBackImage,
      'gstCertificateImage': gstCertificateImage,
      'approvalStatus': approvalStatus,

      // 🔥 Important timestamps
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'statusUpdatedAt': statusUpdatedAt,

      // Store details
      'storeName': storeName,
      'storeDescription': storeDescription,
      'storeLogo': storeLogo,
      'rating': rating,
      'reviewCount': reviewCount,
      'bankAccountNumber': bankAccountNumber,
      'bankIFSC': bankIFSC,
      'bankHolderName': bankHolderName,
      'gstStatus': gstStatus,
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'averageRating': averageRating,
      'verificationStatus': verificationStatus,
    };
  }

  // ================= FROM MAP =================

  factory Seller.fromMap(Map<String, dynamic> map, String documentId) {
    return Seller(
      id: documentId,
      sellerName: map['sellerName'] ?? '',
      email: map['email'] ?? '',
      businessName: map['businessName'] ?? '',
      businessAddress: map['businessAddress'] ?? '',
      phone: map['phone'] ?? '',
      gstNumber: map['gstNumber'] ?? '',
      aadharNumber: map['aadharNumber'] ?? '',
      selfieImage: map['selfieImage'] ?? '',
      aadharFrontImage: map['aadharFrontImage'] ?? '',
      aadharBackImage: map['aadharBackImage'] ?? '',
      gstCertificateImage: map['gstCertificateImage'] ?? '',
      approvalStatus:
      (map['approvalStatus'] ?? 'pending').toString().toLowerCase(),

      createdAt: map['createdAt'] as Timestamp?,
      statusUpdatedAt: map['statusUpdatedAt'] as Timestamp?,

      storeName: map['storeName'] ?? '',
      storeDescription: map['storeDescription'] ?? '',
      storeLogo: map['storeLogo'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      bankAccountNumber: map['bankAccountNumber'] ?? '',
      bankIFSC: map['bankIFSC'] ?? '',
      bankHolderName: map['bankHolderName'] ?? '',
      gstStatus: map['gstStatus'] ?? '',
      totalProducts: map['totalProducts'] ?? 0,
      totalOrders: map['totalOrders'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      averageRating: (map['averageRating'] ?? 0).toDouble(),
      verificationStatus: map['verificationStatus'] ?? 'unverified',
    );
  }

  // ================= COPY WITH (Very Useful) =================

  Seller copyWith({
    String? approvalStatus,
    Timestamp? statusUpdatedAt,
  }) {
    return Seller(
      id: id,
      sellerName: sellerName,
      email: email,
      businessName: businessName,
      businessAddress: businessAddress,
      phone: phone,
      gstNumber: gstNumber,
      aadharNumber: aadharNumber,
      selfieImage: selfieImage,
      aadharFrontImage: aadharFrontImage,
      aadharBackImage: aadharBackImage,
      gstCertificateImage: gstCertificateImage,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      createdAt: createdAt,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      storeName: storeName,
      storeDescription: storeDescription,
      storeLogo: storeLogo,
      rating: rating,
      reviewCount: reviewCount,
      bankAccountNumber: bankAccountNumber,
      bankIFSC: bankIFSC,
      bankHolderName: bankHolderName,
      gstStatus: gstStatus,
      totalProducts: totalProducts,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      averageRating: averageRating,
      verificationStatus: verificationStatus,
    );
  }
}