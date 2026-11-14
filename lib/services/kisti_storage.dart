import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/collection.dart';

class KistiStorage extends ChangeNotifier {
  static const String _keyCustomers = 'kisti_customers_v1';
  static const String _keyCollections = 'kisti_collections_v1';

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
        id: 'CUST-1001',
        name: 'মো: রফিকুল ইসলাম',
        phone: '01712-345678',
        address: 'দোকান নং ৪, কাঁচাবাজার, ঢাকা',
        nid: '1987542158963',
        principalAmount: 30000.0,
        interestRate: 10.0,
        totalPayable: 33000.0,
        installmentAmount: 1100.0,
        frequency: 'দৈনিক',
        totalInstallments: 30,
        paidInstallments: 18,
        totalPaid: 19800.0,
        startDate: now.subtract(const Duration(days: 20)),
        status: 'চলমান',
      ),
      Customer(
        id: 'CUST-1002',
        name: 'মোসাম্মৎ আয়েশা বেগম',
        phone: '01823-987654',
        address: 'হাউজ # ১২, রোড # ৩, মিরপুর-১০',
        nid: '2847592015843',
        principalAmount: 50000.0,
        interestRate: 12.0,
        totalPayable: 56000.0,
        installmentAmount: 2800.0,
        frequency: 'সাপ্তাহিক',
        totalInstallments: 20,
        paidInstallments: 9,
        totalPaid: 25200.0,
        startDate: now.subtract(const Duration(days: 65)),
        status: 'চলমান',
      ),
      Customer(
        id: 'CUST-1003',
        name: 'কামাল হোসেন টেলিকম',
        phone: '01934-567890',
        address: 'স্টেশন রোড, টঙ্গী',
        nid: '3948502918475',
        principalAmount: 20000.0,
        interestRate: 10.0,
        totalPayable: 22000.0,
        installmentAmount: 1000.0,
        frequency: 'দৈনিক',
        totalInstallments: 22,
        paidInstallments: 22,
        totalPaid: 22000.0,
        startDate: now.subtract(const Duration(days: 35)),
        status: 'পরিশোধিত',
      ),
      Customer(
        id: 'CUST-1004',
        name: 'জাহাঙ্গীর আলম',
        phone: '01655-123456',
        address: 'গাছা রোড, গাজীপুর',
        nid: '4839201847562',
        principalAmount: 40000.0,
        interestRate: 10.0,
        totalPayable: 44000.0,
        installmentAmount: 2200.0,
        frequency: 'সাপ্তাহিক',
        totalInstallments: 20,
        paidInstallments: 4,
        totalPaid: 8800.0,
        startDate: now.subtract(const Duration(days: 45)),
        status: 'বকেয়া',
      ),
      Customer(
        id: 'CUST-1005',
        name: 'সুলতানা রাজিয়া',
        phone: '01511-789012',
        address: 'ব্লক-সি, বনশ্রী, ঢাকা',
        nid: '5738201948572',
        principalAmount: 25000.0,
        interestRate: 10.0,
        totalPayable: 27500.0,
        installmentAmount: 1100.0,
        frequency: 'দৈনিক',
        totalInstallments: 25,
        paidInstallments: 12,
        totalPaid: 13200.0,
        startDate: now.subtract(const Duration(days: 14)),
        status: 'চলমান',
      ),
    ];

    _collections = [
      CollectionRecord(
        id: 'RCPT-901',
        customerId: 'CUST-1001',
        customerName: 'মো: রফিকুল ইসলাম',
        amount: 1100.0,
        date: now.subtract(const Duration(hours: 3)),
        installmentIndex: 18,
        paymentMethod: 'নগদ',
        collector: 'সজীব আহমেদ',
        receiptNo: 'REC-2026-001',
        note: 'নিয়মিত আদায়',
      ),
      CollectionRecord(
        id: 'RCPT-902',
        customerId: 'CUST-1005',
        customerName: 'সুলতানা রাজিয়া',
        amount: 1100.0,
        date: now.subtract(const Duration(hours: 5)),
        installmentIndex: 12,
        paymentMethod: 'বিকাশ',
        collector: 'সজীব আহমেদ',
        receiptNo: 'REC-2026-002',
        note: 'ডিজিটাল পেমেন্ট',
      ),
      CollectionRecord(
        id: 'RCPT-903',
        customerId: 'CUST-1002',
        customerName: 'মোসাম্মৎ আয়েশা বেগম',
        amount: 2800.0,
        date: now.subtract(const Duration(days: 1, hours: 2)),
        installmentIndex: 9,
        paymentMethod: 'নগদ',
        collector: 'সজীব আহমেদ',
        receiptNo: 'REC-2026-003',
        note: 'সাপ্তাহিক কিস্তি',
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
    String collector = 'অফিসার',
  }) async {
    final nextIndex = customer.paidInstallments + 1;
    final newPaid = customer.totalPaid + amount;
    final newPaidCount = customer.paidInstallments + 1;

    // Check if fully paid
    String newStatus = customer.status;
    if (newPaid >= customer.totalPayable || newPaidCount >= customer.totalInstallments) {
      newStatus = 'পরিশোধিত';
    } else if (customer.status == 'বকেয়া') {
      newStatus = 'চলমান';
    }

    customer.paidInstallments = newPaidCount;
    customer.totalPaid = newPaid;
    customer.status = newStatus;

    final receipt = CollectionRecord(
      id: 'COL-${DateTime.now().millisecondsSinceEpoch}',
      customerId: customer.id,
      customerName: customer.name,
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

  // --- Aggregation Metrics ---

  double get totalPrincipalDisbursed {
    return _customers.fold(0.0, (sum, c) => sum + c.principalAmount);
  }

  double get totalExpectedReceivable {
    return _customers.fold(0.0, (sum, c) => sum + c.totalPayable);
  }

  double get totalCollectedAllTime {
    return _collections.fold(0.0, (sum, r) => sum + r.amount);
  }

  double get totalOutstanding {
    return (totalExpectedReceivable - totalCollectedAllTime).clamp(0.0, double.infinity);
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
    // Sum of installment amounts for all active daily customers plus weekly due today
    return _customers
        .where((c) => c.status == 'চলমান' || c.status == 'বকেয়া')
        .fold(0.0, (sum, c) => sum + c.installmentAmount);
  }

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
    return _collections.where((c) => c.customerId == customerId).toList();
  }
}
