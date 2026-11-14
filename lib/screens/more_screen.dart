import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/kisti_storage.dart';
import '../theme/liquid_glass_theme.dart';
import '../widgets/liquid_glass.dart';
import 'kisti_calculator_screen.dart';

class MoreScreen extends StatelessWidget {
  final KistiStorage storage;

  const MoreScreen({super.key, required this.storage});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    return '৳ ${formatter.format(amount)}';
  }

  void _showReportDialog(BuildContext context) {
    final totalSales = storage.totalProductSalesValue;
    final totalDown = storage.totalDownPaymentCollected;
    final totalKistiColl = storage.totalInstallmentCollectedAllTime;
    final totalCollected = totalDown + totalKistiColl;
    final totalOutstanding = storage.totalOutstandingKisti;
    final recoveryRate = totalSales > 0
        ? ((totalCollected / totalSales) * 100).toStringAsFixed(1)
        : '0.0';

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: LiquidGlassCard(
            borderRadius: 24,
            glowColor: LiquidGlassTheme.cyberCyan,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'বিক্রয় ও কিস্তি অডিট রিপোর্ট',
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
                const SizedBox(height: 14),
                _buildReportItem('মোট পণ্য বিক্রয় মূল্য', _formatCurrency(totalSales)),
                _buildReportItem('মোট ডাউন পেমেন্ট আদায়', _formatCurrency(totalDown),
                    color: LiquidGlassTheme.cyberCyan),
                _buildReportItem('মোট কিস্তি আদায়', _formatCurrency(totalKistiColl),
                    color: LiquidGlassTheme.neonEmerald),
                _buildReportItem('সর্বমোট সংগৃহীত তহবিল', _formatCurrency(totalCollected),
                    color: LiquidGlassTheme.neonEmerald),
                _buildReportItem('বর্তমান বকেয়া কিস্তি', _formatCurrency(totalOutstanding),
                    color: LiquidGlassTheme.sunsetCoral),
                _buildReportItem('আদায় অগ্রগতি হার', '$recoveryRate%',
                    color: LiquidGlassTheme.amberGold),
                const Divider(color: Colors.white12, height: 20),
                _buildReportItem('মোট বিক্রিত পণ্য সংখ্যা', '${storage.customers.length} টি'),
                _buildReportItem('চলতি কিস্তি গ্রাহক', '${storage.activeCustomersCount} জন'),
                _buildReportItem('পরিশোধিত পণ্য কিস্তি', '${storage.completedCustomersCount} টি'),
                _buildReportItem('খেলাপী / বকেয়া কিস্তি', '${storage.overdueCustomersCount} জন',
                    color: LiquidGlassTheme.sunsetCoral),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: LiquidButton(
                    text: 'বন্ধ করুন',
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

  Widget _buildReportItem(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: LiquidGlassTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    final exportData = {
      'customers': storage.customers.map((c) => c.toJson()).toList(),
      'collections': storage.collections.map((c) => c.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'app': 'Kisti Seba v1.0.1 (Product Installment Sales)',
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: LiquidGlassCard(
            borderRadius: 24,
            glowColor: LiquidGlassTheme.neonEmerald,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ডেটা ব্যাকআপ ও এক্সপোর্ট',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'আপনার শো-রুমের সকল পণ্য বিক্রয় ও কিস্তি আদায়ের ডেটা JSON ফরমেটে সুরক্ষিত:',
                  style: TextStyle(
                    color: LiquidGlassTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      jsonStr,
                      style: const TextStyle(
                        color: LiquidGlassTheme.cyberCyan,
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LiquidButton(
                        text: 'কপি করুন',
                        icon: Icons.copy_rounded,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: jsonStr));
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ব্যাকআপ ডেটা ক্লিপবোর্ডে কপি করা হয়েছে!'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LiquidButton(
                        text: 'বন্ধ করুন',
                        isSecondary: true,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductSchemesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: LiquidGlassCard(
            borderRadius: 24,
            glowColor: LiquidGlassTheme.amberGold,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'পণ্য কিস্তি পলিসি ও স্কিমসমূহ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _buildSchemeCard(
                  '📱 স্মার্টফোন ও গ্যাজেট কিস্তি',
                  'ডাউন পেমেন্ট: ২০%-৩০% • মেয়াদ: ৩-১২ মাস\nঅফিসিয়াল ওয়ারেন্টি ও ক্যাশলেস মাসিক কিস্তি সুবিধা।',
                  LiquidGlassTheme.neonEmerald,
                ),
                _buildSchemeCard(
                  '🧊 ফ্রিজ ও ডিপ ফ্রিজার কিস্তি',
                  'ডাউন পেমেন্ট: ১৫%-২৫% • মেয়াদ: ৬-১৮ মাস\nবাসাবাড়ি ও বাণিজ্যিক ব্যবহারের জন্য সহজ কিস্তিতে ডেলিভারি।',
                  LiquidGlassTheme.cyberCyan,
                ),
                _buildSchemeCard(
                  '📺 স্মার্ট টিভি ও বিনোদন হোম থিয়েটার',
                  'ডাউন পেমেন্ট: ২০% • মেয়াদ: ৬-১২ মাস\nস্মার্ট অ্যান্ড্রয়েড টিভি, সাউন্ড সিস্টেম কিস্তিতে বিক্রয়।',
                  LiquidGlassTheme.amberGold,
                ),
                _buildSchemeCard(
                  '❄️ এসি ও মৌসুমী অ্যাপ্লায়েন্স স্কিম',
                  'ডাউন পেমেন্ট: ২৫% • মেয়াদ: ১২-২৪ মাস\nইনভার্টার এসি ফ্রি ইনস্টলেশন ও দীর্ঘমেয়াদী কিস্তি।',
                  LiquidGlassTheme.electricViolet,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: LiquidButton(
                    text: 'বন্ধ করুন',
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

  void _showClearDataConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: LiquidGlassTheme.bgMidnight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          title: const Text('সব ডেটা মুছে ফেলবেন?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'শো-রুমের সকল পণ্য বিক্রয়, কিস্তি খতিয়ান এবং আদায় রেকর্ড সম্পূর্ণ মুছে ফেলা হবে।',
            style: TextStyle(color: LiquidGlassTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);
                await storage.clearAllData();
                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    backgroundColor: LiquidGlassTheme.bgMidnight,
                    content: Text(
                      'সকল ডেটা সফলভাবে মুছে ফেলা হয়েছে!',
                      style: TextStyle(color: LiquidGlassTheme.sunsetCoral),
                    ),
                  ),
                );
              },
              child: const Text('মুছে ফেলুন', style: TextStyle(color: LiquidGlassTheme.sunsetCoral)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSchemeCard(String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: LiquidGlassTheme.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'আরও সেবা ও শো-রুম সেটিংস',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'পণ্য কিস্তি টুলস, রিপোর্ট ও সিস্টেম কন্ট্রোল',
                    style: TextStyle(
                      color: LiquidGlassTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Feature Grid/List
              LiquidGlassCard(
                glowColor: LiquidGlassTheme.cyberCyan,
                padding: const EdgeInsets.all(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KistiCalculatorScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LiquidGlassTheme.cyberCyan.withOpacity(0.15),
                        border: Border.all(color: LiquidGlassTheme.cyberCyan),
                      ),
                      child: const Icon(
                        Icons.calculate_rounded,
                        color: LiquidGlassTheme.cyberCyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'পণ্য কিস্তি (EMI) ক্যালকুলেটর',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'মোবাইল, ফ্রিজ, টিভি কিস্তির নগদ মূল্য ও ডাউন পেমেন্ট হিসাব',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ],
                ),
              ),

              LiquidGlassCard(
                glowColor: LiquidGlassTheme.neonEmerald,
                padding: const EdgeInsets.all(16),
                onTap: () => _showReportDialog(context),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LiquidGlassTheme.neonEmerald.withOpacity(0.15),
                        border: Border.all(color: LiquidGlassTheme.neonEmerald),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: LiquidGlassTheme.neonEmerald,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'বিক্রয় ও কিস্তি অডিট রিপোর্ট',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'মোট বিক্রয়, ডাউন পেমেন্ট ও বাকি বকেয়ার সামারি',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ],
                ),
              ),

              LiquidGlassCard(
                glowColor: LiquidGlassTheme.amberGold,
                padding: const EdgeInsets.all(16),
                onTap: () => _showProductSchemesDialog(context),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LiquidGlassTheme.amberGold.withOpacity(0.15),
                        border: Border.all(color: LiquidGlassTheme.amberGold),
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: LiquidGlassTheme.amberGold,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'পণ্য কিস্তি পলিসি ও স্কিমসমূহ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'মোবাইল, ফ্রিজ, টিভি, এসির কিস্তির শর্ত ও ওয়ারেন্টি নিয়মাবলী',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ],
                ),
              ),

              LiquidGlassCard(
                glowColor: LiquidGlassTheme.electricViolet,
                padding: const EdgeInsets.all(16),
                onTap: () => _showBackupDialog(context),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LiquidGlassTheme.electricViolet.withOpacity(0.15),
                        border: Border.all(color: LiquidGlassTheme.electricViolet),
                      ),
                      child: const Icon(
                        Icons.backup_rounded,
                        color: LiquidGlassTheme.electricViolet,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'ডেটা ব্যাকআপ ও এক্সপোর্ট',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'সকল বিক্রয় ও কিস্তির খতিয়ান সুরক্ষিত রাখুন',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ],
                ),
              ),

              LiquidGlassCard(
                glowColor: LiquidGlassTheme.sunsetCoral,
                padding: const EdgeInsets.all(16),
                onTap: () => _showClearDataConfirm(context),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LiquidGlassTheme.sunsetCoral.withOpacity(0.15),
                        border: Border.all(color: LiquidGlassTheme.sunsetCoral),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: LiquidGlassTheme.sunsetCoral,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'সকল ডেটা রিসেট ও মুছুন',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'শো-রুমের সমস্ত রেকর্ড মুছে নতুনভাবে শুরু করুন',
                            style: TextStyle(
                              color: LiquidGlassTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // App Info Card
              LiquidGlassCard(
                glowColor: LiquidGlassTheme.neonEmerald,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                LiquidGlassTheme.cyberCyan,
                                LiquidGlassTheme.neonEmerald,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.black,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Kisti (কিস্তি সেবা)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ভার্সন ১.০.১ • পণ্য কিস্তি ম্যানেজমেন্ট প্ল্যাটফর্ম',
                                style: TextStyle(
                                  color: LiquidGlassTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const LiquidBadge(
                          label: 'v1.0.1',
                          color: LiquidGlassTheme.neonEmerald,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ইলেকট্রনিক্স শো-রুম, মোবাইল শপ ও হোম অ্যাপ্লায়েন্সের পণ্য সহজ কিস্তিতে বিক্রয় ও স্বয়ংক্রিয় খতিয়ান পরিচালনার ফিউচারিস্টিক লিকুইড গ্লাস সমাধান।',
                      style: TextStyle(
                        color: LiquidGlassTheme.textMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
