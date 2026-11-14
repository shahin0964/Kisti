import 'package:flutter_test/flutter_test.dart';
import 'package:kisti/models/customer.dart';

void main() {
  test('Customer calculation and progress smoke test', () {
    final customer = Customer(
      id: 'TEST-1',
      name: 'আবু বকর',
      phone: '01700000000',
      address: 'ঢাকা',
      nid: '1234567890',
      principalAmount: 20000,
      interestRate: 10,
      totalPayable: 22000,
      installmentAmount: 1100,
      frequency: 'দৈনিক',
      totalInstallments: 20,
      paidInstallments: 10,
      totalPaid: 11000,
      startDate: DateTime.now(),
    );

    expect(customer.remainingAmount, 11000);
    expect(customer.progressPercentage, 0.5);
    expect(customer.isFullyPaid, false);
  });
}
