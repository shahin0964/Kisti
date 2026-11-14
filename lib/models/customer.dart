class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String nid;
  final double principalAmount; // আসল ঋণ
  final double interestRate; // লাভ / সুদের হার (%)
  final double totalPayable; // মোট প্রদেয় টাকা
  final double installmentAmount; // প্রতি কিস্তির টাকা
  final String frequency; // 'দৈনিক', 'সাপ্তাহিক', 'মাসিক'
  final int totalInstallments; // মোট কিস্তির সংখ্যা
  int paidInstallments; // কতটি কিস্তি পরিশোধ হয়েছে
  double totalPaid; // মোট পরিশোধিত টাকা
  final DateTime startDate;
  String status; // 'চলমান', 'পরিশোধিত', 'বকেয়া'

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.nid,
    required this.principalAmount,
    this.interestRate = 10.0,
    required this.totalPayable,
    required this.installmentAmount,
    required this.frequency,
    required this.totalInstallments,
    this.paidInstallments = 0,
    this.totalPaid = 0.0,
    required this.startDate,
    this.status = 'চলমান',
  });

  double get remainingAmount => (totalPayable - totalPaid).clamp(0.0, totalPayable);

  double get progressPercentage {
    if (totalPayable == 0) return 1.0;
    return (totalPaid / totalPayable).clamp(0.0, 1.0);
  }

  bool get isFullyPaid => totalPaid >= totalPayable || paidInstallments >= totalInstallments;

  DateTime get nextDueDate {
    if (frequency == 'দৈনিক') {
      return startDate.add(Duration(days: paidInstallments + 1));
    } else if (frequency == 'সাপ্তাহিক') {
      return startDate.add(Duration(days: (paidInstallments + 1) * 7));
    } else {
      return DateTime(
        startDate.year,
        startDate.month + (paidInstallments + 1),
        startDate.day,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'nid': nid,
      'principalAmount': principalAmount,
      'interestRate': interestRate,
      'totalPayable': totalPayable,
      'installmentAmount': installmentAmount,
      'frequency': frequency,
      'totalInstallments': totalInstallments,
      'paidInstallments': paidInstallments,
      'totalPaid': totalPaid,
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
      principalAmount: (json['principalAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 10.0,
      totalPayable: (json['totalPayable'] as num).toDouble(),
      installmentAmount: (json['installmentAmount'] as num).toDouble(),
      frequency: json['frequency'] as String,
      totalInstallments: json['totalInstallments'] as int,
      paidInstallments: (json['paidInstallments'] as int?) ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['startDate'] as String),
      status: (json['status'] as String?) ?? 'চলমান',
    );
  }
}
