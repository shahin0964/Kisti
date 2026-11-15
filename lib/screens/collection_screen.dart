import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/collection.dart';
import '../models/expense.dart';
import '../services/kisti_storage.dart';
import '../theme/liquid_glass_theme.dart';
import '../widgets/liquid_glass.dart';

class CollectionScreen extends StatefulWidget {
  final KistiStorage storage;
  final Customer? preselectedCustomer;

  const CollectionScreen({
    super.key,
    required this.storage,
    this.preselectedCustomer,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int _activeSegment = 0; // 0: ওভারভিউ ও লাভ-ক্ষতি, 1: দৈনিক আদায় খতিয়ান, 2: দোকান খরচ
  String _historyFilter = 'সকল'; // 'সকল', 'আজ', 'এই সপ্তাহ', 'এই মাস'
  String _expenseFilter = 'সকল';

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCustomer != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCollectSheet(preselected: widget.preselectedCustomer);
      });
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    return '৳ ${formatter.format(amount)}';
  }

  // --- Quick Collect Sheet ---
  void _showCollectSheet({Customer? preselected}) {
    Customer? selected = preselected;
    if (selected == null) {
      final active = widget.storage.customers.where((c) => !c.isFullyPaid).toList();
      if (active.isNotEmpty) {
        selected = active.first;
      }
    }

    final amountController = TextEditingController(
      text: selected != null ? selected.installmentAmount.toInt().toString() : '',
    );
    final noteController = TextEditingController();
    final collectorController = TextEditingController(text: 'শোরুম ম্যানেজার');
    String paymentMethod = 'নগদ';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final activeCustomers = widget.storage.customers.where((c) => !c.isFullyPaid).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetCtx).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: LiquidGlassTheme.bgDarkVoid.withOpacity(0.96),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: LiquidGlassTheme.neonEmerald.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: LiquidGlassTheme.neonEmerald.withOpacity(0.2),
                              border: Border.all(color: LiquidGlassTheme.neonEmerald),
                            ),
                            child: const Icon(
                              Icons.add_card_rounded,
                              color: LiquidGlassTheme.neonEmerald,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'কিস্তি আদায় গ্রহণ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'আদায় এন্ট্রি করুন ও রশিদ তৈরি করুন',
                                style: TextStyle(
                                  color: LiquidGlassTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (activeCustomers.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'বর্তমানে কোনো চলমান কিস্তি গ্রাহক নেই।\nপ্রথমে গ্রাহক যোগ করুন।',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: LiquidGlassTheme.textMuted),
                            ),
                          ),
                        )
                      else ...[
                        const Text(
                          'গ্রাহক ও পণ্য নির্বাচন করুন *',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.12)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selected?.id,
                              isExpanded: true,
                              dropdownColor: LiquidGlassTheme.bgSurfaceElevated,
                              icon: const Icon(Icons.arrow_drop_down, color: LiquidGlassTheme.neonEmerald),
                              items: activeCustomers.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c.id,
                                  child: Text(
                                    '${c.name} • ${c.productName} (বকেয়া: ${_formatCurrency(c.remainingAmount)})',
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final found = activeCustomers.firstWhere((c) => c.id == val);
                                  setSheetState(() {
                                    selected = found;
                                    amountController.text = found.installmentAmount.toInt().toString();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Amount
                        const Text(
                          'আদায়ের পরিমাণ (টাকা) *',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: LiquidGlassTheme.neonEmerald,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.currency_lira_rounded, color: LiquidGlassTheme.neonEmerald),
                            hintText: '০.০০',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: LiquidGlassTheme.neonEmerald),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Payment Method Chips
                        const Text(
                          'পেমেন্ট মাধ্যম',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: ['নগদ', 'বিকাশ', 'নগদ-অ্যাপ', 'রকেট', 'ব্যাংক'].map((m) {
                            final isSel = paymentMethod == m;
                            return ChoiceChip(
                              label: Text(m),
                              selected: isSel,
                              selectedColor: LiquidGlassTheme.neonEmerald.withOpacity(0.25),
                              backgroundColor: Colors.white.withOpacity(0.04),
                              labelStyle: TextStyle(
                                color: isSel ? LiquidGlassTheme.neonEmerald : Colors.white70,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: isSel ? LiquidGlassTheme.neonEmerald : Colors.white.withOpacity(0.1),
                              ),
                              onSelected: (_) => setSheetState(() => paymentMethod = m),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Collector
                        const Text(
                          'আদায়কারী / প্রতিনিধি',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: collectorController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_rounded, color: Colors.white54, size: 20),
                            hintText: 'ম্যানেজার বা ক্যাশিয়ারের নাম',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Note
                        const Text(
                          'মন্তব্য (ঐচ্ছিক)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: noteController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.edit_note_rounded, color: Colors.white54, size: 20),
                            hintText: 'যেমন: সময়মতো পরিশোধ করেছেন',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: LiquidGlassButton(
                            text: 'কিস্তি জমা করুন ও রসিদ তৈরি করুন',
                            icon: Icons.check_circle_rounded,
                            glowColor: LiquidGlassTheme.neonEmerald,
                            onPressed: () async {
                              final amt = double.tryParse(amountController.text) ?? 0.0;
                              if (selected == null || amt <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('সঠিক পরিমাণ ও গ্রাহক নির্বাচন করুন'),
                                    backgroundColor: LiquidGlassTheme.sunsetAmber,
                                  ),
                                );
                                return;
                              }

                              final nav = Navigator.of(sheetCtx);
                              final rec = await widget.storage.recordCollection(
                                customer: selected!,
                                amount: amt,
                                paymentMethod: paymentMethod,
                                collector: collectorController.text.trim().isEmpty
                                    ? 'শোরুম ক্যাশিয়ার'
                                    : collectorController.text.trim(),
                                note: noteController.text.trim(),
                              );

                              nav.pop();
                              if (!mounted) return;
                              _showReceiptDialog(rec, selected!);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Add Expense Sheet ---
  void _showAddExpenseSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String category = 'দোকান ভাড়া';

    final categories = [
      'দোকান ভাড়া',
      'বিদ্যুৎ বিল',
      'কর্মচারীর বেতন',
      'পরিবহন',
      'নাস্তা ও আপ্যায়ন',
      'মেরামত ও সার্ভিসিং',
      'বিজ্ঞাপন ও প্রচারণা',
      'বিবিধ খরচ',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: LiquidGlassTheme.bgDarkVoid.withOpacity(0.96),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(
                    color: LiquidGlassTheme.sunsetAmber.withOpacity(0.4),
                    width: 1.2,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: LiquidGlassTheme.sunsetAmber.withOpacity(0.2),
                              border: Border.all(color: LiquidGlassTheme.sunsetAmber),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: LiquidGlassTheme.sunsetAmber,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'নতুন দোকান খরচ যোগ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'দোকানের যাবতীয় ব্যয়ের নির্ভুল হিসাব',
                                style: TextStyle(
                                  color: LiquidGlassTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'খরচের বিবরণ / নাম *',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'যেমন: চলতি মাসের দোকান ভাড়া, কর্মচারীর বেতন...',
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category
                      const Text(
                        'খরচের খাত / ক্যাটাগরি',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((cat) {
                          final isSel = category == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSel,
                            selectedColor: LiquidGlassTheme.sunsetAmber.withOpacity(0.25),
                            backgroundColor: Colors.white.withOpacity(0.04),
                            labelStyle: TextStyle(
                              color: isSel ? LiquidGlassTheme.sunsetAmber : Colors.white70,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                            side: BorderSide(
                              color: isSel ? LiquidGlassTheme.sunsetAmber : Colors.white.withOpacity(0.1),
                            ),
                            onSelected: (_) => setSheetState(() => category = cat),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Amount
                      const Text(
                        'খরচের পরিমাণ (টাকা) *',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: LiquidGlassTheme.sunsetAmber,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.currency_lira_rounded, color: LiquidGlassTheme.sunsetAmber),
                          hintText: '০.০০',
                          hintStyle: const TextStyle(color: Colors.white30),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Note
                      const Text(
                        'অতিরিক্ত নোট (ঐচ্ছিক)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'যেমন: নগদ টাকা পরিশোধিত বা ভাউচার নম্বর...',
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Expense
                      SizedBox(
                        width: double.infinity,
                        child: LiquidGlassButton(
                          text: 'খরচ সংরক্ষণ করুন',
                          icon: Icons.save_rounded,
                          glowColor: LiquidGlassTheme.sunsetAmber,
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final amt = double.tryParse(amountController.text) ?? 0.0;
                            if (title.isEmpty || amt <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('খরচের বিবরণ ও সঠিক টাকার অঙ্ক দিন'),
                                  backgroundColor: LiquidGlassTheme.sunsetAmber,
                                ),
                              );
                              return;
                            }

                            final nav = Navigator.of(sheetCtx);
                            final expense = Expense(
                              id: 'EXP-${DateTime.now().millisecondsSinceEpoch}',
                              title: title,
                              category: category,
                              amount: amt,
                              date: DateTime.now(),
                              note: noteController.text.trim(),
                            );

                            await widget.storage.addExpense(expense);
                            nav.pop();

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('খরচ যুক্ত হয়েছে: $title - ${_formatCurrency(amt)}'),
                                backgroundColor: LiquidGlassTheme.sunsetAmber,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Receipt Dialog ---
  void _showReceiptDialog(CollectionRecord record, Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: LiquidGlassCard(
            borderRadius: 24,
            glowColor: LiquidGlassTheme.neonEmerald,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LiquidGlassTheme.neonEmerald.withOpacity(0.2),
                    border: Border.all(color: LiquidGlassTheme.neonEmerald),
                    boxShadow: LiquidGlassTheme.neonGlow(LiquidGlassTheme.neonEmerald),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: LiquidGlassTheme.neonEmerald,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'কিস্তি আদায় স্লিপ তৈরি হয়েছে!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.receiptNo,
                  style: const TextStyle(
                    color: LiquidGlassTheme.cyberCyan,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      _buildReceiptRow('ক্রেতার নাম:', record.customerName),
                      const SizedBox(height: 8),
                      _buildReceiptRow('বিক্রীত পণ্য:', record.productName.isNotEmpty ? record.productName : customer.productName),
                      const SizedBox(height: 8),
                      _buildReceiptRow('কিস্তির কিস্তি নং:', '${record.installmentIndex}তম কিস্তি'),
                      const SizedBox(height: 8),
                      _buildReceiptRow('পরিশোধের মাধ্যম:', record.paymentMethod),
                      const SizedBox(height: 8),
                      _buildReceiptRow('আদায়কারী:', record.collector),
                      const SizedBox(height: 8),
                      _buildReceiptRow(
                        'তারিখ ও সময়:',
                        DateFormat('dd MMM yyyy, hh:mm a').format(record.date),
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'আদায়কৃত টাকা:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatCurrency(record.amount),
                            style: const TextStyle(
                              color: LiquidGlassTheme.neonEmerald,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'অবশিষ্ট বকেয়া:',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatCurrency(customer.remainingAmount),
                            style: const TextStyle(
                              color: LiquidGlassTheme.sunsetAmber,
                              fontSize: 13,
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
                  child: LiquidGlassButton(
                    text: 'সম্পন্ন',
                    icon: Icons.done_all_rounded,
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: LiquidGlassTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.storage,
      builder: (context, _) {
        final storage = widget.storage;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header Bar
                _buildHeader(storage),

                // Liquid Segmented Navigation (ওভারভিউ ও লাভ-ক্ষতি / দৈনিক আদায় / দোকান খরচ)
                _buildSegmentBar(),

                // Scrollable Body Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: _buildActiveTabContent(storage),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Header ---
  Widget _buildHeader(KistiStorage storage) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: LiquidGlassTheme.neonEmerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'আর্থিক হিসাব ও অ্যানালিসিস',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'লাভ-ক্ষতি, দোকান খরচ ও দৈনিক আদায় খতিয়ান',
                  style: TextStyle(
                    color: LiquidGlassTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons: + খরচ and + আদায়
          Row(
            children: [
              GestureDetector(
                onTap: _showAddExpenseSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: LiquidGlassTheme.sunsetAmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LiquidGlassTheme.sunsetAmber.withOpacity(0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: LiquidGlassTheme.sunsetAmber, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'খরচ',
                        style: TextStyle(
                          color: LiquidGlassTheme.sunsetAmber,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showCollectSheet(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: LiquidGlassTheme.neonEmerald.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LiquidGlassTheme.neonEmerald),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: LiquidGlassTheme.neonEmerald, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'আদায়',
                        style: TextStyle(
                          color: LiquidGlassTheme.neonEmerald,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Segmented Switcher ---
  Widget _buildSegmentBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          _buildSegmentItem(0, Icons.analytics_rounded, 'লাভ-ক্ষতি ও হিসাব'),
          _buildSegmentItem(1, Icons.history_rounded, 'দৈনিক খতিয়ান'),
          _buildSegmentItem(2, Icons.receipt_long_rounded, 'দোকান খরচ'),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(int index, IconData icon, String title) {
    final isSelected = _activeSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeSegment = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? LiquidGlassTheme.cyberCyan.withOpacity(0.20)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: LiquidGlassTheme.cyberCyan.withOpacity(0.5))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? LiquidGlassTheme.cyberCyan : Colors.white60,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dynamic Tab Content ---
  Widget _buildActiveTabContent(KistiStorage storage) {
    switch (_activeSegment) {
      case 0:
        return _buildOverviewAndProfitLossTab(storage);
      case 1:
        return _buildDailyHistoryTab(storage);
      case 2:
        return _buildExpensesTab(storage);
      default:
        return _buildOverviewAndProfitLossTab(storage);
    }
  }

  // ==========================================
  // TAB 1: OVERVIEW & PROFIT/LOSS
  // ==========================================
  Widget _buildOverviewAndProfitLossTab(KistiStorage storage) {
    final netProfit = storage.netProfit;
    final isProfit = netProfit >= 0;
    final primaryColor = isProfit ? LiquidGlassTheme.neonEmerald : LiquidGlassTheme.sunsetAmber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Net Profit Card
        LiquidGlassCard(
          glowColor: primaryColor,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.2),
                          border: Border.all(color: primaryColor),
                        ),
                        child: Icon(
                          isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isProfit ? 'অর্জিত নিট লাভ (Net Profit)' : 'নিট ঘাটতি / ক্ষতি (Net Loss)',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Text(
                            'আদায়কৃত লাভ - মোট দোকান খরচ',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      isProfit ? 'লাভজনক' : 'ঘাটতি',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${isProfit ? "+" : "-"}${_formatCurrency(netProfit.abs())}',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 12),
              // Sub statistics
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'আদায়কৃত বিক্রয় লাভ',
                          style: TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(storage.earnedGrossProfit),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 26, color: Colors.white12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'দোকানের মোট খরচ বাদ',
                          style: TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '- ${_formatCurrency(storage.totalExpenses)}',
                          style: const TextStyle(
                            color: LiquidGlassTheme.sunsetAmber,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 26, color: Colors.white12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'সামগ্রিক সম্ভাব্য লাভ',
                          style: TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(storage.projectedNetProfit),
                          style: const TextStyle(
                            color: LiquidGlassTheme.cyberCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Quick Action Buttons
        Row(
          children: [
            Expanded(
              child: LiquidGlassButton(
                text: '+ কিস্তি আদায়',
                icon: Icons.add_card_rounded,
                glowColor: LiquidGlassTheme.neonEmerald,
                onPressed: () => _showCollectSheet(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LiquidGlassButton(
                text: '+ খরচ যোগ',
                icon: Icons.post_add_rounded,
                glowColor: LiquidGlassTheme.sunsetAmber,
                onPressed: _showAddExpenseSheet,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Grid of Key Financial Statistics
        const Text(
          'ব্যবসার মূল আর্থিক খতিয়ান',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'মোট কিস্তি বিক্রয়',
                subtitle: 'সকল পণ্যের বিক্রয় মূল্য',
                value: _formatCurrency(storage.totalProductSalesValue),
                icon: Icons.storefront_rounded,
                color: LiquidGlassTheme.cyberCyan,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'পণ্যের কেনা মূল্য',
                subtitle: 'আসল ক্রয়/নগদ খরচ',
                value: _formatCurrency(storage.totalCashCost),
                icon: Icons.inventory_2_rounded,
                color: Colors.white70,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'মোট নগদ আদায়',
                subtitle: 'ডাউনপেমেন্ট + কিস্তি',
                value: _formatCurrency(storage.totalCollectedAll),
                icon: Icons.account_balance_wallet_rounded,
                color: LiquidGlassTheme.neonEmerald,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'বর্তমান বকেয়া',
                subtitle: 'মার্কেটে আটকে থাকা টাকা',
                value: _formatCurrency(storage.totalOutstandingKisti),
                icon: Icons.pending_actions_rounded,
                color: LiquidGlassTheme.sunsetAmber,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'দোকানের মোট খরচ',
                subtitle: 'ভাড়া, বিদ্যুৎ, বেতন ইত্যাদি',
                value: _formatCurrency(storage.totalExpenses),
                icon: Icons.receipt_long_rounded,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'আজকের নগদ আদায়',
                subtitle: 'আজকে সংগৃহীত কিস্তি',
                value: _formatCurrency(storage.todayCollected),
                icon: Icons.today_rounded,
                color: LiquidGlassTheme.neonEmerald,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Recovery Progress
        LiquidGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'কিস্তি রিকভারি অগ্রগতি',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    storage.totalProductSalesValue > 0
                        ? '${((storage.totalCollectedAll / storage.totalProductSalesValue) * 100).toStringAsFixed(1)}%'
                        : '০%',
                    style: const TextStyle(
                      color: LiquidGlassTheme.neonEmerald,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: storage.totalProductSalesValue > 0
                      ? (storage.totalCollectedAll / storage.totalProductSalesValue).clamp(0.0, 1.0)
                      : 0.0,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(LiquidGlassTheme.neonEmerald),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'সংগৃহীত: ${_formatCurrency(storage.totalCollectedAll)}',
                    style: const TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 11),
                  ),
                  Text(
                    'বাকি: ${_formatCurrency(storage.totalOutstandingKisti)}',
                    style: const TextStyle(color: LiquidGlassTheme.sunsetAmber, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: LiquidGlassTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: LiquidGlassTheme.textMuted,
              fontSize: 9,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: DAILY COLLECTION HISTORY (দৈনিক খতিয়ান)
  // ==========================================
  Widget _buildDailyHistoryTab(KistiStorage storage) {
    final dailyGroups = storage.dailyCollectionGroups;
    final now = DateTime.now();

    // Filter groups
    final filteredGroups = dailyGroups.where((group) {
      if (_historyFilter == 'আজ') {
        return group.date.year == now.year &&
            group.date.month == now.month &&
            group.date.day == now.day;
      }
      if (_historyFilter == 'এই সপ্তাহ') {
        final diff = now.difference(group.date).inDays;
        return diff <= 7;
      }
      if (_historyFilter == 'এই মাস') {
        return group.date.year == now.year && group.date.month == now.month;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter bar & Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'দৈনিক আদায় লগ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 6,
              children: ['সকল', 'আজ', 'এই সপ্তাহ', 'এই মাস'].map((filter) {
                final isSel = _historyFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSel,
                  selectedColor: LiquidGlassTheme.cyberCyan.withOpacity(0.25),
                  backgroundColor: Colors.white.withOpacity(0.04),
                  labelStyle: TextStyle(
                    color: isSel ? LiquidGlassTheme.cyberCyan : Colors.white60,
                    fontSize: 10,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSel ? LiquidGlassTheme.cyberCyan : Colors.white.withOpacity(0.1),
                  ),
                  onSelected: (_) => setState(() => _historyFilter = filter),
                );
              }).toList(),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Filtered Total Highlight Card
        LiquidGlassCard(
          glowColor: LiquidGlassTheme.neonEmerald,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: LiquidGlassTheme.neonEmerald, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$_historyFilter মোট আদায়:',
                    style: const TextStyle(
                      color: LiquidGlassTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                _formatCurrency(
                  filteredGroups.fold(0.0, (sum, g) => sum + g.totalAmount),
                ),
                style: const TextStyle(
                  color: LiquidGlassTheme.neonEmerald,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        if (filteredGroups.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 48,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                const Text(
                  'কোনো দৈনিক কিস্তি আদায় পাওয়া যায়নি',
                  style: TextStyle(color: LiquidGlassTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'উপরে "+ আদায়" বাটনে চাপ দিয়ে যেকোনো কিস্তি কালেকশন করুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                ),
              ],
            ),
          )
        else
          ...filteredGroups.map((group) {
            final isToday = group.date.year == now.year &&
                group.date.month == now.month &&
                group.date.day == now.day;
            final isYesterday = group.date.year == now.year &&
                group.date.month == now.month &&
                group.date.day == now.day - 1;

            String dateLabel;
            if (isToday) {
              dateLabel = 'আজ, ${DateFormat("dd MMMM yyyy").format(group.date)}';
            } else if (isYesterday) {
              dateLabel = 'গতকাল, ${DateFormat("dd MMMM yyyy").format(group.date)}';
            } else {
              dateLabel = DateFormat("EEEE, dd MMMM yyyy").format(group.date);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header Strip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isToday
                            ? LiquidGlassTheme.neonEmerald.withOpacity(0.4)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event_note_rounded,
                              size: 16,
                              color: isToday ? LiquidGlassTheme.neonEmerald : LiquidGlassTheme.cyberCyan,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateLabel,
                              style: TextStyle(
                                color: isToday ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: LiquidGlassTheme.neonEmerald.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'মোট: ${_formatCurrency(group.totalAmount)} (${group.records.length}টি)',
                            style: const TextStyle(
                              color: LiquidGlassTheme.neonEmerald,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Individual Collection records under this date
                  ...group.records.map((col) {
                    final timeStr = DateFormat('hh:mm a').format(col.date);
                    return LiquidGlassCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () {
                          final cust = storage.getCustomerById(col.customerId);
                          if (cust != null) {
                            _showReceiptDialog(col, cust);
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: LiquidGlassTheme.neonEmerald.withOpacity(0.15),
                                border: Border.all(
                                  color: LiquidGlassTheme.neonEmerald.withOpacity(0.4),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.receipt_rounded,
                                color: LiquidGlassTheme.neonEmerald,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          col.customerName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: LiquidGlassTheme.cyberCyan.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${col.installmentIndex}তম কিস্তি',
                                          style: const TextStyle(
                                            color: LiquidGlassTheme.cyberCyan,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${col.productName.isNotEmpty ? "${col.productName} • " : ""}${col.paymentMethod} • রশিদ: ${col.receiptNo}',
                                    style: const TextStyle(
                                      color: LiquidGlassTheme.textMuted,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'আদায়কারী: ${col.collector} • $timeStr',
                                    style: const TextStyle(
                                      color: LiquidGlassTheme.textSecondary,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '+${_formatCurrency(col.amount)}',
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.neonEmerald,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white30),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _confirmDeleteCollection(col.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _confirmDeleteCollection(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LiquidGlassTheme.bgSurfaceElevated,
        title: const Text('আদায় রেকর্ড মুছে ফেলবেন?', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'এই কিস্তি রেকর্ডটি মুছে ফেললে মোট আদায়ের হিসাব থেকে বাদ যাবে।',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('বাতিল', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.storage.deleteCollection(id);
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: LiquidGlassTheme.sunsetAmber)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: SHOP EXPENSES (দোকান খরচ)
  // ==========================================
  Widget _buildExpensesTab(KistiStorage storage) {
    final expenses = storage.expenses;
    final filtered = expenses.where((e) {
      if (_expenseFilter == 'সকল') return true;
      return e.category == _expenseFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary & Add Button
        LiquidGlassCard(
          glowColor: LiquidGlassTheme.sunsetAmber,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'দোকানের মোট খরচ',
                    style: TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(storage.totalExpenses),
                    style: const TextStyle(
                      color: LiquidGlassTheme.sunsetAmber,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'আজকের খরচ: ${_formatCurrency(storage.todayExpenses)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
              LiquidGlassButton(
                text: '+ খরচ লিখুন',
                icon: Icons.add,
                glowColor: LiquidGlassTheme.sunsetAmber,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                onPressed: _showAddExpenseSheet,
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Filter Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              'সকল',
              'দোকান ভাড়া',
              'বিদ্যুৎ বিল',
              'কর্মচারীর বেতন',
              'পরিবহন',
              'নাস্তা ও আপ্যায়ন',
              'মেরামত ও সার্ভিসিং',
              'বিবিধ খরচ',
            ].map((cat) {
              final isSel = _expenseFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSel,
                  selectedColor: LiquidGlassTheme.sunsetAmber.withOpacity(0.25),
                  backgroundColor: Colors.white.withOpacity(0.04),
                  labelStyle: TextStyle(
                    color: isSel ? LiquidGlassTheme.sunsetAmber : Colors.white60,
                    fontSize: 10,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSel ? LiquidGlassTheme.sunsetAmber : Colors.white.withOpacity(0.1),
                  ),
                  onSelected: (_) => setState(() => _expenseFilter = cat),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                const Text(
                  'কোনো খরচের হিসাব পাওয়া যায়নি',
                  style: TextStyle(color: LiquidGlassTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'দোকানের ভাড়া, কারেন্ট বিল, কর্মচারীর বেতন ইত্যাদি লিখে রাখুন যাতে নিখুঁত লাভ-ক্ষতি পাওয়া যায়।',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                ),
              ],
            ),
          )
        else
          ...filtered.map((exp) {
            final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(exp.date);
            return LiquidGlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LiquidGlassTheme.sunsetAmber.withOpacity(0.15),
                      border: Border.all(
                        color: LiquidGlassTheme.sunsetAmber.withOpacity(0.4),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      exp.categoryIcon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                exp.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: LiquidGlassTheme.sunsetAmber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                exp.category,
                                style: const TextStyle(
                                  color: LiquidGlassTheme.sunsetAmber,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (exp.note.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            exp.note,
                            style: const TextStyle(
                              color: LiquidGlassTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: LiquidGlassTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '-${_formatCurrency(exp.amount)}',
                        style: const TextStyle(
                          color: LiquidGlassTheme.sunsetAmber,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white30),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _confirmDeleteExpense(exp.id),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  void _confirmDeleteExpense(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LiquidGlassTheme.bgSurfaceElevated,
        title: const Text('খরচ মুছে ফেলবেন?', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'এই খরচের হিসাব মুছে ফেললে লাভ-ক্ষতির খতিয়ান হালনাগাদ হবে।',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('বাতিল', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.storage.deleteExpense(id);
            },
            child: const Text('মুছে ফেলুন', style: TextStyle(color: LiquidGlassTheme.sunsetAmber)),
          ),
        ],
      ),
    );
  }
}
