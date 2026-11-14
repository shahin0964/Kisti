import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/kisti_storage.dart';
import '../theme/liquid_glass_theme.dart';
import '../widgets/liquid_glass.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  final KistiStorage storage;

  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    required this.storage,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    return '৳ ${formatter.format(amount)}';
  }

  void _showCollectModal(Customer customer) {
    final amountController =
        TextEditingController(text: customer.installmentAmount.toInt().toString());
    final noteController = TextEditingController();
    String paymentMethod = 'নগদ';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: LiquidGlassCard(
                borderRadius: 28,
                glowColor: LiquidGlassTheme.neonEmerald,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'পণ্য কিস্তি আদায় স্লিপ',
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          customer.categoryIcon,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${customer.name} • ${customer.productName}',
                                style: const TextStyle(
                                  color: LiquidGlassTheme.cyberCyan,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'কিস্তি নং ${customer.paidInstallments + 1} / ${customer.totalInstallments} • বকেয়া: ${_formatCurrency(customer.remainingAmount)}',
                                style: const TextStyle(
                                  color: LiquidGlassTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LiquidTextField(
                      controller: amountController,
                      label: 'আদায়ের পরিমাণ (টাকা)',
                      prefixIcon: Icons.payments_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'পেমেন্ট মাধ্যম',
                      style: TextStyle(
                        color: LiquidGlassTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['নগদ', 'বিকাশ', 'নগদ-অ্যাপ', 'রকেট'].map((m) {
                        final isSel = paymentMethod == m;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => paymentMethod = m),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? LiquidGlassTheme.neonEmerald.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
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
                                  fontWeight:
                                      isSel ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    LiquidTextField(
                      controller: noteController,
                      label: 'মন্তব্য (ঐচ্ছিক)',
                      prefixIcon: Icons.notes_rounded,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: LiquidButton(
                        text: 'আদায় সম্পন্ন করুন',
                        icon: Icons.check_circle_rounded,
                        onPressed: () async {
                          final amt = double.tryParse(amountController.text) ??
                              customer.installmentAmount;
                          final nav = Navigator.of(ctx);
                          final messenger = ScaffoldMessenger.of(context);
                          await widget.storage.recordCollection(
                            customer: customer,
                            amount: amt,
                            paymentMethod: paymentMethod,
                            note: noteController.text.trim(),
                          );
                          if (!mounted) return;
                          nav.pop();
                          setState(() {});
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: LiquidGlassTheme.bgMidnight,
                              content: Text(
                                '${customer.productName}-এর ${_formatCurrency(amt)} আদায় সফল হয়েছে!',
                                style: const TextStyle(
                                  color: LiquidGlassTheme.neonEmerald,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirm(Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: LiquidGlassTheme.bgMidnight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          title: const Text(
            'গ্রাহক ও পণ্য বিক্রয় খতিয়ান মুছবেন?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '${customer.name}-এর ${customer.productName} বিক্রয়ের সমস্ত কিস্তির খতিয়ান মুছে ফেলা হবে। এই কাজটি পুনরায় ফিরিয়ে আনা যাবে না।',
            style: const TextStyle(color: LiquidGlassTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                final dialogNav = Navigator.of(ctx);
                await widget.storage.deleteCustomer(customer.id);
                if (!mounted) return;
                dialogNav.pop();
                nav.pop();
              },
              child: const Text(
                'মুছে ফেলুন',
                style: TextStyle(color: LiquidGlassTheme.sunsetCoral),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.storage.getCustomerById(widget.customerId);

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: Text(
            'গ্রাহক খুঁজে পাওয়া যায়নি',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final collections = widget.storage.getCollectionsForCustomer(customer.id);

    return Scaffold(
      backgroundColor: LiquidGlassTheme.bgDarkVoid,
      body: LiquidBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Glass App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'পণ্য কিস্তি পাসবুক ও খতিয়ান',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: LiquidGlassTheme.sunsetCoral,
                        ),
                        onPressed: () => _showDeleteConfirm(customer),
                      ),
                    ],
                  ),
                ),
              ),

              // Customer & Product Header Info Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      LiquidGlassCard(
                        glowColor: LiquidGlassTheme.cyberCyan,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        LiquidGlassTheme.cyberCyan,
                                        LiquidGlassTheme.neonEmerald,
                                      ],
                                    ),
                                    boxShadow: LiquidGlassTheme.neonGlow(
                                      LiquidGlassTheme.cyberCyan,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    customer.categoryIcon,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.productName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_rounded,
                                            size: 13,
                                            color: LiquidGlassTheme.cyberCyan,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            customer.name,
                                            style: const TextStyle(
                                              color: LiquidGlassTheme.cyberCyan,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone_rounded,
                                            size: 12,
                                            color: LiquidGlassTheme.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            customer.phone,
                                            style: const TextStyle(
                                              color: LiquidGlassTheme.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (customer.modelOrImei.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.qr_code_2_rounded,
                                        size: 14,
                                        color: LiquidGlassTheme.neonEmerald),
                                    const SizedBox(width: 6),
                                    Text(
                                      'মডেল / IMEI / Serial: ${customer.modelOrImei}',
                                      style: const TextStyle(
                                        color: LiquidGlassTheme.neonEmerald,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 14),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildHeaderBadge(
                                  'ক্যাটাগরি',
                                  customer.productCategory,
                                  LiquidGlassTheme.cyberCyan,
                                ),
                                _buildHeaderBadge(
                                  'কিস্তির ধরন',
                                  customer.frequency,
                                  LiquidGlassTheme.neonEmerald,
                                ),
                                _buildHeaderBadge(
                                  'স্ট্যাটাস',
                                  customer.status,
                                  customer.status == 'পরিশোধিত'
                                      ? LiquidGlassTheme.neonEmerald
                                      : (customer.status == 'বকেয়া'
                                          ? LiquidGlassTheme.sunsetCoral
                                          : LiquidGlassTheme.amberGold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Product Hire Purchase Ledger Card
                      LiquidGlassCard(
                        glowColor: LiquidGlassTheme.neonEmerald,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'পণ্য বিক্রয় ও কিস্তি হিসাব',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                LiquidBadge(
                                  label: 'ডাউন: ${_formatCurrency(customer.downPayment)}',
                                  color: LiquidGlassTheme.cyberCyan,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatCol('নগদ মূল্য', _formatCurrency(customer.cashPrice)),
                                _buildStatCol('কিস্তি মোট মূল্য', _formatCurrency(customer.installmentPrice)),
                                _buildStatCol('ডাউন পেমেন্ট', _formatCurrency(customer.downPayment),
                                    color: LiquidGlassTheme.cyberCyan),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatCol('মোট কিস্তি আদায়', _formatCurrency(customer.totalPaid),
                                    color: LiquidGlassTheme.neonEmerald),
                                _buildStatCol('প্রতি কিস্তি', _formatCurrency(customer.installmentAmount)),
                                _buildStatCol('বাকি কিস্তি বকেয়া', _formatCurrency(customer.remainingAmount),
                                    color: LiquidGlassTheme.sunsetCoral),
                              ],
                            ),
                            const SizedBox(height: 18),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: customer.progressPercentage,
                                minHeight: 10,
                                backgroundColor: Colors.white.withOpacity(0.08),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  LiquidGlassTheme.neonEmerald,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'কিস্তি জমা: ${customer.paidInstallments} / ${customer.totalInstallments} টি',
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${(customer.progressPercentage * 100).toInt()}% পরিশোধিত',
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.neonEmerald,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: LiquidButton(
                                text: customer.isFullyPaid
                                    ? 'পণ্য কিস্তি পরিশোধিত ✓'
                                    : 'কিস্তি গ্রহণ করুন',
                                icon: Icons.payments_rounded,
                                glowColor: customer.isFullyPaid
                                    ? LiquidGlassTheme.textMuted
                                    : LiquidGlassTheme.neonEmerald,
                                onPressed: customer.isFullyPaid
                                    ? () {}
                                    : () => _showCollectModal(customer),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Guarantor & Customer info details
                      const SizedBox(height: 12),
                      LiquidGlassCard(
                        glowColor: LiquidGlassTheme.electricViolet,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'গ্রাহক ও জামিনদার তথ্য',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.location_on_rounded,
                              'ঠিকানা',
                              customer.address,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.badge_rounded,
                              'এনআইডি / ভোটার আইডি',
                              customer.nid,
                            ),
                            if (customer.guarantorName.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.verified_user_rounded,
                                'জামিনদার (গ্যারান্টার)',
                                '${customer.guarantorName} (${customer.guarantorPhone})',
                              ),
                            ],
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.calendar_month_rounded,
                              'বিক্রয়ের তারিখ',
                              DateFormat('dd MMMM yyyy').format(customer.startDate),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Section Title: Collection History
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'আদায় রেকর্ড ইতিহাস',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          LiquidBadge(
                            label: '${collections.length} টি জমা',
                            color: LiquidGlassTheme.cyberCyan,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Collections List
              if (collections.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'এখনও কোনো কিস্তি জমা হয়নি',
                        style: TextStyle(color: LiquidGlassTheme.textMuted),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, idx) {
                        final record = collections[idx];
                        final dateFormatted =
                            DateFormat('dd MMM yyyy, hh:mm a').format(record.date);

                        return LiquidGlassCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: LiquidGlassTheme.neonEmerald.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: LiquidGlassTheme.neonEmerald.withOpacity(0.3),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '#${record.installmentIndex}',
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.neonEmerald,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateFormatted,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${record.receiptNo} • ${record.paymentMethod}',
                                      style: const TextStyle(
                                        color: LiquidGlassTheme.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (record.note.isNotEmpty)
                                      Text(
                                        record.note,
                                        style: const TextStyle(
                                          color: LiquidGlassTheme.cyberCyan,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatCurrency(record.amount),
                                style: const TextStyle(
                                  color: LiquidGlassTheme.neonEmerald,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: collections.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: LiquidGlassTheme.cyberCyan),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: LiquidGlassTheme.textMuted,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: LiquidGlassTheme.textMuted,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        LiquidBadge(label: value, color: color),
      ],
    );
  }

  Widget _buildStatCol(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: LiquidGlassTheme.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
