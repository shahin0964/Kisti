import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ReleaseInfo {
  final String tagName;
  final String releaseTitle;
  final String releaseNotes;
  final String currentReleaseNotes;
  final DateTime? publishedAt;
  final String apkDownloadUrl;
  final int apkSizeBytes;
  final bool hasUpdate;
  final String currentVersion;

  const ReleaseInfo({
    required this.tagName,
    required this.releaseTitle,
    required this.releaseNotes,
    required this.currentReleaseNotes,
    this.publishedAt,
    required this.apkDownloadUrl,
    required this.apkSizeBytes,
    required this.hasUpdate,
    required this.currentVersion,
  });

  String get formattedSize {
    if (apkSizeBytes <= 0) return '';
    final mb = apkSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class OtaUpdateService {
  static const String currentVersion = 'v1.0.5';
  static const String repoOwner = 'shahin0964';
  static const String repoName = 'Kisti';

  static const String currentReleaseChangelog = '''
✨ নতুন কি যোগ হলো (New Features):
• ব্যবসার তথ্য (Business Info) সেটিংস (দোকানের নাম, মালিকের নাম, মোবাইল, ঠিকানা, স্লোগান)
• অটো এসএমএস সিস্টেমে সিম সিলেকশন (সিম ১ / সিম ২)
• কিস্তি জমার পর তাৎক্ষণিক অটো কনফার্মেশন ও ডিজিটাল রসিদ এসএমএস
• কিস্তির তারিখের পূর্বে ২টি আগাম তাগাদা এসএমএস (৩ দিন ও ১ দিন আগে)
• অ্যাপ পরিচিতি ও তথ্য (About App) পপআপ মডাল

🛠️ কি কি ফিক্স হলো (Fixes):
• স্ক্রিনের হেডারের লেখা স্ক্রল হয়ে উপরে হারিয়ে যাওয়ার সমস্যা সমাধান
• অতিরিক্ত বড় লেখার মাঝে লাইন ভেঙে লম্বাটে হওয়ার সমস্যা সমাধান
• ডিসপ্লে নিচে ভাসমান মেনুবারের সাথে লেখার ওভারল্যাপ ফিক্স

🚀 কি আপডেট হলো (Improvements):
• অফলাইন অটো ব্যাকআপ সিস্টেম (প্রতিদিন রাত ১১:৩০ PM)
• গিটহাব OTA আপডেট ডায়ালগে সবসময় রিলিজ নোট দেখার সুব্যবস্থা
''';

  static int _versionToInt(String version) {
    final clean = version.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = clean.split('.');
    int major = 0;
    int minor = 0;
    int patch = 0;
    if (parts.isNotEmpty) major = int.tryParse(parts[0]) ?? 0;
    if (parts.length > 1) minor = int.tryParse(parts[1]) ?? 0;
    if (parts.length > 2) patch = int.tryParse(parts[2]) ?? 0;
    return major * 10000 + minor * 100 + patch;
  }

  static Future<ReleaseInfo?> checkLatestRelease() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final uri = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'Kisti-App-OTA');
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      final response = await request.close();
      if (response.statusCode != 200) {
        // Return current release info even if offline
        return const ReleaseInfo(
          tagName: currentVersion,
          releaseTitle: 'Kisti Seba $currentVersion',
          releaseNotes: currentReleaseChangelog,
          currentReleaseNotes: currentReleaseChangelog,
          apkDownloadUrl: '',
          apkSizeBytes: 0,
          hasUpdate: false,
          currentVersion: currentVersion,
        );
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(responseBody);

      final tagName = (data['tag_name'] as String?) ?? '';
      final name = (data['name'] as String?) ?? tagName;
      final body = (data['body'] as String?) ?? currentReleaseChangelog;
      final publishedStr = data['published_at'] as String?;
      DateTime? publishedAt;
      if (publishedStr != null) {
        publishedAt = DateTime.tryParse(publishedStr);
      }

      String apkUrl = '';
      int apkSize = 0;
      final List<dynamic>? assets = data['assets'];
      if (assets != null) {
        for (final asset in assets) {
          final assetName = (asset['name'] as String?) ?? '';
          if (assetName.endsWith('.apk')) {
            apkUrl = (asset['browser_download_url'] as String?) ?? '';
            apkSize = (asset['size'] as num?)?.toInt() ?? 0;
            break;
          }
        }
      }

      if (apkUrl.isEmpty && tagName.isNotEmpty) {
        apkUrl = 'https://github.com/$repoOwner/$repoName/releases/download/$tagName/app-release.apk';
      }

      final latestVal = _versionToInt(tagName);
      final currentVal = _versionToInt(currentVersion);
      final hasUpdate = latestVal > currentVal;

      return ReleaseInfo(
        tagName: tagName,
        releaseTitle: name,
        releaseNotes: body.isNotEmpty ? body : currentReleaseChangelog,
        currentReleaseNotes: currentReleaseChangelog,
        publishedAt: publishedAt,
        apkDownloadUrl: apkUrl,
        apkSizeBytes: apkSize,
        hasUpdate: hasUpdate,
        currentVersion: currentVersion,
      );
    } catch (e) {
      debugPrint('Error checking OTA update: $e');
      return const ReleaseInfo(
        tagName: currentVersion,
        releaseTitle: 'Kisti Seba $currentVersion',
        releaseNotes: currentReleaseChangelog,
        currentReleaseNotes: currentReleaseChangelog,
        apkDownloadUrl: '',
        apkSizeBytes: 0,
        hasUpdate: false,
        currentVersion: currentVersion,
      );
    }
  }

  static Future<String?> downloadUpdateApk(
    String url, {
    required void Function(double progress, int receivedBytes, int totalBytes) onProgress,
  }) async {
    try {
      final client = HttpClient();
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      request.maxRedirects = 5;
      request.headers.set('User-Agent', 'Kisti-App-OTA');

      final response = await request.close();
      if (response.statusCode != 200) {
        return null;
      }

      final totalBytes = response.contentLength > 0 ? response.contentLength : 52000000;
      int receivedBytes = 0;

      Directory dir;
      final sdcardDownload = Directory('/sdcard/Download');
      if (sdcardDownload.existsSync()) {
        dir = sdcardDownload;
      } else {
        dir = Directory.systemTemp;
      }

      final saveFile = File('${dir.path}/kisti-latest-update.apk');
      final sink = saveFile.openWrite();

      await for (final chunk in response) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
        onProgress(progress, receivedBytes, totalBytes);
      }

      await sink.flush();
      await sink.close();

      return saveFile.path;
    } catch (e) {
      debugPrint('Error downloading APK: $e');
      return null;
    }
  }
}
