import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/collection.dart';
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
  Customer? _selectedCustomer;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _collectorController =
      TextEditingController(text: 'ফিল্ড ম্যানেজার');
  String _selectedMethod = 'নগদ';
  String _dateFilter = 'সকল'; // 'আজ', 'এই সপ্তাহ', 'সকল'

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCustomer != null) {
      _selectCustomer(widget.preselectedCustomer!);
    } else if (widget.storage.todayDueCustomers.isNotEmpty) {
      _selectCustomer(widget.storage.todayDueCustomers.first);
    }
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _amountController.text = customer.installmentAmount.toInt().toString();
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    return '৳ ${formatter.format(amount)}';
  }

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
                  'কিস্তি আদায় সফল হয়েছে!',
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
                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                const SizedBox(height: 10),
                _buildReceiptRow('গ্রাহকের নাম', record.customerName),
                _buildReceiptRow('আদায়কৃত পরিমাণ', _formatCurrency(record.amount),
                    valueColor: LiquidGlassTheme.neonEmerald),
                _buildReceiptRow('কিস্তি নম্বর', '#${record.installmentIndex}'),
                _buildReceiptRow('পেমেন্ট মাধ্যম', record.paymentMethod),
                _buildReceiptRow('তারিখ ও সময়',
                    DateFormat('dd MMM yyyy, hh:mm a').format(record.date)),
                _buildReceiptRow('সংগ্রাহক', record.collector),
                if (record.note.isNotEmpty)
                  _buildReceiptRow('মন্তব্য', record.note),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: LiquidButton(
                    text: 'ঠিক আছে',
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: LiquidGlassTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCollection() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে একজন গ্রাহক নির্বাচন করুন')),
      );
      return;
    }

    final amt = double.tryParse(_amountController.text) ?? 0.0;
    if (amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক আদায়ের পরিমাণ লিখুন')),
      );
      return;
    }

    final record = await widget.storage.recordCollection(
      customer: _selectedCustomer!,
      amount: amt,
      paymentMethod: _selectedMethod,
      note: _noteController.text.trim(),
      collector: _collectorController.text.trim(),
    );

    if (mounted) {
      _showReceiptDialog(record, _selectedCustomer!);
      setState(() {
        _noteController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final filteredCollections = widget.storage.collections.where((col) {
      if (_dateFilter == 'আজ') {
        return col.date.year == now.year &&
            col.date.month == now.month &&
            col.date.day == now.day;
      } else if (_dateFilter == 'এই সপ্তাহ') {
        return now.difference(col.date).inDays <= 7;
      }
      return true;
    }).toList();

    final totalFilterColl =
        filteredCollections.fold(0.0, (sum, col) => sum + col.amount);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'কিস্তি আদায় কেন্দ্র',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'দ্রুত কালেকশন এন্ট্রি ও ভাউচার রশিদ',
                        style: TextStyle(
                          color: LiquidGlassTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const LiquidBadge(
                    label: 'রিয়েল-টাইম খতিয়ান',
                    color: LiquidGlassTheme.neonEmerald,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Collection Form Card
              LiquidGlassCard(
                glowColor: LiquidGlassTheme.neonEmerald,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'কিস্তি সংগ্রহ ফরম',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Customer Selector Dropdown
                    const Text(
                      'গ্রাহক নির্বাচন করুন',
                      style: TextStyle(
                        color: LiquidGlassTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Customer>(
                          isExpanded: true,
                          dropdownColor: LiquidGlassTheme.bgMidnight,
                          value: _selectedCustomer,
                          hint: const Text(
                            'গ্রাহক বাছাই করুন',
                            style: TextStyle(color: LiquidGlassTheme.textMuted),
                          ),
                          items: widget.storage.customers
                              .where((c) => c.status != 'পরিশোধিত')
                              .map((c) {
                            return DropdownMenuItem<Customer>(
                              value: c,
                              child: Text(
                                '${c.name} (${c.frequency} - ${_formatCurrency(c.installmentAmount)})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (cust) {
                            if (cust != null) _selectCustomer(cust);
                          },
                        ),
                      ),
                    ),

                    if (_selectedCustomer != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LiquidGlassTheme.cyberCyan.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: LiquidGlassTheme.cyberCyan.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'কিস্তি #${_selectedCustomer!.paidInstallments + 1} / ${_selectedCustomer!.totalInstallments}',
                              style: const TextStyle(
                                color: LiquidGlassTheme.cyberCyan,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'বকেয়া: ${_formatCurrency(_selectedCustomer!.remainingAmount)}',
                              style: const TextStyle(
                                color: LiquidGlassTheme.sunsetCoral,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Amount Field
                    LiquidTextField(
                      controller: _amountController,
                      label: 'আদায়ের পরিমাণ (টাকা)',
                      prefixIcon: Icons.payments_rounded,
                      keyboardType: TextInputType.number,
                    ),

                    // Payment Method selector
                    const SizedBox(height: 8),
                    const Text(
                      'পেমেন্ট মাধ্যম',
                      style: TextStyle(
                        color: LiquidGlassTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ['নগদ', 'বিকাশ', 'নগদ-অ্যাপ', 'রকেট'].map((m) {
                        final isSel = _selectedMethod == m;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMethod = m),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? LiquidGlassTheme.neonEmerald.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel
                                      ? LiquidGlassTheme.neonEmerald
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                m,
                                style: TextStyle(
                                  color: isSel
                                      ? LiquidGlassTheme.neonEmerald
                                      : Colors.white70,
                                  fontSize: 11,
                                  fontWeight: isSel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),
                    LiquidTextField(
                      controller: _noteController,
                      label: 'মন্তব্য (ঐচ্ছিক)',
                      prefixIcon: Icons.edit_note_rounded,
                    ),

                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: LiquidButton(
                        text: 'আদায় নিশ্চিত করুন',
                        icon: Icons.check_circle_rounded,
                        onPressed: _submitCollection,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Filter Buttons & Total Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'আদায় খতিয়ান',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: ['সকল', 'এই সপ্তাহ', 'আজ'].map((f) {
                      final isSel = _dateFilter == f;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: isSel,
                          onSelected: (val) => setState(() => _dateFilter = f),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.black : Colors.white70,
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          selectedColor: LiquidGlassTheme.cyberCyan,
                          backgroundColor: Colors.white.withOpacity(0.06),
                          side: BorderSide(
                            color: isSel
                                ? LiquidGlassTheme.cyberCyan
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Total Collected Banner for the filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'নির্বাচিত সময়ের মোট আদায় (${filteredCollections.length} টি)',
                      style: const TextStyle(
                        color: LiquidGlassTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatCurrency(totalFilterColl),
                      style: const TextStyle(
                        color: LiquidGlassTheme.neonEmerald,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Collections List
              if (filteredCollections.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Text(
                    'কোনো আদায় পাওয়া যায়নি',
                    style: TextStyle(color: LiquidGlassTheme.textMuted),
                  ),
                )
              else
                ...filteredCollections.map((col) {
                  final formattedDate =
                      DateFormat('dd MMM yyyy, hh:mm a').format(col.date);
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
                            color: LiquidGlassTheme.neonEmerald.withOpacity(0.15),
                            border: Border.all(
                              color: LiquidGlassTheme.neonEmerald.withOpacity(0.4),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: LiquidGlassTheme.neonEmerald,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                col.customerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${col.receiptNo} • ${col.paymentMethod}',
                                style: const TextStyle(
                                  color: LiquidGlassTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                formattedDate,
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
                              _formatCurrency(col.amount),
                              style: const TextStyle(
                                color: LiquidGlassTheme.neonEmerald,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LiquidBadge(
                              label: 'কিস্তি #${col.installmentIndex}',
                              color: LiquidGlassTheme.cyberCyan,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
