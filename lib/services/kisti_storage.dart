import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/collection.dart';

class KistiStorage extends ChangeNotifier {
  static const String _keyCustomers = 'kisti_product_sales_v2';
  static const String _keyCollections = 'kisti_product_collections_v2';

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
    final customersJson = prefs.getString(_keyCustomers);
    final collectionsJson = prefs.getString(_keyCollections);

    if (customersJson != null && collectionsJson != null) {
      try {
        final List<dynamic> custList = jsonDecode(customersJson);
        _customers = custList.map((e) => Customer.fromJson(e)).toList();

        final List<dynamic> colList = jsonDecode(collectionsJson);
        _collections = colList.map((e) => CollectionRecord.fromJson(e)).toList();
      } catch (e) {
        _seedInitialData();
      }
    } else {
      _seedInitialData();
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

  void _seedInitialData() {
    final now = DateTime.now();

    _customers = [
      Customer(
        id: 'SALE-101',
        name: 'মো: রফিকুল ইসলাম',
        phone: '01712-345678',
        address: 'দোকান নং ৪, বাজার রোড, মিরপুর-১০',
        nid: '1987542158963',
        guarantorName: 'মো: হাসেম আলী (ভাই)',
        guarantorPhone: '01799-887766',
        productName: 'ওয়ালটন ইনভার্টার রেফ্রিজারেটর ২৫০ লিটার',
        productCategory: 'ফ্রিজ',
        modelOrImei: 'WRE-250-INV-BL',
        cashPrice: 38000.0,
        installmentPrice: 42000.0,
        downPayment: 12000.0,
        installmentAmount: 5000.0,
        frequency: 'মাসিক',
        totalInstallments: 6,
        paidInstallments: 3,
        totalInstallmentPaid: 15000.0,
        startDate: now.subtract(const Duration(days: 90)),
        status: 'চলমান',
      ),
      Customer(
        id: 'SALE-102',
        name: 'মোসাম্মৎ আয়েশা বেগম',
        phone: '01823-987654',
        address: 'হাউজ # ১২, রোড # ৩, উত্তরা, ঢাকা',
        nid: '2847592015843',
        guarantorName: 'মো: কবির হোসেন (স্বামী)',
        guarantorPhone: '01811-223344',
        productName: 'স্যামসাং গ্যালাক্সি A55 5G (8/128GB)',
        productCategory: 'মোবাইল',
        modelOrImei: 'IMEI: 358492018475921',
        cashPrice: 46000.0,
        installmentPrice: 50000.0,
        downPayment: 14000.0,
        installmentAmount: 3000.0,
        frequency: 'মাসিক',
        totalInstallments: 12,
        paidInstallments: 5,
        totalInstallmentPaid: 15000.0,
        startDate: now.subtract(const Duration(days: 150)),
        status: 'চলমান',
      ),
      Customer(
        id: 'SALE-103',
        name: 'তানভীর হাসান',
        phone: '01934-567890',
        address: 'স্টেশন রোড, টঙ্গী, গাজীপুর',
        nid: '3948502918475',
        guarantorName: 'শফিকুল ইসলাম (বাবা)',
        guarantorPhone: '01922-334455',
        productName: 'সনি ব্রাভিয়া ৪৩ ইঞ্চি ৪কে গুগল টিভি',
        productCategory: 'টিভি',
        modelOrImei: 'KD-43X75K-SN982',
        cashPrice: 52000.0,
        installmentPrice: 58000.0,
        downPayment: 18000.0,
        installmentAmount: 4000.0,
        frequency: 'মাসিক',
        totalInstallments: 10,
        paidInstallments: 10,
        totalInstallmentPaid: 40000.0,
        startDate: now.subtract(const Duration(days: 300)),
        status: 'পরিশোধিত',
      ),
      Customer(
        id: 'SALE-104',
        name: 'জাহাঙ্গীর আলম',
        phone: '01655-123456',
        address: 'গাছা রোড, গাজীপুর',
        nid: '4839201847562',
        guarantorName: 'মো: বাবুল মিয়া (চাচা)',
        guarantorPhone: '01633-445566',
        productName: 'গ্রী ১.৫ টন ইনভার্টার স্প্লিট এসি',
        productCategory: 'এসি',
        modelOrImei: 'GS-18XPUV32',
        cashPrice: 65000.0,
        installmentPrice: 72000.0,
        downPayment: 20000.0,
        installmentAmount: 6500.0,
        frequency: 'মাসিক',
        totalInstallments: 8,
        paidInstallments: 2,
        totalInstallmentPaid: 13000.0,
        startDate: now.subtract(const Duration(days: 120)),
        status: 'বকেয়া',
      ),
      Customer(
        id: 'SALE-105',
        name: 'সুলতানা রাজিয়া',
        phone: '01511-789012',
        address: 'ব্লক-সি, বনশ্রী, রামপুরা, ঢাকা',
        nid: '5738201948572',
        guarantorName: 'মো: আলমগীর (ভাই)',
        guarantorPhone: '01533-556677',
        productName: 'রিয়েলমি ১২ প্রো প্লাস (12/256GB)',
        productCategory: 'মোবাইল',
        modelOrImei: 'IMEI: 864920184756214',
        cashPrice: 42000.0,
        installmentPrice: 46000.0,
        downPayment: 16000.0,
        installmentAmount: 3000.0,
        frequency: 'মাসিক',
        totalInstallments: 10,
        paidInstallments: 4,
        totalInstallmentPaid: 12000.0,
        startDate: now.subtract(const Duration(days: 120)),
        status: 'চলমান',
      ),
    ];

    _collections = [
      CollectionRecord(
        id: 'RCPT-201',
        customerId: 'SALE-101',
        customerName: 'মো: রফিকুল ইসলাম',
        productName: 'ওয়ালটন ইনভার্টার রেফ্রিজারেটর ২৫০ লিটার',
        amount: 5000.0,
        date: now.subtract(const Duration(hours: 2)),
        installmentIndex: 3,
        paymentMethod: 'নগদ',
        collector: 'সজীব আহমেদ',
        receiptNo: 'INV-2026-001',
        note: '৩য় কিস্তি আদায়',
      ),
      CollectionRecord(
        id: 'RCPT-202',
        customerId: 'SALE-102',
        customerName: 'মোসাম্মৎ আয়েশা বেগম',
        productName: 'স্যামসাং গ্যালাক্সি A55 5G',
        amount: 3000.0,
        date: now.subtract(const Duration(hours: 6)),
        installmentIndex: 5,
        paymentMethod: 'বিকাশ',
        collector: 'সজীব আহমেদ',
        receiptNo: 'INV-2026-002',
        note: 'বিকাশ পেমেন্ট',
      ),
      CollectionRecord(
        id: 'RCPT-203',
        customerId: 'SALE-105',
        customerName: 'সুলতানা রাজিয়া',
        productName: 'রিয়েলমি ১২ প্রো প্লাস',
        amount: 3000.0,
        date: now.subtract(const Duration(days: 1)),
        installmentIndex: 4,
        paymentMethod: 'নগদ',
        collector: 'সজীব আহমেদ',
        receiptNo: 'INV-2026-003',
        note: '৪র্থ কিস্তি আদায়',
      ),
    ];

    _saveData();
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

  // --- Financial & Product Metrics ---

  // মোট পণ্যের কিস্তি বিক্রয় মূল্য
  double get totalProductSalesValue =>
      _customers.fold(0.0, (sum, c) => sum + c.installmentPrice);

  // মোট ডাউন পেমেন্ট আদায়
  double get totalDownPaymentCollected =>
      _customers.fold(0.0, (sum, c) => sum + c.downPayment);

  // মোট কিস্তি আদায়
  double get totalInstallmentCollectedAllTime =>
      _collections.fold(0.0, (sum, r) => sum + r.amount);

  // মোট আদায়কৃত (ডাউন পেমেন্ট + কিস্তি)
  double get totalCollectedAll =>
      totalDownPaymentCollected + totalInstallmentCollectedAllTime;

  // বর্তমান পণ্যের মোট বকেয়া কিস্তি
  double get totalOutstandingKisti {
    return _customers
        .where((c) => c.status != 'পরিশোধিত')
        .fold(0.0, (sum, c) => sum + c.remainingAmount);
  }

  // আজকের কিস্তি আদায়
  double get todayCollected {
    final now = DateTime.now();
    return _collections
        .where((r) =>
            r.date.year == now.year &&
            r.date.month == now.month &&
            r.date.day == now.day)
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  // আজকের কিস্তির লক্ষ্যমাত্রা
  double get todayTarget {
    return _customers
        .where((c) => c.status == 'চলমান' || c.status == 'বকেয়া')
        .fold(0.0, (sum, c) => sum + c.installmentAmount);
  }

  int get totalProductsSoldCount => _customers.length;
  int get activeCustomersCount => _customers.where((c) => c.status == 'চলমান').length;
  int get overdueCustomersCount => _customers.where((c) => c.status == 'বকেয়া').length;
  int get completedCustomersCount => _customers.where((c) => c.status == 'পরিশোধিত').length;

  int get mobileCount => _customers.where((c) => c.productCategory == 'মোবাইল').length;
  int get fridgeCount => _customers.where((c) => c.productCategory == 'ফ্রিজ').length;
  int get tvCount => _customers.where((c) => c.productCategory == 'টিভি').length;
  int get acCount => _customers.where((c) => c.productCategory == 'এসি').length;

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
    return _collections.where((c) => c.customerId == customerId).toList();
  }
}
