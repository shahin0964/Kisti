import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/kisti_storage.dart';
import '../theme/liquid_glass_theme.dart';
import '../widgets/liquid_glass.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  final KistiStorage storage;

  const CustomersScreen({super.key, required this.storage});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'সকল'; // 'সকল', 'মোবাইল', 'ফ্রিজ', 'টিভি', 'এসি', 'চলমান', 'বকেয়া'

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    return '৳ ${formatter.format(amount)}';
  }

  void _showAddSaleDialog() {
    final customerNameCtrl = TextEditingController();
    final customerPhoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final nidCtrl = TextEditingController();
    final guarantorNameCtrl = TextEditingController();
    final guarantorPhoneCtrl = TextEditingController();

    final productNameCtrl = TextEditingController();
    final modelImeiCtrl = TextEditingController();
    final cashPriceCtrl = TextEditingController(text: '40000');
    final installmentPriceCtrl = TextEditingController(text: '45000');
    final downPaymentCtrl = TextEditingController(text: '10000');
    final totalInstallmentsCtrl = TextEditingController(text: '10');

    String selectedCategory = 'মোবাইল'; // 'মোবাইল', 'ফ্রিজ', 'টিভি', 'এসি', 'বাইক', 'অন্যান্য'
    String frequency = 'মাসিক';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final installmentPrice = double.tryParse(installmentPriceCtrl.text) ?? 0.0;
            final downPayment = double.tryParse(downPaymentCtrl.text) ?? 0.0;
            final totalInst = int.tryParse(totalInstallmentsCtrl.text) ?? 1;
            final financedAmount = (installmentPrice - downPayment).clamp(0.0, installmentPrice);
            final instAmount = totalInst > 0 ? (financedAmount / totalInst).ceilToDouble() : 0.0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.90,
                ),
                child: LiquidGlassCard(
                  borderRadius: 28,
                  glowColor: LiquidGlassTheme.cyberCyan,
                  padding: const EdgeInsets.all(22),
                  margin: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.add_shopping_cart_rounded,
                                    color: LiquidGlassTheme.neonEmerald, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'নতুন পণ্য কিস্তিতে বিক্রয়',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Section 1: Product Information
                        const Text(
                          '১. পণ্যের বিবরণ',
                          style: TextStyle(
                            color: LiquidGlassTheme.cyberCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        LiquidTextField(
                          controller: productNameCtrl,
                          label: 'পণ্যের নাম (যেমন: Walton 250L Fridge, Samsung 43" TV)',
                          prefixIcon: Icons.devices_other_rounded,
                        ),

                        // Category Selector
                        const SizedBox(height: 4),
                        const Text(
                          'পণ্যের ক্যাটাগরি',
                          style: TextStyle(
                            color: LiquidGlassTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            'মোবাইল',
                            'ফ্রিজ',
                            'টিভি',
                            'এসি',
                            'অন্যান্য',
                          ].map((cat) {
                            final isSel = selectedCategory == cat;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setSheetState(() => selectedCategory = cat),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? LiquidGlassTheme.cyberCyan.withOpacity(0.25)
                                        : Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSel
                                          ? LiquidGlassTheme.cyberCyan
                                          : Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSel ? Colors.white : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 8),
                        LiquidTextField(
                          controller: modelImeiCtrl,
                          label: 'মডেল / সিরিয়াল / IMEI নম্বর',
                          prefixIcon: Icons.qr_code_2_rounded,
                        ),

                        const SizedBox(height: 14),

                        // Section 2: Pricing & Installment Calculation
                        const Text(
                          '২. দাম ও কিস্তির হিসাব',
                          style: TextStyle(
                            color: LiquidGlassTheme.neonEmerald,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: LiquidTextField(
                                controller: cashPriceCtrl,
                                label: 'নগদ মূল্য (Cash Price)',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.payments_outlined,
                                onChanged: (v) => setSheetState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LiquidTextField(
                                controller: installmentPriceCtrl,
                                label: 'কিস্তিতে মোট মূল্য',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.price_change_rounded,
                                onChanged: (v) => setSheetState(() {}),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: LiquidTextField(
                                controller: downPaymentCtrl,
                                label: 'ডাউন পেমেন্ট (অগ্রিম)',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.savings_rounded,
                                onChanged: (v) => setSheetState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LiquidTextField(
                                controller: totalInstallmentsCtrl,
                                label: 'কিস্তির সংখ্যা (মাস)',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.numbers_rounded,
                                onChanged: (v) => setSheetState(() {}),
                              ),
                            ),
                          ],
                        ),

                        // Dynamic Real-time Calculation Summary
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: LiquidGlassTheme.neonEmerald.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'বকেয়া কিস্তির আসল টাকা',
                                    style: TextStyle(
                                      color: LiquidGlassTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(financedAmount),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'প্রতি মাসের কিস্তি',
                                    style: TextStyle(
                                      color: LiquidGlassTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(instAmount),
                                    style: const TextStyle(
                                      color: LiquidGlassTheme.neonEmerald,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Section 3: Customer & Guarantor Info
                        const Text(
                          '৩. ক্রেতা ও জামিনদারের তথ্য',
                          style: TextStyle(
                            color: LiquidGlassTheme.amberGold,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        LiquidTextField(
                          controller: customerNameCtrl,
                          label: 'ক্রেতার পুরো নাম',
                          prefixIcon: Icons.person_rounded,
                        ),
                        LiquidTextField(
                          controller: customerPhoneCtrl,
                          label: 'ক্রেতার মোবাইল নম্বর',
                          prefixIcon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        LiquidTextField(
                          controller: addressCtrl,
                          label: 'ঠিকানা ও কর্মস্থল',
                          prefixIcon: Icons.location_on_rounded,
                        ),
                        LiquidTextField(
                          controller: nidCtrl,
                          label: 'ক্রেতার NID নম্বর',
                          prefixIcon: Icons.badge_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: LiquidTextField(
                                controller: guarantorNameCtrl,
                                label: 'জামিনদার / গ্যারান্টারের নাম',
                                prefixIcon: Icons.supervised_user_circle_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LiquidTextField(
                                controller: guarantorPhoneCtrl,
                                label: 'জামিনদারের মোবাইল',
                                prefixIcon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: LiquidButton(
                            text: 'পণ্য কিস্তিতে বিক্রয় নিশ্চিত করুন',
                            icon: Icons.check_circle_rounded,
                            onPressed: () async {
                              final custName = customerNameCtrl.text.trim();
                              final prodName = productNameCtrl.text.trim();

                              if (custName.isEmpty || prodName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ক্রেতা ও পণ্যের নাম উভয়ই পূরণ করুন'),
                                  ),
                                );
                                return;
                              }

                              final newSale = Customer(
                                id: 'SALE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                name: custName,
                                phone: customerPhoneCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                                nid: nidCtrl.text.trim(),
                                guarantorName: guarantorNameCtrl.text.trim(),
                                guarantorPhone: guarantorPhoneCtrl.text.trim(),
                                productName: prodName,
                                productCategory: selectedCategory,
                                modelOrImei: modelImeiCtrl.text.trim(),
                                cashPrice: double.tryParse(cashPriceCtrl.text) ?? 0.0,
                                installmentPrice: installmentPrice,
                                downPayment: downPayment,
                                installmentAmount: instAmount,
                                frequency: frequency,
                                totalInstallments: totalInst,
                                startDate: DateTime.now(),
                                status: 'চলমান',
                              );

                              await widget.storage.addCustomer(newSale);
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: LiquidGlassTheme.bgMidnight,
                                    content: Text(
                                      '$prodName ($custName)-এর কিস্তি বিক্রয় সফল হয়েছে!',
                                      style: const TextStyle(
                                        color: LiquidGlassTheme.neonEmerald,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase().trim();

    final filteredCustomers = widget.storage.customers.where((c) {
      final matchesQuery = query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.productName.toLowerCase().contains(query) ||
          c.phone.contains(query) ||
          c.productCategory.toLowerCase().contains(query) ||
          c.modelOrImei.toLowerCase().contains(query);

      bool matchesFilter = true;
      if (_selectedFilter == 'সকল') {
        matchesFilter = true;
      } else if (_selectedFilter == 'চলমান' ||
          _selectedFilter == 'বকেয়া' ||
          _selectedFilter == 'পরিশোধিত') {
        matchesFilter = c.status == _selectedFilter;
      } else {
        // Category filter
        matchesFilter = c.productCategory == _selectedFilter;
      }

      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Add Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'পণ্য বিক্রয় ও গ্রাহক খতিয়ান',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'মোট ${widget.storage.customers.length} টি পণ্য কিস্তিতে সরবরাহকৃত',
                        style: const TextStyle(
                          color: LiquidGlassTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  LiquidButton(
                    text: 'নতুন বিক্রয়',
                    icon: Icons.add_rounded,
                    height: 40,
                    onPressed: _showAddSaleDialog,
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: LiquidTextField(
                controller: _searchController,
                label: 'ক্রেতা, পণ্য (টিভি, ফ্রিজ, মোবাইল) বা IMEI দিয়ে খুঁজুন...',
                prefixIcon: Icons.search_rounded,
                suffix: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),

            // Filter Chips
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'সকল',
                  'মোবাইল',
                  'ফ্রিজ',
                  'টিভি',
                  'এসি',
                  'চলমান',
                  'বকেয়া',
                  'পরিশোধিত',
                ].map((f) {
                  final isSel = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          _selectedFilter = f;
                        });
                      },
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : Colors.white70,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      selectedColor: LiquidGlassTheme.cyberCyan,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      side: BorderSide(
                        color: isSel
                            ? LiquidGlassTheme.cyberCyan
                            : Colors.white.withOpacity(0.12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Product Installment Cards List
            Expanded(
              child: filteredCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: LiquidGlassTheme.textMuted,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'কোনো পণ্য বা গ্রাহক খুঁজে পাওয়া যায়নি',
                            style: TextStyle(color: LiquidGlassTheme.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final sale = filteredCustomers[index];

                        return LiquidGlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailScreen(
                                  customerId: sale.id,
                                  storage: widget.storage,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Product Category Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.08),
                                      border: Border.all(
                                        color: sale.status == 'বকেয়া'
                                            ? LiquidGlassTheme.sunsetCoral
                                            : LiquidGlassTheme.neonEmerald
                                                .withOpacity(0.7),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      sale.categoryIcon,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sale.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          sale.productName,
                                          style: const TextStyle(
                                            color: LiquidGlassTheme.neonEmerald,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (sale.modelOrImei.isNotEmpty)
                                          Text(
                                            sale.modelOrImei,
                                            style: const TextStyle(
                                              color: LiquidGlassTheme.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  LiquidBadge(
                                    label: sale.status,
                                    color: sale.status == 'পরিশোধিত'
                                        ? LiquidGlassTheme.neonEmerald
                                        : (sale.status == 'বকেয়া'
                                            ? LiquidGlassTheme.sunsetCoral
                                            : LiquidGlassTheme.amberGold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'কিস্তি মূল্য',
                                        style: TextStyle(
                                          color: LiquidGlassTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(sale.installmentPrice),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'ডাউন পেমেন্ট',
                                        style: TextStyle(
                                          color: LiquidGlassTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(sale.downPayment),
                                        style: const TextStyle(
                                          color: LiquidGlassTheme.cyberCyan,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'প্রতি কিস্তি',
                                        style: TextStyle(
                                          color: LiquidGlassTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(sale.installmentAmount),
                                        style: const TextStyle(
                                          color: LiquidGlassTheme.neonEmerald,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: sale.progressPercentage,
                                  minHeight: 6,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.08),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    sale.status == 'বকেয়া'
                                        ? LiquidGlassTheme.sunsetCoral
                                        : LiquidGlassTheme.neonEmerald,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'পরিশোধ: ${sale.paidInstallments}/${sale.totalInstallments} কিস্তি',
                                    style: const TextStyle(
                                      color: LiquidGlassTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    'বকেয়া কিস্তি: ${_formatCurrency(sale.remainingAmount)}',
                                    style: const TextStyle(
                                      color: LiquidGlassTheme.amberGold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
