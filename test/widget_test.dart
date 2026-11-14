import 'package:flutter_test/flutter_test.dart';
import 'package:kisti/models/customer.dart';

void main() {
  test('Customer product installment calculation smoke test', () {
    final customer = Customer(
      id: 'KISTI-2026-TEST',
      name: 'আবু বকর',
      phone: '01712345678',
      address: 'ধানমন্ডি, ঢাকা',
      nid: '1992269000000000',
      productName: 'Walton 250L Refrigerator',
      productCategory: 'ফ্রিজ',
      modelOrImei: 'WFE-3B0-GDNE-XX',
      cashPrice: 48000,
      installmentPrice: 54000,
      downPayment: 14000,
      guarantorName: 'মো: রফিকুল ইসলাম',
      guarantorPhone: '01811223344',
      installmentAmount: 4000,
      frequency: 'মাসিক',
      totalInstallments: 10,
      paidInstallments: 4,
      totalInstallmentPaid: 16000,
      startDate: DateTime.now(),
      status: 'চলমান',
    );

    expect(customer.financedAmount, 40000);
    expect(customer.totalCollected, 30000);
    expect(customer.remainingAmount, 24000);
    expect(customer.progressPercentage, closeTo(0.555, 0.001));
    expect(customer.isFullyPaid, false);
    expect(customer.categoryIcon, '🧊');
  });
}
