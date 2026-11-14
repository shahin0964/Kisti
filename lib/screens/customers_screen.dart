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
  String _selectedFilter = 'সকল'; // 'সকল', 'চলমান', 'বকেয়া', 'পরিশোধিত'

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    return '৳ ${formatter.format(amount)}';
  }

  void _showAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final nidCtrl = TextEditingController();
    final principalCtrl = TextEditingController(text: '20000');
    final interestCtrl = TextEditingController(text: '10');
    final installmentsCtrl = TextEditingController(text: '20');

    String frequency = 'দৈনিক'; // 'দৈনিক', 'সাপ্তাহিক', 'মাসিক'

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final principal = double.tryParse(principalCtrl.text) ?? 0.0;
            final interest = double.tryParse(interestCtrl.text) ?? 0.0;
            final totalPayable = principal + (principal * (interest / 100));
            final totalInst = int.tryParse(installmentsCtrl.text) ?? 1;
            final instAmount = totalInst > 0 ? (totalPayable / totalInst).ceilToDouble() : 0.0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                            const Text(
                              'নতুন ঋণগ্রহীতা এন্ট্রি',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LiquidTextField(
                          controller: nameCtrl,
                          label: 'গ্রাহকের পুরো নাম',
                          prefixIcon: Icons.person_rounded,
                        ),
                        LiquidTextField(
                          controller: phoneCtrl,
                          label: 'মোবাইল নম্বর',
                          prefixIcon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        LiquidTextField(
                          controller: addressCtrl,
                          label: 'ঠিকানা / কর্মস্থল',
                          prefixIcon: Icons.location_on_rounded,
                        ),
                        LiquidTextField(
                          controller: nidCtrl,
                          label: 'জাতীয় পরিচয়পত্র নং (NID)',
                          prefixIcon: Icons.badge_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'কিস্তির ধরন (ফ্রিকোয়েন্সি)',
                          style: TextStyle(
                            color: LiquidGlassTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: ['দৈনিক', 'সাপ্তাহিক', 'মাসিক'].map((f) {
                            final isSel = frequency == f;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setSheetState(() => frequency = f),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? LiquidGlassTheme.cyberCyan.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSel
                                          ? LiquidGlassTheme.cyberCyan
                                          : Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    f,
                                    style: TextStyle(
                                      color: isSel
                                          ? LiquidGlassTheme.cyberCyan
                                          : Colors.white70,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: LiquidTextField(
                                controller: principalCtrl,
                                label: 'আসল ঋণ (টাকা)',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.attach_money_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LiquidTextField(
                                controller: interestCtrl,
                                label: 'লাভ/সুদ (%)',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.percent_rounded,
                              ),
                            ),
                          ],
                        ),
                        LiquidTextField(
                          controller: installmentsCtrl,
                          label: 'মোট কিস্তির সংখ্যা (উদা: ২০)',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.numbers_rounded,
                        ),
                        const SizedBox(height: 12),
                        // Realtime calculation preview card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: LiquidGlassTheme.cyberCyan.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'মোট প্রদেয় টাকা',
                                    style: TextStyle(
                                      color: LiquidGlassTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(totalPayable),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'প্রতি কিস্তির পরিমাণ',
                                    style: TextStyle(
                                      color: LiquidGlassTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(instAmount),
                                    style: const TextStyle(
                                      color: LiquidGlassTheme.neonEmerald,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: LiquidButton(
                            text: 'গ্রাহক সংরক্ষণ করুন',
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: () async {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('গ্রাহকের নাম লিখুন')),
                                );
                                return;
                              }

                              final newCustomer = Customer(
                                id: 'CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                name: name,
                                phone: phoneCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                                nid: nidCtrl.text.trim(),
                                principalAmount: principal,
                                interestRate: interest,
                                totalPayable: totalPayable,
                                installmentAmount: instAmount,
                                frequency: frequency,
                                totalInstallments: totalInst,
                                startDate: DateTime.now(),
                                status: 'চলমান',
                              );

                              await widget.storage.addCustomer(newCustomer);
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: LiquidGlassTheme.bgMidnight,
                                    content: Text(
                                      '$name-কে সফলভাবে যুক্ত করা হয়েছে!',
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
          c.phone.contains(query) ||
          c.id.toLowerCase().contains(query) ||
          c.address.toLowerCase().contains(query);

      final matchesFilter = _selectedFilter == 'সকল' || c.status == _selectedFilter;

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
                        'গ্রাহক তালিকা',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'মোট ${widget.storage.customers.length} জন গ্রাহক সক্রিয়',
                        style: const TextStyle(
                          color: LiquidGlassTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  LiquidButton(
                    text: 'নতুন গ্রাহক',
                    icon: Icons.add_rounded,
                    height: 40,
                    onPressed: _showAddCustomerDialog,
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: LiquidTextField(
                controller: _searchController,
                label: 'নাম, মোবাইল বা আইডি দিয়ে খুঁজুন...',
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
                children: ['সকল', 'চলমান', 'বকেয়া', 'পরিশোধিত'].map((f) {
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

            // Customer Cards List
            Expanded(
              child: filteredCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.person_search_rounded,
                            size: 48,
                            color: LiquidGlassTheme.textMuted,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'কোনো গ্রাহক খুঁজে পাওয়া যায়নি',
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
                        final customer = filteredCustomers[index];

                        return LiquidGlassCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailScreen(
                                  customerId: customer.id,
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
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.08),
                                      border: Border.all(
                                        color: customer.status == 'বকেয়া'
                                            ? LiquidGlassTheme.sunsetCoral
                                            : LiquidGlassTheme.neonEmerald
                                                .withOpacity(0.7),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      customer.name.isNotEmpty
                                          ? customer.name[0]
                                          : 'গ',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${customer.phone} • ${customer.frequency}',
                                          style: const TextStyle(
                                            color:
                                                LiquidGlassTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  LiquidBadge(
                                    label: customer.status,
                                    color: customer.status == 'পরিশোধিত'
                                        ? LiquidGlassTheme.neonEmerald
                                        : (customer.status == 'বকেয়া'
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
                                        'আসল ঋণ',
                                        style: TextStyle(
                                          color: LiquidGlassTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(
                                            customer.principalAmount),
                                        style: const TextStyle(
                                          color: Colors.white,
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
                                        'কিস্তির পরিমাণ',
                                        style: TextStyle(
                                          color: LiquidGlassTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(
                                            customer.installmentAmount),
                                        style: const TextStyle(
                                          color: LiquidGlassTheme.neonEmerald,
                                          fontSize: 14,
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
                                  value: customer.progressPercentage,
                                  minHeight: 6,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.08),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    customer.status == 'বকেয়া'
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
                                    'পরিশোধ: ${customer.paidInstallments}/${customer.totalInstallments} কিস্তি',
                                    style: const TextStyle(
                                      color: LiquidGlassTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    'অবশিষ্ট: ${_formatCurrency(customer.remainingAmount)}',
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
