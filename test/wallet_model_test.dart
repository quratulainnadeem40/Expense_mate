import 'package:expense_mate/Feature/wallets/model/wallet_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WalletModel cash labels', () {
    WalletModel createWallet({required String name, required String type}) {
      return WalletModel(
        id: 'wallet-id',
        userId: 'user-id',
        name: name,
        type: type,
        balance: 100,
        currency: 'PKR',
        createdAt: DateTime(2026),
      );
    }

    test('identifies cash as physical cash in wallet views', () {
      final wallet = createWallet(name: 'Cash', type: 'Cash');

      expect(wallet.isCash, isTrue);
      expect(wallet.displayType, 'Cash (Physical cash)');
      expect(wallet.transactionOptionLabel, 'Cash (Physical cash)');
    });

    test('distinguishes named cash wallets in transaction choices', () {
      final wallet = createWallet(name: 'Home cash', type: 'Cash');

      expect(wallet.transactionOptionLabel, 'Home cash · Physical cash');
    });

    test('leaves non-cash wallet labels unchanged', () {
      final wallet = createWallet(name: 'Main account', type: 'Bank Account');

      expect(wallet.isCash, isFalse);
      expect(wallet.displayType, 'Bank Account');
      expect(wallet.transactionOptionLabel, 'Main account');
    });
  });
}
