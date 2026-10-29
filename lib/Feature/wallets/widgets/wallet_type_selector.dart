import 'package:flutter/material.dart';

class WalletTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const WalletTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static const List<String> walletTypes = [
    'Cash',
    'Bank Account',
    'JazzCash',
    'Easypaisa',
    'Credit Card',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: walletTypes.contains(selectedType)
          ? selectedType
          : walletTypes.first,
      decoration: const InputDecoration(
        labelText: 'Wallet Type',
        border: OutlineInputBorder(),
      ),
      items: walletTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}