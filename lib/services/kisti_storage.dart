import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/collection.dart';
import '../models/expense.dart';
import '../models/sms_template.dart';

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
  static const String _keyAutoBackupEnabled = 'kisti_auto_backup_enabled';
  static const String _keyLastAutoBackupTime = 'kisti_last_auto_backup_time';
  static const String _keyOfflineBackupSnapshot = 'kisti_offline_backup_snapshot';
  static const String _keyAutoSmsEnabled = 'kisti_auto_sms_enabled';
  static const String _keyShopName = 'kisti_shop_name';

  List<Customer> _customers = [];
  List<CollectionRecord> _collections = [];
  List<Expense> _expenses = [];
  bool _isLoaded = false;
  bool _isAutoBackupEnabled = true;
  DateTime? _lastAutoBackupTime;
  bool _isAutoSmsEnabled = true;
  String _shopName = 'কিস্তি সেবা শো-রুম';

  List<Customer> get customers => List.unmodifiable(_customers);
  List<CollectionRecord> get collections => List.unmodifiable(_collections);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoaded => _isLoaded;
  bool get isAutoBackupEnabled => _isAutoBackupEnabled;
  DateTime? get lastAutoBackupTime => _lastAutoBackupTime;
  bool get isAutoSmsEnabled => _isAutoSmsEnabled;
  String get shopName => _shopName;

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

    _isAutoBackupEnabled = prefs.getBool(_keyAutoBackupEnabled) ?? true;
    _isAutoSmsEnabled = prefs.getBool(_keyAutoSmsEnabled) ?? true;
    _shopName = prefs.getString(_keyShopName) ?? 'কিস্তি সেবা শো-রুম';

    final lastBackupStr = prefs.getString(_keyLastAutoBackupTime);
    if (lastBackupStr != null) {
      _lastAutoBackupTime = DateTime.tryParse(lastBackupStr);
    }

    _isLoaded = true;
    notifyListeners();

    // Trigger auto backup check
    await checkAndTriggerDailyAutoBackup();
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

  // --- Settings ---

  Future<void> setAutoBackupEnabled(bool enabled) async {
    _isAutoBackupEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackupEnabled, enabled);
    notifyListeners();
  }

  Future<void> setAutoSmsEnabled(bool enabled) async {
    _isAutoSmsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoSmsEnabled, enabled);
    notifyListeners();
  }

  Future<void> setShopName(String name) async {
    _shopName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyShopName, name);
    notifyListeners();
  }

  // --- Offline Auto Backup (11:30 PM Daily) ---

  Future<String> createOfflineBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final backupPayload = {
      'version': '1.0.4',
      'backupTimestamp': now.toIso8601String(),
      'type': 'offline_auto_backup',
      'shopName': _shopName,
      'stats': {
        'totalCustomers': _customers.length,
        'totalCollections': _collections.length,
        'totalExpenses': _expenses.length,
        'totalSales': totalProductSalesValue,
        'totalCollected': totalCollectedAll,
      },
      'customers': _customers.map((c) => c.toJson()).toList(),
      'collections': _collections.map((c) => c.toJson()).toList(),
      'expenses': _expenses.map((e) => e.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupPayload);
    await prefs.setString(_keyOfflineBackupSnapshot, jsonString);
    await prefs.setString(_keyLastAutoBackupTime, now.toIso8601String());
    _lastAutoBackupTime = now;
    notifyListeners();
    return jsonString;
  }

  Future<void> checkAndTriggerDailyAutoBackup() async {
    if (!_isAutoBackupEnabled) return;

    final now = DateTime.now();
    // Check if 11:30 PM (23:30) condition is met for today
    // Or if last backup was before today
    bool shouldBackup = false;
    if (_lastAutoBackupTime == null) {
      shouldBackup = true;
    } else {
      final isDifferentDay = _lastAutoBackupTime!.year != now.year ||
          _lastAutoBackupTime!.month != now.month ||
          _lastAutoBackupTime!.day != now.day;
      if (isDifferentDay && (now.hour > 23 || (now.hour == 23 && now.minute >= 30))) {
        shouldBackup = true;
      }
    }

    if (shouldBackup) {
      await createOfflineBackup();
    }
  }

  Future<String?> getSavedOfflineBackup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOfflineBackupSnapshot);
  }

  Future<bool> restoreFromOfflineBackup([String? jsonString]) async {
    try {
      String? dataToRestore = jsonString;
      if (dataToRestore == null || dataToRestore.trim().isEmpty) {
        dataToRestore = await getSavedOfflineBackup();
      }
      if (dataToRestore == null || dataToRestore.trim().isEmpty) {
        return false;
      }

      final dynamic decoded = jsonDecode(dataToRestore);
      if (decoded is! Map<String, dynamic>) return false;

      final List<dynamic>? custList = decoded['customers'];
      final List<dynamic>? colList = decoded['collections'];
      final List<dynamic>? expList = decoded['expenses'];

      if (custList != null) {
        _customers = custList.map((e) => Customer.fromJson(e)).toList();
      }
      if (colList != null) {
        _collections = colList.map((e) => CollectionRecord.fromJson(e)).toList();
      }
      if (expList != null) {
        _expenses = expList.map((e) => Expense.fromJson(e)).toList();
      }

      await _saveData();
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- Personalized SMS Helper ---

  String personalizeSmsTemplate(
    SmsTemplate template,
    Customer customer, {
    CollectionRecord? record,
  }) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    final installmentAmtStr = formatter.format(customer.installmentAmount);
    final remainingAmtStr = formatter.format(customer.remainingAmount);
    final dateStr = DateFormat('dd MMMM yyyy').format(
      record != null ? record.date : DateTime.now(),
    );
    final paymentAmtStr = record != null
        ? formatter.format(record.amount)
        : formatter.format(customer.installmentAmount);
    final receiptNoStr = record?.receiptNo ?? 'REC-${customer.id}';

    String text = template.content;
    text = text.replaceAll('{গ্রাহকের নাম}', customer.name);
    text = text.replaceAll('{পণ্যের নাম}', customer.productName);
    text = text.replaceAll('{কিস্তির পরিমাণ}', installmentAmtStr);
    text = text.replaceAll('{বকেয়া পরিমাণ}', remainingAmtStr);
    text = text.replaceAll('{পরিশোধের পরিমাণ}', paymentAmtStr);
    text = text.replaceAll('{রশিদ}', receiptNoStr);
    text = text.replaceAll('{তারিখ}', dateStr);
    text = text.replaceAll('{দোকানের নাম}', _shopName);
    return text;
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
      final key =
          '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
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

  double get totalProductSalesValue =>
      _customers.fold(0.0, (sum, c) => sum + c.installmentPrice);

  double get totalCashCost =>
      _customers.fold(0.0, (sum, c) => sum + c.cashPrice);

  double get totalExpectedProfit {
    final profit = totalProductSalesValue - totalCashCost;
    return profit > 0 ? profit : 0.0;
  }

  double get totalDownPaymentCollected =>
      _customers.fold(0.0, (sum, c) => sum + c.downPayment);

  double get totalInstallmentCollectedAllTime =>
      _collections.fold(0.0, (sum, r) => sum + r.amount);

  double get totalCollectedAll =>
      totalDownPaymentCollected + totalInstallmentCollectedAllTime;

  double get totalOutstandingKisti {
    return _customers
        .where((c) => c.status != 'পরিশোধিত')
        .fold(0.0, (sum, c) => sum + c.remainingAmount);
  }

  double get todayCollected {
    final now = DateTime.now();
    return _collections
        .where((r) =>
            r.date.year == now.year &&
            r.date.month == now.month &&
            r.date.day == now.day)
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  double get todayTarget {
    return _customers
        .where((c) => c.status == 'চলমান' || c.status == 'বকেয়া')
        .fold(0.0, (sum, c) => sum + c.installmentAmount);
  }

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get todayExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get earnedGrossProfit {
    if (totalProductSalesValue <= 0) return 0.0;
    final collectionRatio = (totalCollectedAll / totalProductSalesValue).clamp(0.0, 1.0);
    return totalExpectedProfit * collectionRatio;
  }

  double get netProfit => earnedGrossProfit - totalExpenses;

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
