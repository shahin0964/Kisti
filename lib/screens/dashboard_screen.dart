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
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);
    final todayColl = storage.todayCollected;
    final todayTgt = storage.todayTarget;
    final progress = todayTgt > 0 ? (todayColl / todayTgt).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Bar / Top Futuristic Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
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
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: LiquidGlassTheme.neonEmerald,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'KISTI SEBA',
                        style: TextStyle(
                          color: LiquidGlassTheme.neonEmerald,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: LiquidGlassTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              // Live Status Badge
              const LiquidBadge(
                label: 'অনলাইন সিস্টেম',
                color: LiquidGlassTheme.cyberCyan,
                icon: Icons.wifi_rounded,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Hero Card: Today's Collection Liquid Progress
          LiquidGlassCard(
            glowColor: LiquidGlassTheme.neonEmerald,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'আজকের আদায়',
                          style: TextStyle(
                            color: LiquidGlassTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatCurrency(todayColl),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    // Circular Progress Dial
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 66,
                          height: 66,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              LiquidGlassTheme.neonEmerald,
                            ),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: LiquidGlassTheme.neonEmerald,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.track_changes_rounded,
                            size: 16,
                            color: LiquidGlassTheme.cyberCyan,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'দৈনিক লক্ষ্য: ${_formatCurrency(todayTgt)}',
                            style: const TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'অবশিষ্ট: ${_formatCurrency((todayTgt - todayColl).clamp(0.0, todayTgt))}',
                        style: const TextStyle(
                          color: LiquidGlassTheme.amberGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2x2 Metric Grid
          Row(
            children: [
              Expanded(
                child: LiquidGlassCard(
                  glowColor: LiquidGlassTheme.cyberCyan,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'মোট বিতরণ',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 16,
                            color: LiquidGlassTheme.cyberCyan,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(storage.totalPrincipalDisbursed),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${storage.customers.length} জন গ্রাহক',
                        style: const TextStyle(
                          color: LiquidGlassTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LiquidGlassCard(
                  glowColor: LiquidGlassTheme.sunsetCoral,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'মোট বকেয়া',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.pending_actions_rounded,
                            size: 16,
                            color: LiquidGlassTheme.sunsetCoral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(storage.totalOutstanding),
                        style: const TextStyle(
                          color: LiquidGlassTheme.sunsetCoral,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${storage.overdueCustomersCount} জন খেলাপী',
                        style: TextStyle(
                          color: LiquidGlassTheme.sunsetCoral.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: LiquidGlassCard(
                  glowColor: LiquidGlassTheme.electricViolet,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'মোট আদায়',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.savings_rounded,
                            size: 16,
                            color: LiquidGlassTheme.electricViolet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCurrency(storage.totalCollectedAllTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${storage.collections.length} টি রশিদ',
                        style: const TextStyle(
                          color: LiquidGlassTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LiquidGlassCard(
                  glowColor: LiquidGlassTheme.amberGold,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'সক্রিয় ঋণ',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.group_rounded,
                            size: 16,
                            color: LiquidGlassTheme.amberGold,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${storage.activeCustomersCount} টি',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${storage.completedCustomersCount} টি সমাপ্ত',
                        style: const TextStyle(
                          color: LiquidGlassTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Action Banner
          LiquidGlassCard(
            glowColor: LiquidGlassTheme.cyberCyan,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        LiquidGlassTheme.cyberCyan,
                        LiquidGlassTheme.neonEmerald,
                      ],
                    ),
                    boxShadow: LiquidGlassTheme.neonGlow(LiquidGlassTheme.cyberCyan),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.black87,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'তাৎক্ষণিক কিস্তি আদায়',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ওয়ান-ট্যাপে সরাসরি কিস্তির টাকা এন্ট্রি করুন',
                        style: TextStyle(
                          color: LiquidGlassTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                LiquidButton(
                  text: 'আদায়',
                  height: 38,
                  onPressed: () => onNavigateTab(2), // Jump to Collection tab
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section: Today's Due Installments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'আজকের প্রদেয় কিস্তি',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => onNavigateTab(1), // View Customers
                child: const Text(
                  'সবগুলো দেখুন',
                  style: TextStyle(
                    color: LiquidGlassTheme.cyberCyan,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Due Customers List
          if (storage.todayDueCustomers.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                'আজকের কোনো কিস্তি বাকি নেই! 🎉',
                style: TextStyle(color: LiquidGlassTheme.textSecondary),
              ),
            )
          else
            ...storage.todayDueCustomers.take(4).map((cust) {
              return LiquidGlassCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerDetailScreen(
                        customerId: cust.id,
                        storage: storage,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    // Avatar circle with frequency
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                        border: Border.all(
                          color: cust.status == 'বকেয়া'
                              ? LiquidGlassTheme.sunsetCoral.withOpacity(0.6)
                              : LiquidGlassTheme.neonEmerald.withOpacity(0.6),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cust.name.isNotEmpty ? cust.name[0] : 'গ',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  cust.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              LiquidBadge(
                                label: cust.frequency,
                                color: LiquidGlassTheme.cyberCyan,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'পরিশোধ: ${cust.paidInstallments}/${cust.totalInstallments} কিস্তি',
                            style: const TextStyle(
                              color: LiquidGlassTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(cust.installmentAmount),
                          style: const TextStyle(
                            color: LiquidGlassTheme.neonEmerald,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LiquidButton(
                          text: 'গ্রহণ',
                          height: 30,
                          glowColor: LiquidGlassTheme.neonEmerald,
                          onPressed: () {
                            if (onQuickCollect != null) {
                              onQuickCollect!(cust);
                            } else {
                              onNavigateTab(2);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // Section: Recent Collections
          const Text(
            'সাম্প্রতিক আদায় রশিদ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          if (storage.collections.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'কোনো আদায় রেকর্ড পাওয়া যায়নি',
                style: TextStyle(color: LiquidGlassTheme.textMuted),
              ),
            )
          else
            ...storage.collections.take(3).map((col) {
              final timeStr = DateFormat('hh:mm a, d MMM').format(col.date);
              return LiquidGlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: LiquidGlassTheme.neonEmerald.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$timeStr • ${col.paymentMethod}',
                            style: const TextStyle(
                              color: LiquidGlassTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatCurrency(col.amount),
                      style: const TextStyle(
                        color: LiquidGlassTheme.neonEmerald,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
