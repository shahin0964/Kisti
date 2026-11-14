import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/kisti_storage.dart';
import '../theme/liquid_glass_theme.dart';
import '../widgets/liquid_glass.dart';
import '../models/customer.dart';
import 'customer_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final KistiStorage storage;
  final Function(int) onNavigateTab;
  final Function(Customer)? onQuickCollect;

  const DashboardScreen({
    super.key,
    required this.storage,
    required this.onNavigateTab,
    this.onQuickCollect,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    return '৳ ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEE, d MMM yyyy').format(now);
    final todayColl = storage.todayCollected;
    final todayTgt = storage.todayTarget;
    final progress = todayTgt > 0 ? (todayColl / todayTgt).clamp(0.0, 1.0) : 0.0;
    final dueList = storage.todayDueCustomers;
    final dynamicCats = storage.dynamicCategories;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. App Top Header (Safe from notification bar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LiquidGlassTheme.neonEmerald.withOpacity(0.15),
                      border: Border.all(
                        color: LiquidGlassTheme.neonEmerald.withOpacity(0.4),
                      ),
                      boxShadow: LiquidGlassTheme.neonGlow(
                        LiquidGlassTheme.neonEmerald,
                        intensity: 0.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: LiquidGlassTheme.neonEmerald,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KISTI SEBA',
                        style: TextStyle(
                          color: LiquidGlassTheme.neonEmerald,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: LiquidGlassTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => onNavigateTab(1), // Go to Customer & Sales tab
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: LiquidGlassTheme.cyberCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: LiquidGlassTheme.cyberCyan.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add_rounded, color: LiquidGlassTheme.cyberCyan, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'নতুন বিক্রয়',
                        style: TextStyle(
                          color: LiquidGlassTheme.cyberCyan,
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

          const SizedBox(height: 10),

          // 2. Main Hero: Today's Collection Liquid Bar
          LiquidGlassCard(
            glowColor: LiquidGlassTheme.neonEmerald,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'আজকের কিস্তি আদায়',
                        style: TextStyle(
                          color: LiquidGlassTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(todayColl),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'দৈনিক লক্ষ্য: ${_formatCurrency(todayTgt)} • বকেয়া: ${_formatCurrency((todayTgt - todayColl).clamp(0.0, double.infinity))}',
                        style: const TextStyle(
                          color: LiquidGlassTheme.cyberCyan,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 5,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          LiquidGlassTheme.neonEmerald,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 3. Compact 2x2 Financial Overview Grid
          Row(
            children: [
              Expanded(
                child: _buildCompactCard(
                  'মোট পণ্য বিক্রয়',
                  _formatCurrency(storage.totalProductSalesValue),
                  '${storage.totalProductsSoldCount} টি পণ্য সরবরাহ',
                  Icons.shopping_bag_rounded,
                  LiquidGlassTheme.cyberCyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactCard(
                  'বকেয়া কিস্তি',
                  _formatCurrency(storage.totalOutstandingKisti),
                  '${storage.overdueCustomersCount} জন কিস্তি বাকি',
                  Icons.pending_actions_rounded,
                  LiquidGlassTheme.sunsetCoral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCompactCard(
                  'ডাউন পেমেন্ট জমা',
                  _formatCurrency(storage.totalDownPaymentCollected),
                  'নগদ অগ্রিম সংগ্রহ',
                  Icons.payments_rounded,
                  LiquidGlassTheme.electricViolet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactCard(
                  'চলমান কিস্তি হিসাব',
                  '${storage.activeCustomersCount} টি',
                  '${storage.completedCustomersCount} টি পরিশোধিত',
                  Icons.receipt_long_rounded,
                  LiquidGlassTheme.amberGold,
                ),
              ),
            ],
          ),

          // 4. Dynamic Categories (Only if user has created categories)
          if (dynamicCats.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 28,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: dynamicCats.length,
                itemBuilder: (context, idx) {
                  final cat = dynamicCats[idx];
                  final count = storage.getCategoryCount(cat);
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: LiquidGlassTheme.cyberCyan.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: LiquidGlassTheme.cyberCyan,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 10),

          // 5. Section Header for History / Due List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'কিস্তির খতিয়ান ও বকেয়া তালিকা',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  LiquidBadge(
                    label: '${dueList.length}',
                    color: LiquidGlassTheme.neonEmerald,
                  ),
                ],
              ),
              InkWell(
                onTap: () => onNavigateTab(1),
                child: const Text(
                  'সব দেখুন ›',
                  style: TextStyle(
                    color: LiquidGlassTheme.cyberCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 6. SCROLLABLE HISTORY LIST ONLY (desbord ekpage e thakbe, sudhu histore scrol hobe)
          Expanded(
            child: dueList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 44,
                            color: LiquidGlassTheme.neonEmerald.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'কোনো বকেয়া বা চলমান কিস্তি নেই',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'নতুন পণ্য কিস্তিতে বিক্রয় করতে ওপরের বাটনে চাপুন',
                            style: TextStyle(
                              color: LiquidGlassTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: dueList.length,
                    itemBuilder: (context, idx) {
                      final customer = dueList[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: LiquidGlassCard(
                          padding: const EdgeInsets.all(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailScreen(
                                  customerId: customer.id,
                                  storage: storage,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  customer.categoryIcon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      customer.productName,
                                      style: const TextStyle(
                                        color: LiquidGlassTheme.cyberCyan,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'বকেয়া: ${_formatCurrency(customer.remainingAmount)} • কিস্তি: ${customer.paidInstallments}/${customer.totalInstallments}',
                                      style: const TextStyle(
                                        color: LiquidGlassTheme.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  if (onQuickCollect != null) {
                                    onQuickCollect!(customer);
                                  } else {
                                    onNavigateTab(2);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: LiquidGlassTheme.neonEmerald.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: LiquidGlassTheme.neonEmerald.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatCurrency(customer.installmentAmount),
                                        style: const TextStyle(
                                          color: LiquidGlassTheme.neonEmerald,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'আদায় ›',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(
    String title,
    String value,
    String subtext,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.22),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: LiquidGlassTheme.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 14),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            subtext,
            style: const TextStyle(
              color: LiquidGlassTheme.textMuted,
              fontSize: 9.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
