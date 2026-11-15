class SmsTemplate {
  final String id;
  final String title;
  final String description;
  final String content;
  final String tag;

  const SmsTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.tag,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'tag': tag,
    };
  }

  factory SmsTemplate.fromJson(Map<String, dynamic> json) {
    return SmsTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      tag: json['tag'] as String,
    );
  }

  static List<SmsTemplate> get defaultTemplates => const [
    SmsTemplate(
      id: 'due_reminder',
      title: '🔔 কিস্তির তাগাদা এসএমএস (Upcoming Due)',
      description: 'কিস্তির তারিখের পূর্বে গ্রাহককে আগাম নোটিশ পাঠানোর জন্য',
      content:
          'সম্মানিত {গ্রাহকের নাম}, আপনার {পণ্যের নাম}-এর কিস্তির তারিখ {তারিখ}। অনুগ্রহ করে সময়মতো কিস্তির টাকা ৳{কিস্তির পরিমাণ} জমা দিয়ে সহযোগিতা করুন। ধন্যবাদ, {দোকানের নাম}।',
      tag: 'তাগাদা',
    ),
    SmsTemplate(
      id: 'due_today',
      title: '⏰ আজকের কিস্তির নোটিশ (Due Today)',
      description: 'কিস্তির দিন সকালে গ্রাহককে স্মরণ করিয়ে দিতে',
      content:
          'সম্মানিত {গ্রাহকের নাম}, আজ আপনার {পণ্যের নাম}-এর কিস্তি জমার নির্ধারিত দিন। আজই ৳{কিস্তির পরিমাণ} টাকা প্রদান করতে অনুরোধ করা হচ্ছে। - {দোকানের নাম}।',
      tag: 'আজকের',
    ),
    SmsTemplate(
      id: 'overdue_alert',
      title: '⚠️ বকেয়া কিস্তির জরুরি তাগাদা (Overdue Alert)',
      description: 'যেসব গ্রাহকের কিস্তি নির্ধারিত সময়ে পরিশোধ হয়নি তাদের জন্য',
      content:
          'জরুরি নোটিশ: সম্মানিত {গ্রাহকের নাম}, আপনার {পণ্যের নাম}-এর কিস্তি বকেয়া রয়েছে। বিলম্ব চার্জ ও আইনি ঝামেলা এড়াতে দ্রুত বাকি ৳{বকেয়া পরিমাণ} পরিশোধ করুন। - {দোকানের নাম}।',
      tag: 'বকেয়া',
    ),
    SmsTemplate(
      id: 'payment_received',
      title: '🧾 কিস্তি আদায়ের নিশ্চিতকরণ স্লিপ (Receipt)',
      description: 'কিস্তি জমা নেওয়ার পর গ্রাহককে ডিজিটাল রসিদ হিসেবে পাঠাতে',
      content:
          'ধন্যবাদ {গ্রাহকের নাম}! আপনার {পণ্যের নাম}-এর কিস্তি বাবদ ৳{পরিশোধের পরিমাণ} সফলভাবে জমা হয়েছে। রশিদ নং: {রশিদ}। অবশিষ্ট বকেয়া: ৳{বকেয়া পরিমাণ}। - {দোকানের নাম}।',
      tag: 'রসিদ',
    ),
    SmsTemplate(
      id: 'welcome_purchase',
      title: '🎉 নতুন পণ্য ক্রয়ের শুভেচ্ছা (Welcome)',
      description: 'নতুন গ্রাহক যখন কিস্তিতে পণ্য কেনেন তখন শুভেচ্ছা জানাতে',
      content:
          'অভিনন্দন {গ্রাহকের নাম}! আমাদের শোরুম থেকে {পণ্যের নাম} ক্রয়ের জন্য আন্তরিক ধন্যবাদ। সহজ কিস্তিতে মানসম্মত পণ্য সেবায় আমরা সর্বদা আপনার পাশে আছি। - {দোকানের নাম}।',
      tag: 'শুভেচ্ছা',
    ),
  ];
}
