import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/collection.dart';

class KistiStorage extends ChangeNotifier {
  static const String _keyCustomers = 'kisti_product_sales_v3';
  static const String _keyCollections = 'kisti_product_collections_v3';

  List<Customer> _customers = [];
  List<CollectionRecord> _collections = [];
  bool _isLoaded = false;

  List<Customer> get customers => List.unmodifiable(_customers);
  List<CollectionRecord> get collections => List.unmodifiable(_collections);
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

    if (customersJson != null && collectionsJson != null) {
      try {
        final List<dynamic> custList = jsonDecode(customersJson);
        _customers = custList.map((e) => Customer.fromJson(e)).toList();

        final List<dynamic> colList = jsonDecode(collectionsJson);
        _collections = colList.map((e) => CollectionRecord.fromJson(e)).toList();
      } catch (e) {
        _customers = [];
        _collections = [];
      }
    } else {
      // Clean empty list - NO fake / dummy seed data!
      _customers = [];
      _collections = [];
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final customersJson = jsonEncode(_customers.map((c) => c.toJson()).toList());
    final collectionsJson = jsonEncode(_collections.map((c) => c.toJson()).toList());

    await prefs.setString(_keyCustomers, customersJson);
    await prefs.setString(_keyCollections, collectionsJson);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCustomers);
    await prefs.remove(_keyCollections);
    _customers = [];
    _collections = [];
    notifyListeners();
  }

  // --- CRUD Operations ---

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
