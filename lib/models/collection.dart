class CollectionRecord {
  final String id;
  final String customerId;
  final String customerName;
  final String productName; // পণ্যের নাম
  final double amount;
  final DateTime date;
  final int installmentIndex;
  final String paymentMethod; // 'নগদ', 'বিকাশ', 'নগদ-অ্যাপ', 'রকেট', 'ব্যাংক'
  final String collector;
  final String receiptNo;
  final String note;

  CollectionRecord({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.productName = '',
    required this.amount,
    required this.date,
    required this.installmentIndex,
    this.paymentMethod = 'নগদ',
    this.collector = 'ম্যানেজার',
    required this.receiptNo,
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'productName': productName,
      'amount': amount,
      'date': date.toIso8601String(),
      'installmentIndex': installmentIndex,
      'paymentMethod': paymentMethod,
      'collector': collector,
      'receiptNo': receiptNo,
      'note': note,
    };
  }

  factory CollectionRecord.fromJson(Map<String, dynamic> json) {
    return CollectionRecord(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      productName: (json['productName'] ?? '') as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      installmentIndex: json['installmentIndex'] as int,
      paymentMethod: (json['paymentMethod'] as String?) ?? 'নগদ',
      collector: (json['collector'] as String?) ?? 'ম্যানেজার',
      receiptNo: (json['receiptNo'] as String?) ?? '',
      note: (json['note'] as String?) ?? '',
    );
  }
}
