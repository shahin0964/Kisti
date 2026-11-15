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
  // 1. OFFLINE AUTO BACKUP SYSTEM (11:30 PM DAILY)
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
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: LiquidGlassCard(
                borderRadius: 24,
                glowColor: LiquidGlassTheme.electricViolet,
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
                              color: LiquidGlassTheme.electricViolet.withOpacity(0.2),
                              border: Border.all(color: LiquidGlassTheme.electricViolet),
                            ),
                            child: const Icon(
                              Icons.cloud_sync_rounded,
                              color: LiquidGlassTheme.electricViolet,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'অফলাইন অটো ব্যাকআপ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'প্রতিদিন রাত ১১:৩০ টায় অফলাইন ব্যাকআপ',
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

                      // Auto Backup Switch Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
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
                                    fontSize: 13,
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
                                    fontSize: 11,
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

                      const SizedBox(height: 12),

                      // Status Details
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('নির্ধারিত সময়:', 'প্রতিদিন রাত ১১:৩০ PM'),
                            const SizedBox(height: 6),
                            _buildInfoRow('সর্বশেষ ব্যাকআপ:', lastBackupStr),
                            const SizedBox(height: 6),
                            _buildInfoRow('ব্যাকআপ স্টোরেজ:', 'ডিভাইসের নিজস্ব অফলাইন মেমোরি'),
                            const SizedBox(height: 6),
                            _buildInfoRow(
                              'বর্তমান রেকর্ড:',
                              'গ্রাহক: ${storage.customers.length} | কিস্তি: ${storage.collections.length} | খরচ: ${storage.expenses.length}',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action Buttons
                      LiquidGlassButton(
                        text: '📥 এখনই অফলাইন ব্যাকআপ নিন',
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

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: LiquidGlassButton(
                              text: '📤 ব্যাকআপ রিস্টোর',
                              icon: Icons.restore_rounded,
                              isSecondary: true,
                              height: 46,
                              onPressed: () => _showRestoreDialog(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LiquidGlassButton(
                              text: '📋 কোড কপি',
                              icon: Icons.copy_rounded,
                              isSecondary: true,
                              height: 46,
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
              'আগের সংরক্ষিত ব্যাকআপ কোড (JSON) নিচে পেস্ট করুন অথবা সরাসরি ডিভাইসের অফলাইন স্ন্যাপশট থেকে রিস্টোর করতে নিচের বাটনে চাপ দিন:',
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
  // 2. AUTO SMS & REMINDERS HUB (৫+ বাংলা টেমপ্লেট)
  // ==========================================
  void _showAutoSmsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final storage = widget.storage;
            final isSmsOn = storage.isAutoSmsEnabled;
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
                                  'অটো এসএমএস ও তাগাদা',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'কিস্তির তাগাদা ও ৫+ রেডিমেড বাংলা টেমপ্লেট',
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
                      const SizedBox(height: 14),

                      // Auto SMS Switch Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSmsOn
                                ? LiquidGlassTheme.cyberCyan.withOpacity(0.3)
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
                                  'অটো এসএমএস রিমাইন্ডার',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSmsOn
                                      ? 'সক্রিয় • কিস্তির দিন সকাল ১০:০০ টায়'
                                      : 'নিষ্ক্রিয় (বন্ধ করা আছে)',
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
                                  // Pick customer & generate
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
                                  // Copy template
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
  // 3. APP OTA UPDATE (GITHUB CONNECTED)
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'অ্যাপ OTA আপডেট (GitHub)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'বর্তমান ভার্সন: ${OtaUpdateService.currentVersion}',
                                  style: const TextStyle(
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
                      else if (rel == null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'আপডেট তথ্য লোড করা যায়নি। ইন্টারনেট সংযোগ চেক করুন।',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              LiquidGlassButton(
                                text: 'পুনরায় চেষ্টা করুন',
                                icon: Icons.refresh_rounded,
                                isSecondary: true,
                                height: 42,
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
                      else if (isUpToDate)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: LiquidGlassTheme.neonEmerald.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: LiquidGlassTheme.neonEmerald.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: LiquidGlassTheme.neonEmerald,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'আপনার অ্যাপ সম্পূর্ণ আপ-টু-ডেট!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'সর্বশেষ ভার্সন ${rel.tagName} সক্রিয় রয়েছে। কোনো নতুন আপডেট নেই।',
                                style: const TextStyle(
                                  color: LiquidGlassTheme.textSecondary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              LiquidGlassButton(
                                text: 'আবার চেক করুন',
                                icon: Icons.sync_rounded,
                                isSecondary: true,
                                height: 42,
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
                        // Update Available Card!
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
                                constraints: const BoxConstraints(maxHeight: 120),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'আরও সুবিধাসমূহ ও সেটিংস',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'ক্যালকুলেটর, অফলাইন অটো ব্যাকআপ, অটো এসএমএস ও OTA আপডেট',
                style: TextStyle(
                  color: LiquidGlassTheme.textSecondary,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 18),

              // 1. EMI Calculator Card
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

              // 2. Offline Auto Backup System (রাত ১১:৩০ PM)
              LiquidGlassCard(
                glowColor: LiquidGlassTheme.electricViolet,
                padding: const EdgeInsets.all(16),
                onTap: () => _showOfflineBackupDialog(context),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'অফলাইন অটো ব্যাকআপ সিস্টেম',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'প্রতিদিন রাত ১১:৩০ টায় স্বয়ংক্রিয় ব্যাকআপ • অফলাইন সুরক্ষিত',
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

              // 3. Auto SMS & Reminders (৫+ বাংলা টেমপ্লেট)
              LiquidGlassCard(
                glowColor: LiquidGlassTheme.cyberCyan,
                padding: const EdgeInsets.all(16),
                onTap: () => _showAutoSmsDialog(context),
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
                        Icons.sms_rounded,
                        color: LiquidGlassTheme.cyberCyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'অটো এসএমএস ও কিস্তি তাগাদা',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'কিস্তির তাগাদা, পেমেন্ট রসিদ ও ৫+ বাংলা এসএমএস টেমপ্লেট',
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

              // 4. App OTA Update (GitHub Connected)
              LiquidGlassCard(
                glowColor: rel?.hasUpdate == true
                    ? LiquidGlassTheme.neonEmerald
                    : LiquidGlassTheme.cyberCyan,
                padding: const EdgeInsets.all(16),
                onTap: () => _showOtaUpdateDialog(context),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (rel?.hasUpdate == true
                                ? LiquidGlassTheme.neonEmerald
                                : LiquidGlassTheme.cyberCyan)
                            .withOpacity(0.15),
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'অ্যাপ OTA আপডেট (GitHub)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (rel?.hasUpdate == true) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: LiquidGlassTheme.neonEmerald.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'আপডেট!',
                                    style: TextStyle(
                                      color: LiquidGlassTheme.neonEmerald,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rel?.hasUpdate == true
                                ? 'নতুন সংস্করণ ${rel?.tagName} উপলভ্য • ট্যাপ করে ডাউনলোড করুন'
                                : 'গিটহাব থেকে সরাসরি ইন-অ্যাপ আপডেট • বর্তমান: ${OtaUpdateService.currentVersion}',
                            style: const TextStyle(
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

              // 5. Reset All Data
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kisti (কিস্তি সেবা)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ভার্সন ১.০.৪ • পণ্য কিস্তি ম্যানেজমেন্ট প্ল্যাটফর্ম',
                                style: TextStyle(
                                  color: LiquidGlassTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const LiquidBadge(
                          label: 'v1.0.4',
                          color: LiquidGlassTheme.neonEmerald,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ইলেকট্রনিক্স শো-রুম, মোবাইল শপ ও হোম অ্যাপ্লায়েন্সের পণ্য সহজ কিস্তিতে বিক্রয়, লাভ-ক্ষতি, অফলাইন অটো ব্যাকআপ, অটো এসএমএস ও গিটহাব OTA আপডেটের পূর্ণাঙ্গ সমাধান।',
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
