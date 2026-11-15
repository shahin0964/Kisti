import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/collection.dart';
import '../models/expense.dart';

class DailyCollectionGroup {
  final DateTime date;
  final double totalAmount;
  final List<CollectionRecord> records;

  DailyCollectionGroup({
    required this.date,
    required this.totalAmount,
    required this.records,
  });
}

class KistiStorage extends ChangeNotifier {
  static const String _keyCustomers = 'kisti_product_sales_v3';
  static const String _keyCollections = 'kisti_product_collections_v3';
  static const String _keyExpenses = 'kisti_expenses_v3';

  List<Customer> _customers = [];
  List<CollectionRecord> _collections = [];
  List<Expense> _expenses = [];
  bool _isLoaded = false;

  List<Customer> get customers => List.unmodifiable(_customers);
  List<CollectionRecord> get collections => List.unmodifiable(_collections);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoaded => _isLoaded;

  KistiStorage() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove legacy fake / seed caches
    if (prefs.containsKey('kisti_product_sales_v2')) {
      await prefs.remove('kisti_product_sales_v2');
      await prefs.remove('kisti_product_collections_v2');
      await prefs.remove('kisti_customers_v1');
      await prefs.remove('kisti_collections_v1');
    }

    final customersJson = prefs.getString(_keyCustomers);
    final collectionsJson = prefs.getString(_keyCollections);
    final expensesJson = prefs.getString(_keyExpenses);

    if (customersJson != null) {
      try {
        final List<dynamic> custList = jsonDecode(customersJson);
        _customers = custList.map((e) => Customer.fromJson(e)).toList();
      } catch (e) {
        _customers = [];
      }
    } else {
      _customers = [];
    }

    if (collectionsJson != null) {
      try {
        final List<dynamic> colList = jsonDecode(collectionsJson);
        _collections = colList.map((e) => CollectionRecord.fromJson(e)).toList();
      } catch (e) {
        _collections = [];
      }
    } else {
      _collections = [];
    }

    if (expensesJson != null) {
      try {
        final List<dynamic> expList = jsonDecode(expensesJson);
        _expenses = expList.map((e) => Expense.fromJson(e)).toList();
      } catch (e) {
        _expenses = [];
      }
    } else {
      _expenses = [];
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final customersJson = jsonEncode(_customers.map((c) => c.toJson()).toList());
    final collectionsJson = jsonEncode(_collections.map((c) => c.toJson()).toList());
    final expensesJson = jsonEncode(_expenses.map((e) => e.toJson()).toList());

    await prefs.setString(_keyCustomers, customersJson);
    await prefs.setString(_keyCollections, collectionsJson);
    await prefs.setString(_keyExpenses, expensesJson);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCustomers);
    await prefs.remove(_keyCollections);
    await prefs.remove(_keyExpenses);
    _customers = [];
    _collections = [];
    _expenses = [];
    notifyListeners();
  }

  // --- Customer CRUD ---

  Future<void> addCustomer(Customer customer) async {
    _customers.insert(0, customer);
    await _saveData();
  }

  Future<void> updateCustomer(Customer updated) async {
    final index = _customers.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _customers[index] = updated;
      await _saveData();
    }
  }

  Future<void> deleteCustomer(String id) async {
    _customers.removeWhere((c) => c.id == id);
    _collections.removeWhere((r) => r.customerId == id);
    await _saveData();
  }

  // --- Collection CRUD ---

  Future<CollectionRecord> recordCollection({
    required Customer customer,
    required double amount,
    required String paymentMethod,
    String note = '',
    String collector = 'ক্যাশিয়ার',
  }) async {
    final nextIndex = customer.paidInstallments + 1;
    final newInstallmentPaid = customer.totalInstallmentPaid + amount;
    final newPaidCount = customer.paidInstallments + 1;

    String newStatus = customer.status;
    if ((customer.downPayment + newInstallmentPaid) >= customer.installmentPrice ||
        newPaidCount >= customer.totalInstallments) {
      newStatus = 'পরিশোধিত';
    } else if (customer.status == 'বকেয়া') {
      newStatus = 'চলমান';
    }

    customer.paidInstallments = newPaidCount;
    customer.totalInstallmentPaid = newInstallmentPaid;
    customer.status = newStatus;

    final receipt = CollectionRecord(
      id: 'COL-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customer.id,
      customerName: customer.name,
      productName: customer.productName,
      amount: amount,
      date: DateTime.now(),
      installmentIndex: nextIndex,
      paymentMethod: paymentMethod,
      collector: collector,
      receiptNo: 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      note: note,
    );

    _collections.insert(0, receipt);
    await updateCustomer(customer);
    return receipt;
  }

  Future<void> deleteCollection(String id) async {
    _collections.removeWhere((c) => c.id == id);
    await _saveData();
  }

  // --- Expense CRUD ---

  Future<void> addExpense(Expense expense) async {
    _expenses.insert(0, expense);
    await _saveData();
  }

  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    await _saveData();
  }

  // --- Daily Collection Grouping ---

  List<DailyCollectionGroup> get dailyCollectionGroups {
    final Map<String, List<CollectionRecord>> grouped = {};
    for (final record in _collections) {
      final key = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(record);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final List<DailyCollectionGroup> result = [];

    for (final key in sortedKeys) {
      final records = grouped[key]!;
      records.sort((a, b) => b.date.compareTo(a.date));
      final total = records.fold(0.0, (sum, r) => sum + r.amount);
      result.add(DailyCollectionGroup(
        date: records.first.date,
        totalAmount: total,
        records: records,
      ));
    }

    return result;
  }

  // --- Dynamic Categories ---

  List<String> get dynamicCategories {
    final set = <String>{};
    for (final c in _customers) {
      final cat = c.productCategory.trim();
      if (cat.isNotEmpty) {
        set.add(cat);
      }
    }
    return set.toList();
  }

  int getCategoryCount(String category) {
    return _customers.where((c) => c.productCategory.trim() == category.trim()).length;
  }

  // --- Financial & Product Metrics ---

  /// মোট কিস্তিতে বিক্রয় মূল্য
  double get totalProductSalesValue =>
      _customers.fold(0.0, (sum, c) => sum + c.installmentPrice);

  /// মোট পণ্যের ক্রয়মূল্য / নগদ মূল্য (Cost)
  double get totalCashCost =>
      _customers.fold(0.0, (sum, c) => sum + c.cashPrice);

  /// বিক্রয়ের উপর মোট প্রত্যাশিত লাভ (Total Expected Markup)
  double get totalExpectedProfit {
    final profit = totalProductSalesValue - totalCashCost;
    return profit > 0 ? profit : 0.0;
  }

  /// মোট ডাউন পেমেন্ট আদায়
  double get totalDownPaymentCollected =>
      _customers.fold(0.0, (sum, c) => sum + c.downPayment);

  /// মোট কিস্তি আদায়
  double get totalInstallmentCollectedAllTime =>
      _collections.fold(0.0, (sum, r) => sum + r.amount);

  /// সর্বমোট সংগৃহীত টাকা (ডাউন পেমেন্ট + কিস্তি আদায়)
  double get totalCollectedAll =>
      totalDownPaymentCollected + totalInstallmentCollectedAllTime;

  /// বর্তমান বকেয়া কিস্তির পরিমাণ
  double get totalOutstandingKisti {
    return _customers
        .where((c) => c.status != 'পরিশোধিত')
        .fold(0.0, (sum, c) => sum + c.remainingAmount);
  }

  /// আজ সংগৃহীত কিস্তি
  double get todayCollected {
    final now = DateTime.now();
    return _collections
        .where((r) =>
            r.date.year == now.year &&
            r.date.month == now.month &&
            r.date.day == now.day)
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  /// আজকের আদায় লক্ষ্যমাত্রা
  double get todayTarget {
    return _customers
        .where((c) => c.status == 'চলমান' || c.status == 'বকেয়া')
        .fold(0.0, (sum, c) => sum + c.installmentAmount);
  }

  /// মোট খরচের পরিমাণ (Expenses)
  double get totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  /// আজকের খরচ
  double get todayExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// আদায়কৃত টাকার সাপেক্ষে অর্জিত লাভ (Realized Profit)
  /// অর্জিত লাভ = (মোট সংগৃহীত / মোট বিক্রয়) * সর্বমোট প্রত্যাশিত লাভ
  double get earnedGrossProfit {
    if (totalProductSalesValue <= 0) return 0.0;
    final collectionRatio = (totalCollectedAll / totalProductSalesValue).clamp(0.0, 1.0);
    return totalExpectedProfit * collectionRatio;
  }

  /// অর্জিত নিট লাভ / ক্ষতি (Net Profit = Earned Gross Profit - Total Expenses)
  double get netProfit => earnedGrossProfit - totalExpenses;

  /// সামগ্রিক প্রজেক্টেড নিট লাভ (Total Expected Markup - Total Expenses)
  double get projectedNetProfit => totalExpectedProfit - totalExpenses;

  int get totalProductsSoldCount => _customers.length;
  int get activeCustomersCount => _customers.where((c) => c.status == 'চলমান').length;
  int get overdueCustomersCount => _customers.where((c) => c.status == 'বকেয়া').length;
  int get completedCustomersCount => _customers.where((c) => c.status == 'পরিশোধিত').length;

  List<Customer> get todayDueCustomers {
    return _customers.where((c) => c.status != 'পরিশোধিত').toList();
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<CollectionRecord> getCollectionsForCustomer(String customerId) {
    return _collections.where((r) => r.customerId == customerId).toList();
  }
}
