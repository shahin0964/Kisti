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
    final totalDisbursed = storage.totalPrincipalDisbursed;
    final totalReceivable = storage.totalExpectedReceivable;
    final totalCollected = storage.totalCollectedAllTime;
    final totalOutstanding = storage.totalOutstanding;
    final recoveryRate = totalReceivable > 0
        ? ((totalCollected / totalReceivable) * 100).toStringAsFixed(1)
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
                      'আর্থিক রিপোর্ট ও সারসংক্ষেপ',
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
                _buildReportItem('মোট ঋণ বিতরণ', _formatCurrency(totalDisbursed)),
                _buildReportItem('মোট প্রদেয় লক্ষ্যমাত্রা', _formatCurrency(totalReceivable)),
                _buildReportItem('মোট আদায়কৃত টাকা', _formatCurrency(totalCollected),
                    color: LiquidGlassTheme.neonEmerald),
                _buildReportItem('বর্তমান মোট বকেয়া', _formatCurrency(totalOutstanding),
                    color: LiquidGlassTheme.sunsetCoral),
                _buildReportItem('আদায় অগ্রগতি হার', '$recoveryRate%',
                    color: LiquidGlassTheme.cyberCyan),
                _buildReportItem('সক্রিয় ঋণগ্রহীতা', '${storage.activeCustomersCount} জন'),
                _buildReportItem('পরিশোধিত ঋণগ্রহীতা', '${storage.completedCustomersCount} জন'),
                _buildReportItem('খেলাপী ঋণগ্রহীতা', '${storage.overdueCustomersCount} জন',
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
      'app': 'Kisti Seba v1.0.0',
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
                  'আপনার সকল গ্রাহক ও কিস্তি আদায়ের ডেটা নিচে JSON ফরমেটে সুরক্ষিত আছে:',
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

  void _showLoanSchemesDialog(BuildContext context) {
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
                  'ঋণ ও সঞ্চয় স্কিমসমূহ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _buildSchemeCard(
                  'দৈনিক ক্ষুদ্রঋণ (Micro)',
                  'মেয়াদ: ২০-৩০ দিন • সুদ: ১০%\nহকার ও কাঁচাবাজার ব্যবসায়ীদের জন্য দ্রুত কিস্তি সুবিধা।',
                  LiquidGlassTheme.neonEmerald,
                ),
                _buildSchemeCard(
                  'সাপ্তাহিক বাণিজ্যিক ঋণ (SME)',
                  'মেয়াদ: ২০-৫০ সপ্তাহ • সুদ: ১২%\nমুদি দোকান ও স্থায়ী ব্যবসায়ীদের উপযোগী সহজ কিস্তি।',
                  LiquidGlassTheme.cyberCyan,
                ),
                _buildSchemeCard(
                  'মাসিক সঞ্চয় ও প্রজেক্ট লোন',
                  'মেয়াদ: ৬-১২ মাস • সুদ: ১৫%\nউদ্যোক্তা ও পাইকারি ব্যবসায়ীদের বড় অঙ্কের ঋণ।',
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
                    'আরও সেবা ও সেটিংস',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'টুলস, এনালিটিক্স ও সিস্টেম কন্ট্রোল',
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
                            'স্মার্ট কিস্তি ক্যালকুলেটর',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'ঋণ, সুদের হার ও কিস্তির পরিমাণ মুহূর্তেই গণনা করুন',
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
                            'আর্থিক স্টেটমেন্ট ও রিপোর্ট',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'বিতরণ, আদায় ও সার্বিক অগ্রগতির রিয়েল-টাইম রিপোর্ট',
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
                onTap: () => _showLoanSchemesDialog(context),
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
                        Icons.workspace_premium_rounded,
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
                            'ঋণ স্কিম ও প্যাকেজসমূহ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'দৈনিক, সাপ্তাহিক ও মাসিক স্কিমের শর্তাবলী ও বিবরণ',
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
                        Icons.cloud_sync_rounded,
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
                            'নিরাপদে সকল কিস্তির তথ্য JSON ফাইলে সেভ করুন',
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
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: LiquidGlassTheme.neonEmerald.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: LiquidGlassTheme.neonEmerald,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Kisti Seba (কিস্তি সেবা)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Package: com.kisti.seba • v1.0.0',
                              style: TextStyle(
                                color: LiquidGlassTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'আধুনিক ফিউচারিস্টিক লিকুইড গ্লাস এফেক্ট সহ পূর্ণাঙ্গ মাইক্রোফাইন্যান্স ও কিস্তি হিসাব ট্র্যাকার। সম্পূর্ণ অফলাইনে নিরাপদে কাজ করে।',
                      style: TextStyle(
                        color: LiquidGlassTheme.textSecondary,
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
