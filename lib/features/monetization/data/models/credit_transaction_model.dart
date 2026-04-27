import '../../domain/entities/credit_transaction_entity.dart';

class CreditTransactionModel extends CreditTransactionEntity {
  CreditTransactionModel({
    required super.id,
    required super.walletId,
    required super.type,
    required super.amount,
    required super.balanceAfter,
    required super.description,
    required super.referenceType,
    required super.referenceId,
    required super.createdAt,
  });

  factory CreditTransactionModel.fromJson(Map<String, dynamic> json) {
    return CreditTransactionModel(
      id: json['id'],
      walletId: json['walletId'],
      type: _parseType(json['type']),
      amount: json['amount'],
      balanceAfter: json['balanceAfter'],
      description: json['description'] ?? '',
      referenceType: json['referenceType'] ?? '',
      referenceId: json['referenceId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static TransactionType _parseType(String type) {
    switch (type) {
      case 'topup':
        return TransactionType.topup;
      case 'purchase':
        return TransactionType.purchase;
      case 'pipeline_fee':
        return TransactionType.pipelineFee;
      default:
        return TransactionType.unknown;
    }
  }
}
