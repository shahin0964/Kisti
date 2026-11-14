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
  String _selectedFilter = 'সকল';

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
    final categoryCtrl = TextEditingController();
    final modelImeiCtrl = TextEditingController();
    final cashPriceCtrl = TextEditingController();
    final installmentPriceCtrl = TextEditingController();
    final downPaymentCtrl = TextEditingController();
    final totalInstallmentsCtrl = TextEditingController(text: '10');
    String frequency = 'মাসিক';

    final existingCats = widget.storage.dynamicCategories;

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
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
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
                                    color: LiquidGlassTheme.neonEmerald, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'নতুন পণ্য কিস্তিতে বিক্রয়',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Section 1: Product Information
                        const Text(
                          '১. পণ্যের বিবরণ',
                          style: TextStyle(
                            color: LiquidGlassTheme.cyberCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        LiquidTextField(
                          controller: productNameCtrl,
                          label: 'পণ্যের নাম (যেকোনো পণ্য)',
                          hint: 'যেমন: Walton 250L Fridge, Samsung A55, ইত্যাদি',
                          prefixIcon: Icons.devices_other_rounded,
                        ),

                        // Dynamic Category Input Field (NO HARDCODING)
                        LiquidTextField(
                          controller: categoryCtrl,
                          label: 'ক্যাটাগরি / পণ্যের ধরন (ঐচ্ছিক)',
                          hint: 'যেমন: ফ্রিজ, মোবাইল, টিভি, বাইক, ফার্নিচার ইত্যাদি',
                          prefixIcon: Icons.category_rounded,
                        ),

                        if (existingCats.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: existingCats.map((cat) {
                              return ActionChip(
                                label: Text(cat),
                                labelStyle: const TextStyle(
                                  color: LiquidGlassTheme.cyberCyan,
                                  fontSize: 11,
                                ),
                                backgroundColor: Colors.white.withOpacity(0.06),
                                side: BorderSide(
                                  color: LiquidGlassTheme.cyberCyan.withOpacity(0.3),
                                ),
                                onPressed: () {
                                  setSheetState(() {
                                    categoryCtrl.text = cat;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],

                        LiquidTextField(
                          controller: modelImeiCtrl,
                          label: 'মডেল / IMEI / Serial (ঐচ্ছিক)',
                          prefixIcon: Icons.qr_code_2_rounded,
                        ),

                        const SizedBox(height: 12),

                        // Section 2: Pricing & Installment
                        const Text(
                          '২. বিক্রয় মূল্য ও কিস্তি হিসাব',
                          style: TextStyle(
                            color: LiquidGlassTheme.neonEmerald,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Expanded(
                              child: LiquidTextField(
                                controller: cashPriceCtrl,
                                label: 'নগদ মূল্য (টাকা)',
                                prefixIcon: Icons.sell_rounded,
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setSheetState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LiquidTextField(
                                controller: installmentPriceCtrl,
                                label: 'কিস্তিতে মোট মূল্য',
                                prefixIcon: Icons.price_change_rounded,
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setSheetState(() {});
                                },
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
                                prefixIcon: Icons.payments_rounded,
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setSheetState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LiquidTextField(
                                controller: totalInstallmentsCtrl,
                                label: 'মোট কিস্তির সংখ্যা',
                                prefixIcon: Icons.format_list_numbered_rounded,
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setSheetState(() {});
                                },
                              ),
                            ),
                          ],
                        ),

                        // Realtime calculated monthly installment badge
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: LiquidGlassTheme.neonEmerald.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
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
                                    'প্রতি কিস্তির পরিমাণ:',
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
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'বকেয়া কিস্তির টাকা:',
                                    style: TextStyle(
                                      color: LiquidGlassTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(financedAmount),
                                    style: const TextStyle(
                                      color: LiquidGlassTheme.cyberCyan,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Frequency Selector
                        Row(
                          children: ['মাসিক', 'সাপ্তাহিক', 'দৈনিক'].map((freq) {
                            final isSel = frequency == freq;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setSheetState(() => frequency = freq),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? LiquidGlassTheme.cyberCyan.withOpacity(0.2)
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
                                    freq,
                                    style: TextStyle(
                                      color: isSel
                                          ? LiquidGlassTheme.cyberCyan
                                          : Colors.white70,
                                      fontSize: 11,
                                      fontWeight:
                                          isSel ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 14),

                        // Section 3: Customer & Guarantor
                        const Text(
                          '৩. ক্রেতা ও জামিনদারের তথ্য',
                          style: TextStyle(
                            color: LiquidGlassTheme.amberGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

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
                          label: 'ঠিকানা ও কর্মস্থল (ঐচ্ছিক)',
                          prefixIcon: Icons.location_on_rounded,
                        ),
                        LiquidTextField(
                          controller: nidCtrl,
                          label: 'ক্রেতার NID নম্বর (ঐচ্ছিক)',
                          prefixIcon: Icons.badge_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: LiquidTextField(
                                controller: guarantorNameCtrl,
                                label: 'জামিনদার নাম (ঐচ্ছিক)',
                                prefixIcon: Icons.supervised_user_circle_rounded,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LiquidTextField(
                                controller: guarantorPhoneCtrl,
                                label: 'জামিনদার মোবাইল',
                                prefixIcon: Icons.phone_android_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

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

                              final cat = categoryCtrl.text.trim().isNotEmpty
                                  ? categoryCtrl.text.trim()
                                  : 'পণ্য';

                              final newSale = Customer(
                                id: 'SALE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                name: custName,
                                phone: customerPhoneCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                                nid: nidCtrl.text.trim(),
                                guarantorName: guarantorNameCtrl.text.trim(),
                                guarantorPhone: guarantorPhoneCtrl.text.trim(),
                                productName: prodName,
                                productCategory: cat,
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
        // Dynamic Category filter
        matchesFilter = c.productCategory == _selectedFilter;
      }

      return matchesQuery && matchesFilter;
    }).toList();

    // Dynamic Filter Chip list (NO HARDCODING)
    final filterOptions = [
      'সকল',
      'চলমান',
      'বকেয়া',
      'পরিশোধিত',
      ...widget.storage.dynamicCategories,
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Safe Header: Title + Add Button that never overflows
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'পণ্য বিক্রয় খতিয়ান',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'মোট ${widget.storage.customers.length} টি পণ্য সরবরাহ',
                          style: const TextStyle(
                            color: LiquidGlassTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _showAddSaleDialog,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: LiquidGlassTheme.neonEmerald.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: LiquidGlassTheme.neonEmerald,
                          width: 1.2,
                        ),
                        boxShadow: LiquidGlassTheme.neonGlow(
                          LiquidGlassTheme.neonEmerald,
                          intensity: 0.25,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add_rounded, color: LiquidGlassTheme.neonEmerald, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'নতুন বিক্রয়',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: LiquidTextField(
                controller: _searchController,
                label: 'ক্রেতা, পণ্য বা IMEI দিয়ে খুঁজুন...',
                prefixIcon: Icons.search_rounded,
                onChanged: (val) => setState(() {}),
                suffix: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),

            // Filter Chips (Dynamic, non-hardcoded)
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filterOptions.length,
                itemBuilder: (context, idx) {
                  final f = filterOptions[idx];
                  final isSel = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
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
                        fontSize: 11,
                      ),
                      selectedColor: LiquidGlassTheme.cyberCyan,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      side: BorderSide(
                        color: isSel
                            ? LiquidGlassTheme.cyberCyan
                            : Colors.white.withOpacity(0.10),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            // Customers / Product Sales List
            Expanded(
              child: filteredCustomers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'কোনো বিক্রয় রেকর্ড পাওয়া যায়নি',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'উপরের "নতুন বিক্রয়" বাটনে চাপ দিয়ে পণ্য কিস্তি যোগ করুন',
                              style: TextStyle(
                                color: LiquidGlassTheme.textMuted,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, idx) {
                        final customer = filteredCustomers[idx];
                        return _buildCustomerCard(customer);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    Color statusColor;
    if (customer.status == 'পরিশোধিত') {
      statusColor = LiquidGlassTheme.neonEmerald;
    } else if (customer.status == 'বকেয়া') {
      statusColor = LiquidGlassTheme.sunsetCoral;
    } else {
      statusColor = LiquidGlassTheme.amberGold;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailScreen(
                customerId: customer.id,
                storage: widget.storage,
              ),
            ),
          );
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
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    customer.categoryIcon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.productName,
                        style: const TextStyle(
                          color: LiquidGlassTheme.cyberCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (customer.modelOrImei.isNotEmpty)
                        Text(
                          customer.modelOrImei,
                          style: const TextStyle(
                            color: LiquidGlassTheme.textMuted,
                            fontSize: 10.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                LiquidBadge(
                  label: customer.status,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCol('কিস্তি মূল্য', _formatCurrency(customer.installmentPrice)),
                _buildInfoCol('ডাউন পেমেন্ট', _formatCurrency(customer.downPayment)),
                _buildInfoCol('প্রতি কিস্তি', _formatCurrency(customer.installmentAmount),
                    color: LiquidGlassTheme.neonEmerald),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: customer.progressPercentage,
                minHeight: 5,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  customer.isFullyPaid
                      ? LiquidGlassTheme.neonEmerald
                      : LiquidGlassTheme.cyberCyan,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'পরিশোধ: ${customer.paidInstallments}/${customer.totalInstallments} কিস্তি',
                  style: const TextStyle(
                    color: LiquidGlassTheme.textMuted,
                    fontSize: 10.5,
                  ),
                ),
                Text(
                  'বকেয়া কিস্তি: ${_formatCurrency(customer.remainingAmount)}',
                  style: const TextStyle(
                    color: LiquidGlassTheme.sunsetCoral,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: LiquidGlassTheme.textMuted,
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
