import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/kisti_storage.dart';
import '../services/ota_update_service.dart';
import '../models/customer.dart';
import '../models/sms_template.dart';
import '../theme/liquid_glass_theme.dart';
import '../widgets/liquid_glass.dart';
import 'kisti_calculator_screen.dart';

class MoreScreen extends StatefulWidget {
  final KistiStorage storage;

  const MoreScreen({super.key, required this.storage});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  ReleaseInfo? _latestRelease;
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _silentCheckUpdate();
  }

  Future<void> _silentCheckUpdate() async {
    final rel = await OtaUpdateService.checkLatestRelease();
    if (mounted) {
      setState(() {
        _latestRelease = rel;
      });
    }
  }

  // ==========================================
  // 1. BUSINESS INFORMATION DIALOG
  // ==========================================
  void _showBusinessInfoDialog(BuildContext context) {
    final storage = widget.storage;
    final nameCtrl = TextEditingController(text: storage.shopName);
    final propCtrl = TextEditingController(text: storage.proprietorName);
    final phoneCtrl = TextEditingController(text: storage.shopPhone);
    final addressCtrl = TextEditingController(text: storage.shopAddress);
    final tradeCtrl = TextEditingController(text: storage.tradeLicense);
    final sloganCtrl = TextEditingController(text: storage.shopSlogan);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.88,
            ),
            decoration: BoxDecoration(
              color: LiquidGlassTheme.bgDarkVoid.withOpacity(0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: LiquidGlassTheme.amberGold.withOpacity(0.4),
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
                          color: LiquidGlassTheme.amberGold.withOpacity(0.2),
                          border: Border.all(color: LiquidGlassTheme.amberGold),
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: LiquidGlassTheme.amberGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ব্যবসার তথ্য (Business Info)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'দোকানের প্রোফাইল, মোবাইল ও ঠিকানার খতিয়ান',
                              style: TextStyle(
                                color: LiquidGlassTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  _buildDialogInputField(
                    label: 'দোকান / শোরুমের নাম *',
                    hint: 'যেমন: মেসার্স ডিজিটাল ইলেকট্রনিক্স',
                    controller: nameCtrl,
                    icon: Icons.storefront_rounded,
                  ),
                  const SizedBox(height: 12),

                  _buildDialogInputField(
                    label: 'প্রোপাইটর / মালিকের নাম',
                    hint: 'মালিকের নাম লিখুন',
                    controller: propCtrl,
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 12),

                  _buildDialogInputField(
                    label: 'মোবাইল / যোগাযোগের নম্বর *',
                    hint: '০১৭১২-৩৪৫৬৭৮',
                    controller: phoneCtrl,
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  _buildDialogInputField(
                    label: 'শোরুমের ঠিকানা *',
                    hint: 'দোকানের সম্পূর্ণ ঠিকানা',
                    controller: addressCtrl,
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 12),

                  _buildDialogInputField(
                    label: 'ট্রেড লাইসেন্স / রেজিস্ট্রেশন নম্বর',
                    hint: 'TRD-XXXX/2026',
                    controller: tradeCtrl,
                    icon: Icons.verified_rounded,
                  ),
                  const SizedBox(height: 12),

                  _buildDialogInputField(
                    label: 'দোকানের স্লোগান / ক্যাচলাইন',
                    hint: 'সহজ কিস্তিতে পণ্য বিক্রয়ের বিশ্বস্ত প্রতিষ্ঠান',
                    controller: sloganCtrl,
                    icon: Icons.format_quote_rounded,
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: LiquidGlassButton(
                      text: 'ব্যবসার তথ্য সংরক্ষণ করুন',
                      icon: Icons.check_circle_rounded,
                      glowColor: LiquidGlassTheme.amberGold,
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final phone = phoneCtrl.text.trim();
                        final address = addressCtrl.text.trim();

                        if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('দোকানের নাম, মোবাইল ও ঠিকানা প্রদান করুন'),
                              backgroundColor: LiquidGlassTheme.sunsetCoral,
                            ),
                          );
                          return;
                        }

                        final nav = Navigator.of(sheetCtx);
                        await storage.updateBusinessInfo(
                          name: name,
                          proprietor: propCtrl.text.trim(),
                          phone: phone,
                          address: address,
                          tradeLicense: tradeCtrl.text.trim(),
                          slogan: sloganCtrl.text.trim(),
                        );
                        nav.pop();

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ব্যবসার তথ্য সফলভাবে সংরক্ষিত হয়েছে!'),
                            backgroundColor: LiquidGlassTheme.amberGold,
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
  }

  Widget _buildDialogInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white54, size: 18),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: LiquidGlassTheme.amberGold),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. AUTO SMS & REMINDERS HUB (SIM SELECT + 2 ADVANCE NOTICES + RECEIPTS)
  // ==========================================
  void _showAutoSmsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final storage = widget.storage;
            final isSmsOn = storage.isAutoSmsEnabled;
            final simSlot = storage.smsSimSlot;
            final onCollection = storage.smsOnCollection;
            final notice1 = storage.smsNotice1Days;
            final notice2 = storage.smsNotice2Days;
            final templates = SmsTemplate.defaultTemplates;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: LiquidGlassCard(
                borderRadius: 24,
                glowColor: LiquidGlassTheme.cyberCyan,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: LiquidGlassTheme.cyberCyan.withOpacity(0.2),
                              border: Border.all(color: LiquidGlassTheme.cyberCyan),
                            ),
                            child: const Icon(
                              Icons.sms_rounded,
                              color: LiquidGlassTheme.cyberCyan,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'অটো এসএমএস ও কিস্তি তাগাদা',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'সিম নির্বাচন, কিস্তি রসিদ ও ২টি আগাম তাগাদা',
                                  style: TextStyle(
                                    color: LiquidGlassTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Auto SMS Master Switch
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSmsOn
                                ? LiquidGlassTheme.cyberCyan.withOpacity(0.35)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'অটো এসএমএস সিস্টেম',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSmsOn ? 'সক্রিয় (Active)' : 'নিষ্ক্রিয় (Disabled)',
                                  style: TextStyle(
                                    color: isSmsOn
                                        ? LiquidGlassTheme.cyberCyan
                                        : Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isSmsOn,
                              activeColor: LiquidGlassTheme.cyberCyan,
                              onChanged: (val) async {
                                await storage.setAutoSmsEnabled(val);
                                setDialogState(() {});
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // SIM Slot Selector
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'এসএমএস পাঠানোর সিম নির্বাচন (SIM Slot):',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: ['সিম ১ (SIM 1)', 'সিম ২ (SIM 2)'].map((slot) {
                                final isSel = simSlot == slot;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      await storage.setSmsSimSlot(slot);
                                      setDialogState(() {});
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSel
                                            ? LiquidGlassTheme.cyberCyan.withOpacity(0.22)
                                            : Colors.white.withOpacity(0.04),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSel
                                              ? LiquidGlassTheme.cyberCyan
                                              : Colors.white12,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.sim_card_rounded,
                                            size: 16,
                                            color: isSel ? LiquidGlassTheme.cyberCyan : Colors.white60,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            slot,
                                            style: TextStyle(
                                              color: isSel ? Colors.white : Colors.white70,
                                              fontSize: 11,
                                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Trigger 1: Auto SMS on Collection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'কিস্তি দিলে অটো এসএমএস রসিদ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'কিস্তি জমা নেওয়ার সাথে সাথে গ্রাহকের মোবাইলে ডিজিটাল রসিদ পাঠানো',
                                    style: TextStyle(
                                      color: LiquidGlassTheme.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: onCollection,
                              activeColor: LiquidGlassTheme.neonEmerald,
                              onChanged: (val) async {
                                await storage.setSmsOnCollection(val);
                                setDialogState(() {});
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Trigger 2: Two Advance Notice SMS
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'কিস্তির তারিখের পূর্বে ২টি আগাম তাগাদা এসএমএস:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '১ম এসএমএস: কিস্তির $notice1 দিন পূর্বে • ২য় এসএমএস: কিস্তির $notice2 দিন পূর্বে (সকাল ১০:০০ টায়)',
                              style: const TextStyle(
                                color: LiquidGlassTheme.textSecondary,
                                fontSize: 10.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: LiquidGlassTheme.amberGold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '১ম রিমাইন্ডার: $notice1 দিন আগে',
                                    style: const TextStyle(color: LiquidGlassTheme.amberGold, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: LiquidGlassTheme.sunsetCoral.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '২য় রিমাইন্ডার: $notice2 দিন আগে',
                                    style: const TextStyle(color: LiquidGlassTheme.sunsetCoral, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'রেডিমেড বাংলা এসএমএস টেমপ্লেটসমূহ:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Template Cards
                      ...templates.map((tpl) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tpl.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: LiquidGlassTheme.cyberCyan.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tpl.tag,
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
                                tpl.description,
                                style: const TextStyle(
                                  color: LiquidGlassTheme.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Text(
                                  tpl.content,
                                  style: const TextStyle(
                                    color: LiquidGlassTheme.textSecondary,
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: LiquidGlassTheme.cyberCyan,
                                      side: BorderSide(color: LiquidGlassTheme.cyberCyan.withOpacity(0.4)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      minimumSize: Size.zero,
                                    ),
                                    icon: const Icon(Icons.person_pin_rounded, size: 14),
                                    label: const Text('গ্রাহক সিলেক্ট করে তৈরি', style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      _showPersonalizeSmsDialog(context, tpl);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white70),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'টেমপ্লেট কপি করুন',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: tpl.content));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('টেমপ্লেট কপি হয়েছে: ${tpl.title}'),
                                        ),
                                      );
                                    },
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
          },
        );
      },
    );
  }

  void _showPersonalizeSmsDialog(BuildContext context, SmsTemplate template) {
    Customer? selectedCustomer;
    if (widget.storage.customers.isNotEmpty) {
      selectedCustomer = widget.storage.customers.first;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            String previewText = selectedCustomer != null
                ? widget.storage.personalizeSmsTemplate(template, selectedCustomer!)
                : template.content;

            return AlertDialog(
              backgroundColor: LiquidGlassTheme.bgSurfaceElevated,
              title: const Text('গ্রাহকভিত্তিক ব্যক্তিগত এসএমএস', style: TextStyle(color: Colors.white, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('গ্রাহক নির্বাচন করুন:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  if (widget.storage.customers.isEmpty)
                    const Text('কোনো গ্রাহক যোগ করা নেই।', style: TextStyle(color: Colors.white38, fontSize: 12))
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCustomer?.id,
                          isExpanded: true,
                          dropdownColor: LiquidGlassTheme.bgSurfaceElevated,
                          items: widget.storage.customers.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(
                                '${c.name} (${c.productName} • ${c.phone})',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedCustomer = widget.storage.getCustomerById(val);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text('এসএমএস প্রিভিউ:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: LiquidGlassTheme.cyberCyan.withOpacity(0.3)),
                    ),
                    child: Text(
                      previewText,
                      style: const TextStyle(color: LiquidGlassTheme.cyberCyan, fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('বন্ধ', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: LiquidGlassTheme.cyberCyan),
                  icon: const Icon(Icons.copy_rounded, size: 14, color: Colors.black),
                  label: const Text('এসএমএস কপি করুন', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: previewText));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${selectedCustomer?.name ?? "গ্রাহকের"} জন্য এসএমএস কপি হয়েছে!'),
                        backgroundColor: LiquidGlassTheme.cyberCyan,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 3. OFFLINE AUTO BACKUP SYSTEM (11:30 PM DAILY)
  // ==========================================
  void _showOfflineBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final storage = widget.storage;
            final isAutoOn = storage.isAutoBackupEnabled;
            final lastBackup = storage.lastAutoBackupTime;
            final lastBackupStr = lastBackup != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(lastBackup)
                : 'এখনও ব্যাকআপ নেওয়া হয়নি';

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: LiquidGlassCard(
                borderRadius: 20,
                glowColor: LiquidGlassTheme.electricViolet,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: LiquidGlassTheme.electricViolet.withOpacity(0.2),
                              border: Border.all(color: LiquidGlassTheme.electricViolet),
                            ),
                            child: const Icon(
                              Icons.cloud_sync_rounded,
                              color: LiquidGlassTheme.electricViolet,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'অফলাইন অটো ব্যাকআপ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'প্রতিদিন রাত ১১:৩০ টায় অফলাইন ব্যাকআপ',
                                  style: TextStyle(
                                    color: LiquidGlassTheme.textSecondary,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white60, size: 18),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isAutoOn
                                ? LiquidGlassTheme.neonEmerald.withOpacity(0.3)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'প্রতিদিনের অটো ব্যাকআপ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAutoOn
                                      ? 'সক্রিয় • প্রতিদিন রাত ১১:৩০ PM'
                                      : 'নিষ্ক্রিয় (অফ করা আছে)',
                                  style: TextStyle(
                                    color: isAutoOn
                                        ? LiquidGlassTheme.neonEmerald
                                        : Colors.white38,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: isAutoOn,
                              activeColor: LiquidGlassTheme.neonEmerald,
                              onChanged: (val) async {
                                await storage.setAutoBackupEnabled(val);
                                setDialogState(() {});
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('নির্ধারিত সময়:', 'প্রতিদিন রাত ১১:৩০ PM'),
                            const SizedBox(height: 5),
                            _buildInfoRow('সর্বশেষ ব্যাকআপ:', lastBackupStr),
                            const SizedBox(height: 5),
                            _buildInfoRow('ব্যাকআপ স্টোরেজ:', 'ডিভাইস লোকাল স্টোরেজ'),
                            const SizedBox(height: 5),
                            _buildInfoRow(
                              'বর্তমান রেকর্ড:',
                              'গ্রাহক: ${storage.customers.length} | কিস্তি: ${storage.collections.length} | খরচ: ${storage.expenses.length}',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      LiquidGlassButton(
                        text: 'অফলাইন ব্যাকআপ নিন',
                        icon: Icons.save_rounded,
                        glowColor: LiquidGlassTheme.electricViolet,
                        onPressed: () async {
                          final jsonStr = await storage.createOfflineBackup();
                          Clipboard.setData(ClipboardData(text: jsonStr));
                          setDialogState(() {});
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('অফলাইন ব্যাকআপ তৈরি ও ক্লিপবোর্ডে কপি সম্পন্ন হয়েছে!'),
                              backgroundColor: LiquidGlassTheme.electricViolet,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: LiquidGlassButton(
                              text: 'রিস্টোর করুন',
                              icon: Icons.restore_rounded,
                              isSecondary: true,
                              height: 40,
                              onPressed: () => _showRestoreDialog(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LiquidGlassButton(
                              text: 'কোড কপি',
                              icon: Icons.copy_rounded,
                              isSecondary: true,
                              height: 40,
                              onPressed: () async {
                                final snap = await storage.getSavedOfflineBackup() ??
                                    await storage.createOfflineBackup();
                                Clipboard.setData(ClipboardData(text: snap));
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('সম্পূর্ণ JSON ব্যাকআপ কোড কপি করা হয়েছে!'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
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

  void _showRestoreDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LiquidGlassTheme.bgSurfaceElevated,
        title: const Text('ব্যাকআপ রিস্টোর করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'সংরক্ষিত ব্যাকআপ কোড (JSON) নিচে পেস্ট করুন অথবা সরাসরি ডিভাইসের অফলাইন স্ন্যাপশট থেকে রিস্টোর করতে নিচের বাটনে চাপ দিন:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'ব্যাকআপ কোড পেস্ট করুন (ঐচ্ছিক)...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: LiquidGlassTheme.electricViolet),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final input = textController.text.trim();
              final success = await widget.storage.restoreFromOfflineBackup(
                input.isNotEmpty ? input : null,
              );
              nav.pop();

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'সফলভাবে সকল ডেটা রিস্টোর সম্পন্ন হয়েছে!'
                        : 'রিস্টোর ব্যর্থ হয়েছে! সঠিক ব্যাকআপ ফাইল যাচাই করুন।',
                  ),
                  backgroundColor: success ? LiquidGlassTheme.neonEmerald : LiquidGlassTheme.sunsetCoral,
                ),
              );
            },
            child: const Text('রিস্টোর নিশ্চিত করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. APP OTA UPDATE (GITHUB CONNECTED + PERMANENT NOTES)
  // ==========================================
  void _showOtaUpdateDialog(BuildContext context) {
    bool isDownloading = false;
    double downloadProgress = 0.0;
    String downloadStatus = '';
    String? downloadedFilePath;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final rel = _latestRelease;
            final isUpToDate = rel != null && !rel.hasUpdate;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: LiquidGlassCard(
                borderRadius: 24,
                glowColor: rel?.hasUpdate == true
                    ? LiquidGlassTheme.neonEmerald
                    : LiquidGlassTheme.cyberCyan,
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (rel?.hasUpdate == true
                                      ? LiquidGlassTheme.neonEmerald
                                      : LiquidGlassTheme.cyberCyan)
                                  .withOpacity(0.2),
                              border: Border.all(
                                color: rel?.hasUpdate == true
                                    ? LiquidGlassTheme.neonEmerald
                                    : LiquidGlassTheme.cyberCyan,
                              ),
                            ),
                            child: Icon(
                              rel?.hasUpdate == true
                                  ? Icons.system_update_rounded
                                  : Icons.verified_rounded,
                              color: rel?.hasUpdate == true
                                  ? LiquidGlassTheme.neonEmerald
                                  : LiquidGlassTheme.cyberCyan,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'অ্যাপ OTA আপডেট (GitHub)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'বর্তমান ভার্সন: ${OtaUpdateService.currentVersion}',
                                  style: TextStyle(
                                    color: LiquidGlassTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isCheckingUpdate)
                        Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: const Column(
                            children: [
                              CircularProgressIndicator(color: LiquidGlassTheme.cyberCyan),
                              SizedBox(height: 12),
                              Text(
                                'GitHub রিলিজ চেক করা হচ্ছে...',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      else if (isUpToDate || rel == null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: LiquidGlassTheme.neonEmerald.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: LiquidGlassTheme.neonEmerald.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: LiquidGlassTheme.neonEmerald, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'আপনার অ্যাপ সম্পূর্ণ আপ-টু-ডেট!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'আপনি সর্বশেষ সংস্করণ ${OtaUpdateService.currentVersion} ব্যবহার করছেন।',
                                style: TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 11),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'বর্তমান ভার্সনের রিলিজ নোট (কি ফিক্স ও কি যোগ হলো):',
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                constraints: const BoxConstraints(maxHeight: 180),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const SingleChildScrollView(
                                  child: Text(
                                    OtaUpdateService.currentReleaseChangelog,
                                    style: TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 11, height: 1.4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              LiquidGlassButton(
                                text: 'আবার চেক করুন',
                                icon: Icons.sync_rounded,
                                isSecondary: true,
                                height: 40,
                                onPressed: () async {
                                  setDialogState(() => _isCheckingUpdate = true);
                                  final newRel = await OtaUpdateService.checkLatestRelease();
                                  setDialogState(() {
                                    _latestRelease = newRel;
                                    _isCheckingUpdate = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Newer Version Available!
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: LiquidGlassTheme.neonEmerald.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: LiquidGlassTheme.neonEmerald.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.new_releases_rounded, color: LiquidGlassTheme.neonEmerald, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'নতুন ভার্সন: ${rel.tagName}',
                                        style: const TextStyle(
                                          color: LiquidGlassTheme.neonEmerald,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (rel.formattedSize.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        rel.formattedSize,
                                        style: const TextStyle(color: Colors.white, fontSize: 11),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                rel.releaseTitle,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              const Text('রিলিজ নোট (নতুন ফিচার ও পরিবর্তন):', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              Container(
                                constraints: const BoxConstraints(maxHeight: 140),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SingleChildScrollView(
                                  child: Text(
                                    rel.releaseNotes,
                                    style: const TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 11, height: 1.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (isDownloading) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    downloadStatus.isNotEmpty ? downloadStatus : 'ডাউনলোড হচ্ছে...',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  Text(
                                    '${(downloadProgress * 100).toInt()}%',
                                    style: const TextStyle(color: LiquidGlassTheme.neonEmerald, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: downloadProgress,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(LiquidGlassTheme.neonEmerald),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ] else if (downloadedFilePath != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: LiquidGlassTheme.neonEmerald.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: LiquidGlassTheme.neonEmerald),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '✅ ডাউনলোড সম্পন্ন হয়েছে!',
                                  style: TextStyle(color: LiquidGlassTheme.neonEmerald, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ফাইল লোকেশন: $downloadedFilePath',
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                LiquidGlassButton(
                                  text: 'পাথ কপি করুন ও ইন্সটল করুন',
                                  icon: Icons.install_mobile_rounded,
                                  glowColor: LiquidGlassTheme.neonEmerald,
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: downloadedFilePath!));
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('APK ডাউনলোড হয়েছে: $downloadedFilePath'),
                                        backgroundColor: LiquidGlassTheme.neonEmerald,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          LiquidGlassButton(
                            text: '🚀 অ্যাপের মধ্যেই আপডেট ডাউনলোড করুন',
                            icon: Icons.download_rounded,
                            glowColor: LiquidGlassTheme.neonEmerald,
                            onPressed: () async {
                              setDialogState(() {
                                isDownloading = true;
                                downloadProgress = 0.0;
                                downloadStatus = 'ডাউনলোড শুরু হচ্ছে...';
                              });

                              final path = await OtaUpdateService.downloadUpdateApk(
                                rel.apkDownloadUrl,
                                onProgress: (progress, received, total) {
                                  setDialogState(() {
                                    downloadProgress = progress;
                                    downloadStatus =
                                        'ডাউনলোড হচ্ছে: ${(received / (1024 * 1024)).toStringAsFixed(1)}MB / ${(total / (1024 * 1024)).toStringAsFixed(1)}MB';
                                  });
                                },
                              );

                              setDialogState(() {
                                isDownloading = false;
                                downloadedFilePath = path;
                              });
                            },
                          ),
                        ],
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

  // ==========================================
  // 5. THEME SELECTION MODAL
  // ==========================================
  void _showThemeSelectionDialog(BuildContext context) {
    final storage = widget.storage;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final activeId = storage.themeId;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: LiquidGlassCard(
                borderRadius: 20,
                glowColor: LiquidGlassTheme.neonEmerald,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: LiquidGlassTheme.neonEmerald.withOpacity(0.2),
                              border: Border.all(color: LiquidGlassTheme.neonEmerald),
                            ),
                            child: const Icon(
                              Icons.palette_rounded,
                              color: LiquidGlassTheme.neonEmerald,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'অ্যাপ থিম ও রঙ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'পছন্দের কালার প্যালেট নির্বাচন করুন',
                                  style: TextStyle(
                                    color: LiquidGlassTheme.textSecondary,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white60, size: 18),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Presets List
                      ...LiquidGlassTheme.presets.map((preset) {
                        final isSelected = activeId == preset.id;
                        return GestureDetector(
                          onTap: () async {
                            await storage.setThemeId(preset.id);
                            setDialogState(() {});
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('থিম পরিবর্তিত হয়েছে: ${preset.name}'),
                                backgroundColor: preset.neonEmerald,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? preset.neonEmerald.withOpacity(0.14)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? preset.neonEmerald
                                    : Colors.white.withOpacity(0.10),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: preset.neonEmerald.withOpacity(0.25),
                                        blurRadius: 10,
                                        spreadRadius: -2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // Preset Icon
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: preset.bgCard,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: preset.neonEmerald.withOpacity(0.4)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      preset.icon,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Preset Name & Subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            preset.name,
                                            style: TextStyle(
                                              color: isSelected ? preset.neonEmerald : Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (isSelected) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: preset.neonEmerald.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: preset.neonEmerald.withOpacity(0.5)),
                                              ),
                                              child: Text(
                                                'সক্রিয়',
                                                style: TextStyle(
                                                  color: preset.neonEmerald,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        preset.subtitle,
                                        style: const TextStyle(
                                          color: LiquidGlassTheme.textSecondary,
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Color preview dots
                                Row(
                                  children: [
                                    _buildColorDot(preset.neonEmerald),
                                    const SizedBox(width: 3),
                                    _buildColorDot(preset.cyberCyan),
                                    const SizedBox(width: 3),
                                    _buildColorDot(preset.electricViolet),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 6),

                      // Done Button
                      SizedBox(
                        width: double.infinity,
                        child: LiquidGlassButton(
                          text: 'সম্পন্ন',
                          icon: Icons.check_circle_rounded,
                          glowColor: LiquidGlassTheme.neonEmerald,
                          height: 40,
                          onPressed: () => Navigator.pop(ctx),
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

  Widget _buildColorDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. APP ABOUT MODAL ("choto page show korbe")
  // ==========================================
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: LiquidGlassCard(
          borderRadius: 20,
          glowColor: LiquidGlassTheme.neonEmerald,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [LiquidGlassTheme.cyberCyan, LiquidGlassTheme.neonEmerald],
                  ),
                  boxShadow: LiquidGlassTheme.neonGlow(LiquidGlassTheme.neonEmerald, intensity: 0.3),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.storefront_rounded, color: Colors.black, size: 34),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kisti (কিস্তি সেবা)',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              const Text(
                'পণ্য কিস্তি ম্যানেজমেন্ট প্ল্যাটফর্ম',
                style: TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: LiquidGlassTheme.neonEmerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LiquidGlassTheme.neonEmerald.withOpacity(0.4)),
                ),
                child: const Text(
                  'ভার্সন v1.0.7 (Build 8)',
                  style: TextStyle(color: LiquidGlassTheme.neonEmerald, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Text(
                  'ইলেকট্রনিক্স শো-রুম, মোবাইল শপ ও হোম অ্যাপ্লায়েন্সের পণ্য সহজ কিস্তিতে বিক্রয়, লাভ-ক্ষতি, অফলাইন অটো ব্যাকআপ, অটো এসএমএস ও গিটহাব OTA আপডেটের পূর্ণাঙ্গ সমাধান।',
                  style: TextStyle(color: LiquidGlassTheme.textMuted, fontSize: 11, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),
              _buildInfoRow('প্যাকেজ নাম:', 'com.kisti.seba'),
              const SizedBox(height: 6),
              _buildInfoRow('ডিজাইন স্টাইল:', 'ফিউচারিস্টিক লিকুইড গ্লাস'),
              const SizedBox(height: 6),
              _buildInfoRow('প্ল্যাটফর্ম:', 'Flutter Android & Termux'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: LiquidGlassButton(
                  text: 'বন্ধ করুন',
                  icon: Icons.close_rounded,
                  isSecondary: true,
                  height: 44,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: LiquidGlassTheme.textSecondary, fontSize: 11)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showClearDataConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: LiquidGlassTheme.bgSurfaceElevated,
          title: const Text('সব ডেটা মুছে ফেলবেন?', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: const Text(
            'সতর্কতা: এটি শো-রুমের সকল গ্রাহক ও কিস্তি আদায়ের রেকর্ড স্থায়ীভাবে মুছে ফেলবে। এটি পুনরুদ্ধার করা সম্ভব নয়।',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: LiquidGlassTheme.sunsetCoral),
              onPressed: () async {
                final nav = Navigator.of(ctx);
                await widget.storage.clearAllData();
                nav.pop();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('সকল ডেটা সফলভাবে মুছে ফেলা হয়েছে!'),
                    backgroundColor: LiquidGlassTheme.sunsetCoral,
                  ),
                );
              },
              child: const Text('হ্যাঁ, সব মুছুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rel = _latestRelease;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // PINNED TOP HEADER (Never scrolls away!)
            _buildPinnedHeader(),

            // SCROLLABLE MENU LIST ONLY
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. EMI Calculator Card
                    _buildMenuCard(
                      title: 'পণ্য কিস্তি (EMI) ক্যালকুলেটর',
                      subtitle: 'মোবাইল, ফ্রিজ, টিভি কিস্তির নগদ মূল্য ও ডাউন পেমেন্ট হিসাব',
                      icon: Icons.calculate_rounded,
                      color: LiquidGlassTheme.cyberCyan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KistiCalculatorScreen(),
                          ),
                        );
                      },
                    ),

                    // 2. Business Information Card (NEW!)
                    _buildMenuCard(
                      title: 'ব্যবসার তথ্য ও প্রোফাইল',
                      subtitle: 'দোকান/শোরুমের নাম, প্রোপাইটর, মোবাইল ও ঠিকানা',
                      icon: Icons.store_mall_directory_rounded,
                      color: LiquidGlassTheme.amberGold,
                      onTap: () => _showBusinessInfoDialog(context),
                    ),

                    // 3. Theme & Color Customization (NEW!)
                    _buildMenuCard(
                      title: 'অ্যাপ থিম ও কালার (App Theme)',
                      subtitle: 'বর্তমান: ${LiquidGlassTheme.currentPreset.name} • ৬টি আকর্ষণীয় থিম',
                      icon: Icons.palette_rounded,
                      color: LiquidGlassTheme.neonEmerald,
                      badge: LiquidGlassTheme.currentPreset.icon,
                      onTap: () => _showThemeSelectionDialog(context),
                    ),

                    // 3. Auto SMS & Reminders (UPGRADED!)
                    _buildMenuCard(
                      title: 'অটো এসএমএস ও কিস্তি তাগাদা',
                      subtitle: 'সিম সিলেকশন, কিস্তি রসিদ ও ২টি আগাম তাগাদা এসএমএস',
                      icon: Icons.sms_rounded,
                      color: LiquidGlassTheme.cyberCyan,
                      onTap: () => _showAutoSmsDialog(context),
                    ),

                    // 4. Offline Auto Backup System (11:30 PM)
                    _buildMenuCard(
                      title: 'অফলাইন অটো ব্যাকআপ সিস্টেম',
                      subtitle: 'প্রতিদিন রাত ১১:৩০ টায় অটো ব্যাকআপ • সম্পূর্ণ অফলাইন সুরক্ষিত',
                      icon: Icons.cloud_sync_rounded,
                      color: LiquidGlassTheme.electricViolet,
                      onTap: () => _showOfflineBackupDialog(context),
                    ),

                    // 5. App OTA Update (GitHub Connected)
                    _buildMenuCard(
                      title: 'অ্যাপ OTA আপডেট (GitHub)',
                      subtitle: rel?.hasUpdate == true
                          ? 'নতুন ভার্সন ${rel?.tagName} উপলভ্য • ট্যাপ করে ইন-অ্যাপ ডাউনলোড করুন'
                          : 'গিটহাব থেকে সরাসরি আপডেট • রিলিজ নোট পড়ার সুবিধা',
                      icon: rel?.hasUpdate == true
                          ? Icons.system_update_rounded
                          : Icons.verified_rounded,
                      color: rel?.hasUpdate == true
                          ? LiquidGlassTheme.neonEmerald
                          : LiquidGlassTheme.cyberCyan,
                      badge: rel?.hasUpdate == true ? 'আপডেট!' : null,
                      onTap: () => _showOtaUpdateDialog(context),
                    ),

                    // 6. App About Popup Modal (NEW!)
                    _buildMenuCard(
                      title: 'অ্যাপ পরিচিতি ও সিস্টেম তথ্য',
                      subtitle: 'ভার্সন v1.0.7 • ডেভেলপার ও সিস্টেম স্পেসিফিকেশন',
                      icon: Icons.info_outline_rounded,
                      color: LiquidGlassTheme.neonEmerald,
                      onTap: () => _showAboutDialog(context),
                    ),

                    // 7. Reset All Data
                    _buildMenuCard(
                      title: 'সকল ডেটা রিসেট ও মুছুন',
                      subtitle: 'শো-রুমের সমস্ত রেকর্ড মুছে নতুনভাবে শুরু করুন',
                      icon: Icons.delete_forever_rounded,
                      color: LiquidGlassTheme.sunsetCoral,
                      onTap: () => _showClearDataConfirm(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LiquidGlassTheme.neonEmerald.withOpacity(0.18),
              border: Border.all(color: LiquidGlassTheme.neonEmerald.withOpacity(0.5)),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: LiquidGlassTheme.neonEmerald,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আরও সুবিধাসমূহ ও সেটিংস',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ব্যবসার তথ্য, অটো এসএমএস, ব্যাকআপ ও OTA আপডেট',
                  style: TextStyle(
                    color: LiquidGlassTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return LiquidGlassCard(
      glowColor: color,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
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
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.4)),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: LiquidGlassTheme.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white30,
            size: 14,
          ),
        ],
      ),
    );
  }
}
