import 'package:money_milestone/utils/databaseHelper.dart';

class TransactionModel {
  TransactionModel(
      {this.transactionAmount,
      this.transactionDate,
      this.transactionNote,
      this.transactionType,
      this.transactionId});

  TransactionModel.fromJson(final Map<String?, dynamic> json) {
    transactionAmount = json[DatabaseHelper.transactionAmount] ?? '';
    transactionType = json[DatabaseHelper.transactionType] ?? '';
    transactionDate = json[DatabaseHelper.transactionDate] ?? '';
    transactionNote = json[DatabaseHelper.transactionNote] ?? '';
    transactionId = json[DatabaseHelper.transactionId] ?? '0';
  }

  Map<String, dynamic> toJson() => {
        DatabaseHelper.transactionAmount: transactionAmount,
        DatabaseHelper.transactionDate: transactionDate,
        DatabaseHelper.transactionNote: transactionNote,
        DatabaseHelper.transactionType: transactionType,
        DatabaseHelper.transactionId: transactionId
      };

  String? transactionId;
  String? transactionAmount;
  String? transactionDate;
  String? transactionNote;
  String? transactionType;
}
