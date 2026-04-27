enum TransactionType {
  topup,
  purchase,
  pipelineFee,
  unknown
}

class CreditTransactionEntity {
  final int id;
  final int walletId;
  final TransactionType type;
  final int amount;
  final int balanceAfter;
  final String description;
  final String referenceType;
  final int referenceId;
  final DateTime createdAt;

  CreditTransactionEntity({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    required this.referenceType,
    required this.referenceId,
    required this.createdAt,
  });

  bool get isIncome => amount > 0;
}
