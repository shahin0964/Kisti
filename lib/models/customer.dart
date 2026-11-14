class Customer {
  final String id;
  final String name; // ক্রেতার নাম
  final String phone; // মোবাইল নম্বর
  final String address; // ঠিকানা
  final String nid; // জাতীয় পরিচয়পত্র
  final String guarantorName; // জামিনদার / গ্যারান্টারের নাম
  final String guarantorPhone; // জামিনদারের মোবাইল
  final String productName; // পণ্যের নাম (যেমন: Walton 250L Fridge, Samsung 43" TV)
  final String productCategory; // 'মোবাইল', 'ফ্রিজ', 'টিভি', 'এসি', 'অন্যান্য'
  final String modelOrImei; // মডেল / সিরিয়াল / IMEI নম্বর
  final double cashPrice; // নগদ মূল্য
  final double installmentPrice; // কিস্তিতে মোট বিক্রয় মূল্য
  final double downPayment; // ডাউন পেমেন্ট / অগ্রিম
  final double installmentAmount; // প্রতি কিস্তির টাকা
  final String frequency; // 'মাসিক', 'সাপ্তাহিক', 'দৈনিক'
  final int totalInstallments; // মোট কিস্তির সংখ্যা
  int paidInstallments; // কতটি কিস্তি পরিশোধ হয়েছে
  double totalInstallmentPaid; // কিস্তিতে মোট পরিশোধিত টাকা
  final DateTime startDate; // ক্রয়ের তারিখ
  String status; // 'চলমান', 'পরিশোধিত', 'বকেয়া'

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.nid,
    this.guarantorName = '',
    this.guarantorPhone = '',
    required this.productName,
    required this.productCategory,
    this.modelOrImei = '',
    required this.cashPrice,
    required this.installmentPrice,
    required this.downPayment,
    required this.installmentAmount,
    this.frequency = 'মাসিক',
    required this.totalInstallments,
    this.paidInstallments = 0,
    this.totalInstallmentPaid = 0.0,
    required this.startDate,
    this.status = 'চলমান',
  });

  // আসল কিস্তির ঋণ (ডাউন পেমেন্ট বাদে)
  double get financedAmount => (installmentPrice - downPayment).clamp(0.0, installmentPrice);

  // অবশিষ্ট বকেয়া কিস্তি
  double get remainingAmount => (financedAmount - totalInstallmentPaid).clamp(0.0, financedAmount);

  // মোট জমা (ডাউন পেমেন্ট + কিস্তি)
  double get totalCollected => downPayment + totalInstallmentPaid;

  // সামগ্রিক পরিশোধের শতকরা হার
  double get progressPercentage {
    if (installmentPrice == 0) return 1.0;
    return (totalCollected / installmentPrice).clamp(0.0, 1.0);
  }

  // মোট কিস্তি আদায়
  double get totalPaid => totalInstallmentPaid;

  bool get isFullyPaid =>
      totalCollected >= installmentPrice || paidInstallments >= totalInstallments;

  String get categoryIcon {
    switch (productCategory) {
      case 'মোবাইল':
        return '📱';
      case 'ফ্রিজ':
        return '🧊';
      case 'টিভি':
        return '📺';
      case 'এসি':
        return '❄️';
      case 'বাইক':
        return '🛵';
      default:
        return '📦';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'nid': nid,
      'guarantorName': guarantorName,
      'guarantorPhone': guarantorPhone,
      'productName': productName,
      'productCategory': productCategory,
      'modelOrImei': modelOrImei,
      'cashPrice': cashPrice,
      'installmentPrice': installmentPrice,
      'downPayment': downPayment,
      'installmentAmount': installmentAmount,
      'frequency': frequency,
      'totalInstallments': totalInstallments,
      'paidInstallments': paidInstallments,
      'totalInstallmentPaid': totalInstallmentPaid,
      'startDate': startDate.toIso8601String(),
      'status': status,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      nid: (json['nid'] ?? '') as String,
      guarantorName: (json['guarantorName'] ?? '') as String,
      guarantorPhone: (json['guarantorPhone'] ?? '') as String,
      productName: (json['productName'] ?? 'পণ্য') as String,
      productCategory: (json['productCategory'] ?? 'অন্যান্য') as String,
      modelOrImei: (json['modelOrImei'] ?? '') as String,
      cashPrice: (json['cashPrice'] as num?)?.toDouble() ?? 0.0,
      installmentPrice: (json['installmentPrice'] as num).toDouble(),
      downPayment: (json['downPayment'] as num?)?.toDouble() ?? 0.0,
      installmentAmount: (json['installmentAmount'] as num).toDouble(),
      frequency: (json['frequency'] ?? 'মাসিক') as String,
      totalInstallments: json['totalInstallments'] as int,
      paidInstallments: (json['paidInstallments'] as int?) ?? 0,
      totalInstallmentPaid: (json['totalInstallmentPaid'] as num?)?.toDouble() ??
          ((json['totalPaid'] as num?)?.toDouble() ?? 0.0),
      startDate: DateTime.parse(json['startDate'] as String),
      status: (json['status'] as String?) ?? 'চলমান',
    );
  }
}
