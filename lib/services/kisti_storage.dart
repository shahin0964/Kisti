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

  // Business Profile Keys
  static const String _keyProprietorName = 'kisti_proprietor_name';
  static const String _keyShopPhone = 'kisti_shop_phone';
  static const String _keyShopAddress = 'kisti_shop_address';
  static const String _keyTradeLicense = 'kisti_trade_license';
  static const String _keyShopSlogan = 'kisti_shop_slogan';

  // Auto SMS Configuration Keys
  static const String _keySmsSimSlot = 'kisti_sms_sim_slot';
  static const String _keySmsOnCollection = 'kisti_sms_on_collection';
  static const String _keySmsNotice1Days = 'kisti_sms_notice_1_days';
  static const String _keySmsNotice2Days = 'kisti_sms_notice_2_days';

  List<Customer> _customers = [];
  List<CollectionRecord> _collections = [];
  List<Expense> _expenses = [];
  bool _isLoaded = false;
  bool _isAutoBackupEnabled = true;
  DateTime? _lastAutoBackupTime;

  // Business Info State
  String _shopName = 'কিস্তি সেবা শো-রুম';
  String _proprietorName = 'মোঃ শাহিন আলম';
  String _shopPhone = '01700000000';
  String _shopAddress = 'মিরপুর, ঢাকা - ১২১৬';
  String _tradeLicense = 'TRD-2026/0964';
  String _shopSlogan = 'সহজ কিস্তিতে বিশ্বস্ত পণ্য বিক্রয় সেবা';

  // Auto SMS State
  bool _isAutoSmsEnabled = true;
  String _smsSimSlot = 'সিম ১ (SIM 1)';
  bool _smsOnCollection = true;
  int _smsNotice1Days = 3;
  int _smsNotice2Days = 1;

  List<Customer> get customers => List.unmodifiable(_customers);
  List<CollectionRecord> get collections => List.unmodifiable(_collections);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoaded => _isLoaded;
  bool get isAutoBackupEnabled => _isAutoBackupEnabled;
  DateTime? get lastAutoBackupTime => _lastAutoBackupTime;

  // Business Info Getters
  String get shopName => _shopName;
  String get proprietorName => _proprietorName;
  String get shopPhone => _shopPhone;
  String get shopAddress => _shopAddress;
  String get tradeLicense => _tradeLicense;
  String get shopSlogan => _shopSlogan;

  // Auto SMS Getters
  bool get isAutoSmsEnabled => _isAutoSmsEnabled;
  String get smsSimSlot => _smsSimSlot;
  bool get smsOnCollection => _smsOnCollection;
  int get smsNotice1Days => _smsNotice1Days;
  int get smsNotice2Days => _smsNotice2Days;

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

    // Load Backup State
    _isAutoBackupEnabled = prefs.getBool(_keyAutoBackupEnabled) ?? true;
    final lastBackupStr = prefs.getString(_keyLastAutoBackupTime);
    if (lastBackupStr != null) {
      _lastAutoBackupTime = DateTime.tryParse(lastBackupStr);
    }

    // Load Business Info
    _shopName = prefs.getString(_keyShopName) ?? 'কিস্তি সেবা শো-রুম';
    _proprietorName = prefs.getString(_keyProprietorName) ?? 'মোঃ শাহিন আলম';
    _shopPhone = prefs.getString(_keyShopPhone) ?? '01700000000';
    _shopAddress = prefs.getString(_keyShopAddress) ?? 'মিরপুর, ঢাকা - ১২১৬';
    _tradeLicense = prefs.getString(_keyTradeLicense) ?? 'TRD-2026/0964';
    _shopSlogan = prefs.getString(_keyShopSlogan) ?? 'সহজ কিস্তিতে বিশ্বস্ত পণ্য বিক্রয় সেবা';

    // Load Auto SMS State
    _isAutoSmsEnabled = prefs.getBool(_keyAutoSmsEnabled) ?? true;
    _smsSimSlot = prefs.getString(_keySmsSimSlot) ?? 'সিম ১ (SIM 1)';
    _smsOnCollection = prefs.getBool(_keySmsOnCollection) ?? true;
    _smsNotice1Days = prefs.getInt(_keySmsNotice1Days) ?? 3;
    _smsNotice2Days = prefs.getInt(_keySmsNotice2Days) ?? 1;

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

  // --- Business Information Settings ---

  Future<void> updateBusinessInfo({
    required String name,
    required String proprietor,
    required String phone,
    required String address,
    String tradeLicense = '',
    String slogan = '',
  }) async {
    _shopName = name;
    _proprietorName = proprietor;
    _shopPhone = phone;
    _shopAddress = address;
    _tradeLicense = tradeLicense;
    _shopSlogan = slogan;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyShopName, name);
    await prefs.setString(_keyProprietorName, proprietor);
    await prefs.setString(_keyShopPhone, phone);
    await prefs.setString(_keyShopAddress, address);
    await prefs.setString(_keyTradeLicense, tradeLicense);
    await prefs.setString(_keyShopSlogan, slogan);
    notifyListeners();
  }

  // --- Auto SMS Configuration Settings ---

  Future<void> setAutoSmsEnabled(bool enabled) async {
    _isAutoSmsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoSmsEnabled, enabled);
    notifyListeners();
  }

  Future<void> setSmsSimSlot(String sim) async {
    _smsSimSlot = sim;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySmsSimSlot, sim);
    notifyListeners();
  }

  Future<void> setSmsOnCollection(bool value) async {
    _smsOnCollection = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySmsOnCollection, value);
    notifyListeners();
  }

  Future<void> setSmsNoticeDays({required int firstNoticeDays, required int secondNoticeDays}) async {
    _smsNotice1Days = firstNoticeDays;
    _smsNotice2Days = secondNoticeDays;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySmsNotice1Days, firstNoticeDays);
    await prefs.setInt(_keySmsNotice2Days, secondNoticeDays);
    notifyListeners();
  }

  // --- Offline Auto Backup (11:30 PM Daily) ---

  Future<void> setAutoBackupEnabled(bool enabled) async {
    _isAutoBackupEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoBackupEnabled, enabled);
    notifyListeners();
  }

  Future<String> createOfflineBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final backupPayload = {
      'version': '1.0.5',
      'backupTimestamp': now.toIso8601String(),
      'type': 'offline_auto_backup',
      'business': {
        'shopName': _shopName,
        'proprietor': _proprietorName,
        'phone': _shopPhone,
        'address': _shopAddress,
      },
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
