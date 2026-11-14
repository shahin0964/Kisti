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
  double _cashPrice = 45000;
  double _downPayment = 10000;
  int _durationMonths = 12;
  double _markupRate = 10; // percent
  String _productType = 'ফ্রিজ';

  String _formatCurrency(double amount) {
    final formatter = NumberFormat("#,##,##0", "en_US");
    return '৳ ${formatter.format(amount)}';
  }

  void _applyPreset(String type, double price, double down, int months, double markup) {
    setState(() {
      _productType = type;
      _cashPrice = price;
      _downPayment = down;
      _durationMonths = months;
      _markupRate = markup;
    });
  }

  @override
  Widget build(BuildContext context) {
    final financedAmount = (_cashPrice - _downPayment).clamp(0.0, double.infinity);
    final markupAmount = financedAmount * (_markupRate / 100);
    final totalInstallmentPrice = _cashPrice + markupAmount;
    final totalDueAfterDown = financedAmount + markupAmount;
    final monthlyInstallment = _durationMonths > 0
        ? (totalDueAfterDown / _durationMonths).ceilToDouble()
        : 0.0;

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
                      'পণ্য কিস্তি (EMI) ক্যালকুলেটর',
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
                              'প্রতি মাসের কিস্তির পরিমাণ',
                              style: TextStyle(
                                color: LiquidGlassTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatCurrency(monthlyInstallment),
                              style: const TextStyle(
                                color: LiquidGlassTheme.neonEmerald,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_durationMonths মাস মেয়াদ • $_productType স্কিম',
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
                                _buildSummaryCol('নগদ মূল্য', _formatCurrency(_cashPrice)),
                                _buildSummaryCol('ডাউন পেমেন্ট', _formatCurrency(_downPayment),
                                    color: LiquidGlassTheme.cyberCyan),
                                _buildSummaryCol('মোট কিস্তি মূল্য', _formatCurrency(totalInstallmentPrice),
                                    color: LiquidGlassTheme.amberGold),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryCol('কিস্তি মুনাফা', _formatCurrency(markupAmount),
                                    color: LiquidGlassTheme.electricViolet),
                                _buildSummaryCol('বাকি প্রদেয়', _formatCurrency(totalDueAfterDown),
                                    color: Colors.white),
                                _buildSummaryCol('মুনাফা হার', '${_markupRate.toInt()}%',
                                    color: LiquidGlassTheme.neonEmerald),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Product Quick Presets
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildPresetChip('📱 মোবাইল', 35000, 7000, 6, 8),
                            _buildPresetChip('🧊 ফ্রিজ', 52000, 12000, 12, 10),
                            _buildPresetChip('📺 স্মার্ট টিভি', 40000, 8000, 10, 10),
                            _buildPresetChip('❄️ এসি', 75000, 20000, 18, 12),
                            _buildPresetChip('🛵 বাইক', 160000, 40000, 24, 14),
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
                            // Cash Price Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'পণ্যের নগদ মূল্য',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(_cashPrice),
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
                                overlayColor: LiquidGlassTheme.neonEmerald.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _cashPrice,
                                min: 5000,
                                max: 200000,
                                divisions: 39,
                                onChanged: (val) {
                                  setState(() {
                                    _cashPrice = val;
                                    if (_downPayment > _cashPrice) {
                                      _downPayment = (_cashPrice * 0.2).roundToDouble();
                                    }
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Down Payment Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ডাউন পেমেন্ট (অগ্রিম)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${_formatCurrency(_downPayment)} (${((_downPayment / (_cashPrice > 0 ? _cashPrice : 1)) * 100).toInt()}%)',
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.cyberCyan,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: LiquidGlassTheme.cyberCyan,
                                thumbColor: Colors.white,
                                overlayColor: LiquidGlassTheme.cyberCyan.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _downPayment.clamp(0.0, _cashPrice),
                                min: 0,
                                max: _cashPrice,
                                divisions: 20,
                                onChanged: (val) => setState(() => _downPayment = val),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Duration Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'কিস্তির মেয়াদ (মাস)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$_durationMonths মাস',
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.amberGold,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: LiquidGlassTheme.amberGold,
                                thumbColor: Colors.white,
                                overlayColor: LiquidGlassTheme.amberGold.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _durationMonths.toDouble(),
                                min: 2,
                                max: 24,
                                divisions: 22,
                                onChanged: (val) => setState(() => _durationMonths = val.toInt()),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Markup Rate Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'কিস্তি অতিরিক্ত লাভ / মার্কআপ হার',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${_markupRate.toInt()}%',
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.electricViolet,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: LiquidGlassTheme.electricViolet,
                                thumbColor: Colors.white,
                                overlayColor: LiquidGlassTheme.electricViolet.withOpacity(0.2),
                              ),
                              child: Slider(
                                value: _markupRate,
                                min: 0,
                                max: 25,
                                divisions: 25,
                                onChanged: (val) => setState(() => _markupRate = val),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Installment Schedule Preview Card
                      LiquidGlassCard(
                        glowColor: LiquidGlassTheme.neonEmerald,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'কিস্তি পরিশোধ সময়সূচী (প্রথম ৩টি কিস্তি)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(
                              _durationMonths > 3 ? 3 : _durationMonths,
                              (idx) {
                                final dueMonth = DateTime.now().add(Duration(days: 30 * (idx + 1)));
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'কিস্তি #${idx + 1} (${DateFormat("MMM yyyy").format(dueMonth)})',
                                        style: const TextStyle(
                                          color: LiquidGlassTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(monthlyInstallment),
                                        style: const TextStyle(
                                          color: LiquidGlassTheme.neonEmerald,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  Widget _buildPresetChip(
      String label, double price, double down, int months, double markup) {
    final isSelected = _productType == label.split(' ').last;
    return GestureDetector(
      onTap: () => _applyPreset(label.split(' ').last, price, down, months, markup),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? LiquidGlassTheme.neonEmerald.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? LiquidGlassTheme.neonEmerald
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? LiquidGlassTheme.neonEmerald : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
}
