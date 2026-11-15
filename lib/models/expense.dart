class Expense {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String note;

  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      category: (json['category'] as String?) ?? 'বিবিধ',
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: (json['note'] as String?) ?? '',
    );
  }

  String get categoryIcon {
    final cat = category.toLowerCase();
    if (cat.contains('ভাড়া') || cat.contains('rent')) return '🏢';
    if (cat.contains('বিদ্যুৎ') || cat.contains('কারেন্ট') || cat.contains('bill')) return '⚡';
    if (cat.contains('বেতন') || cat.contains('salary')) return '👥';
    if (cat.contains('পরিবহন') || cat.contains('গাড়ি') || cat.contains('transport')) return '🚚';
    if (cat.contains('নাস্তা') || cat.contains('চা') || cat.contains('খাবার') || cat.contains('food')) return '☕';
    if (cat.contains('মেরামত') || cat.contains('সার্ভিসিং') || cat.contains('repair')) return '🛠️';
    return '📝';
  }
}
