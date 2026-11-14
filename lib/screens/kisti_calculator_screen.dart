import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/liquid_glass_theme.dart';
import '../widgets/liquid_glass.dart';

class KistiCalculatorScreen extends StatefulWidget {
  const KistiCalculatorScreen({super.key});

  @override
  State<KistiCalculatorScreen> createState() => _KistiCalculatorScreenState();
}

class _KistiCalculatorScreenState extends State<KistiCalculatorScreen> {
  double _principal = 30000;
  double _interestRate = 10;
  int _installments = 25;
  String _frequency = 'দৈনিক'; // 'দৈনিক', 'সাপ্তাহিক', 'মাসিক'

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    return '৳ ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final profit = _principal * (_interestRate / 100);
    final totalPayable = _principal + profit;
    final installmentAmount =
        _installments > 0 ? (totalPayable / _installments).ceilToDouble() : 0.0;

    return Scaffold(
      backgroundColor: LiquidGlassTheme.bgDarkVoid,
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'স্মার্ট কিস্তি ক্যালকুলেটর',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  child: Column(
                    children: [
                      // Calculation Result Highlight Card
                      LiquidGlassCard(
                        glowColor: LiquidGlassTheme.neonEmerald,
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            const Text(
                              'প্রতি কিস্তির পরিমাণ',
                              style: TextStyle(
                                color: LiquidGlassTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatCurrency(installmentAmount),
                              style: const TextStyle(
                                color: LiquidGlassTheme.neonEmerald,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_frequency কিস্তি • মোট $_installments টি',
                              style: const TextStyle(
                                color: LiquidGlassTheme.cyberCyan,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryCol('আসল ঋণ', _formatCurrency(_principal)),
                                _buildSummaryCol('মোট মুনাফা', _formatCurrency(profit),
                                    color: LiquidGlassTheme.amberGold),
                                _buildSummaryCol('মোট প্রদেয়', _formatCurrency(totalPayable),
                                    color: Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Input Sliders Card
                      LiquidGlassCard(
                        glowColor: LiquidGlassTheme.cyberCyan,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Principal Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'আসল ঋণের পরিমাণ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(_principal),
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.neonEmerald,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: LiquidGlassTheme.neonEmerald,
                                thumbColor: Colors.white,
                                overlayColor:
                                    LiquidGlassTheme.neonEmerald.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _principal,
                                min: 5000,
                                max: 200000,
                                divisions: 39,
                                onChanged: (val) =>
                                    setState(() => _principal = val),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Interest Rate Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'সুদ / মুনাফার হার',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${_interestRate.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.amberGold,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: LiquidGlassTheme.amberGold,
                                thumbColor: Colors.white,
                                overlayColor:
                                    LiquidGlassTheme.amberGold.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _interestRate,
                                min: 0,
                                max: 30,
                                divisions: 60,
                                onChanged: (val) =>
                                    setState(() => _interestRate = val),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Total Installments Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'কিস্তির সংখ্যা',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$_installments টি',
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.cyberCyan,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: LiquidGlassTheme.cyberCyan,
                                thumbColor: Colors.white,
                                overlayColor:
                                    LiquidGlassTheme.cyberCyan.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _installments.toDouble(),
                                min: 5,
                                max: 100,
                                divisions: 95,
                                onChanged: (val) =>
                                    setState(() => _installments = val.toInt()),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Frequency Selector
                            const Text(
                              'কিস্তির সময়কাল',
                              style: TextStyle(
                                color: LiquidGlassTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: ['দৈনিক', 'সাপ্তাহিক', 'মাসিক'].map((f) {
                                final isSel = _frequency == f;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _frequency = f),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSel
                                            ? LiquidGlassTheme.cyberCyan
                                                .withOpacity(0.25)
                                            : Colors.white.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(12),
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
                                              ? Colors.white
                                              : Colors.white70,
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Quick Scheme Recommendations
                      LiquidGlassCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'জনপ্রিয় কিস্তি স্কিমসমূহ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildPresetTile('ক্ষুদ্র ব্যবসা দৈনিক স্কিম', '৳২০,০০০ • ২০ কিস্তি • দৈনিক ১,১০০', () {
                              setState(() {
                                _principal = 20000;
                                _interestRate = 10;
                                _installments = 20;
                                _frequency = 'দৈনিক';
                              });
                            }),
                            _buildPresetTile('দোকান সাপ্তাহিক স্কিম', '৳৫০,০০০ • ২৫ কিস্তি • সাপ্তাহিক ২,২০০', () {
                              setState(() {
                                _principal = 50000;
                                _interestRate = 10;
                                _installments = 25;
                                _frequency = 'সাপ্তাহিক';
                              });
                            }),
                            _buildPresetTile('মাসিক মাঝারি স্কিম', '৳১,০০,০০০ • ১২ কিস্তি • মাসিক ৯,৫০০', () {
                              setState(() {
                                _principal = 100000;
                                _interestRate = 14;
                                _installments = 12;
                                _frequency = 'মাসিক';
                              });
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCol(String label, String value, {Color? color}) {
    return Column(
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetTile(String title, String desc, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: LiquidGlassTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.touch_app_rounded,
                size: 18,
                color: LiquidGlassTheme.cyberCyan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
