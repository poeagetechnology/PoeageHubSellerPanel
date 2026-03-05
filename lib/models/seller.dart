import 'package:cloud_firestore/cloud_firestore.dart';

class Seller {
  final String id;

  // Basic info
  final String sellerName;
  final String email;
  final String businessName;
  final String businessAddress;
  final String phone;

  // Verification info
  final String gstNumber;
  final String aadharNumber;
  final String selfieImage;
  final String aadharFrontImage;
  final String aadharBackImage;
  final String gstCertificateImage;

  // Status
  final String approvalStatus;
  final Timestamp? createdAt;
  final Timestamp? statusUpdatedAt;
  final String? rejectionReason;

  // Store info
  final String storeName;
  final String storeDescription;
  final String storeLogo;

  // Ratings & stats
  final double rating;
  final int reviewCount;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final double averageRating;

  // Bank & GST
  final String bankAccountNumber;
  final String bankIFSC;
  final String bankHolderName;
  final String gstStatus;

  // Verification
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
    this.rejectionReason,

    this.storeName = '',
    this.storeDescription = '',
    this.storeLogo = '',

    this.rating = 0.0,
    this.reviewCount = 0,
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.averageRating = 0.0,

    this.bankAccountNumber = '',
    this.bankIFSC = '',
    this.bankHolderName = '',
    this.gstStatus = '',
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
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'statusUpdatedAt': statusUpdatedAt,
      'rejectionReason': rejectionReason,

      'storeName': storeName,
      'storeDescription': storeDescription,
      'storeLogo': storeLogo,

      'rating': rating,
      'reviewCount': reviewCount,
      'totalProducts': totalProducts,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'averageRating': averageRating,

      'bankAccountNumber': bankAccountNumber,
      'bankIFSC': bankIFSC,
      'bankHolderName': bankHolderName,
      'gstStatus': gstStatus,
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
      rejectionReason: map['rejectionReason'],

      storeName: map['storeName'] ?? '',
      storeDescription: map['storeDescription'] ?? '',
      storeLogo: map['storeLogo'] ?? '',

      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      totalProducts: (map['totalProducts'] as num?)?.toInt() ?? 0,
      totalOrders: (map['totalOrders'] as num?)?.toInt() ?? 0,
      totalRevenue: (map['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,

      bankAccountNumber: map['bankAccountNumber'] ?? '',
      bankIFSC: map['bankIFSC'] ?? '',
      bankHolderName: map['bankHolderName'] ?? '',
      gstStatus: map['gstStatus'] ?? '',
      verificationStatus: map['verificationStatus'] ?? 'unverified',
    );
  }

  // ================= COPY WITH =================

  Seller copyWith({
    String? approvalStatus,
    Timestamp? statusUpdatedAt,
    String? rejectionReason,
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
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,

      storeName: storeName,
      storeDescription: storeDescription,
      storeLogo: storeLogo,

      rating: rating,
      reviewCount: reviewCount,
      totalProducts: totalProducts,
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      averageRating: averageRating,

      bankAccountNumber: bankAccountNumber,
      bankIFSC: bankIFSC,
      bankHolderName: bankHolderName,
      gstStatus: gstStatus,
      verificationStatus: verificationStatus,
    );
  }
}