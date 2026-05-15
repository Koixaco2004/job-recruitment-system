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
      id: json['id'] as int? ?? 0,
      walletId: json['walletId'] as int? ?? 0,
      type: _parseType(json['type']?.toString() ?? ''),
      amount: (json['amount'] is num) ? (json['amount'] as num).toInt() : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      balanceAfter: (json['balanceAfter'] is num) ? (json['balanceAfter'] as num).toInt() : int.tryParse(json['balanceAfter']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      referenceType: json['referenceType']?.toString() ?? '',
      referenceId: json['referenceId'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
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
