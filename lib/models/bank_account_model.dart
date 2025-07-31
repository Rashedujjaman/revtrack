import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType { savings, current, credit }

class BankAccount {
  final String id;
  final String userId;
  final String accountName;
  final String bankName;
  final String accountNumber; // Last 4 digits only for security
  final AccountType accountType;
  final double currentBalance;
  final double? creditLimit; // Only for credit cards
  final String? description;
  final bool isActive;
  final Timestamp dateCreated;
  final Timestamp? dateModified;

  BankAccount({
    required this.id,
    required this.userId,
    required this.accountName,
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    required this.currentBalance,
    this.creditLimit,
    this.description,
    this.isActive = true,
    required this.dateCreated,
    this.dateModified,
  });

  // Factory method to create from JSON
  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      userId: json['userId'],
      accountName: json['accountName'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      accountType: AccountType.values.firstWhere(
        (e) => e.toString() == 'AccountType.${json['accountType']}',
        orElse: () => AccountType.savings,
      ),
      currentBalance: (json['currentBalance'] ?? 0.0).toDouble(),
      creditLimit: json['creditLimit']?.toDouble(),
      description: json['description'],
      isActive: json['isActive'] ?? true,
      dateCreated: json['dateCreated'],
      dateModified: json['dateModified'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountName': accountName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountType': accountType.toString().split('.').last,
      'currentBalance': currentBalance,
      'creditLimit': creditLimit,
      'description': description,
      'isActive': isActive,
      'dateCreated': dateCreated,
      'dateModified': dateModified,
    };
  }

  // Factory method from Firestore document
  factory BankAccount.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BankAccount(
      id: doc.id,
      userId: data['userId'],
      accountName: data['accountName'],
      bankName: data['bankName'],
      accountNumber: data['accountNumber'],
      accountType: AccountType.values.firstWhere(
        (e) => e.toString() == 'AccountType.${data['accountType']}',
        orElse: () => AccountType.savings,
      ),
      currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
      creditLimit: data['creditLimit']?.toDouble(),
      description: data['description'],
      isActive: data['isActive'] ?? true,
      dateCreated: data['dateCreated'],
      dateModified: data['dateModified'],
    );
  }

  // Helper methods
  bool get isCreditCard => accountType == AccountType.credit;
  
  double get availableBalance {
    if (isCreditCard) {
      return (creditLimit ?? 0.0) + currentBalance; // Credit cards have negative balances
    }
    return currentBalance;
  }

  String get displayName => '$accountName (*${accountNumber.substring(accountNumber.length - 4)})';
  
  String get formattedBalance {
    if (isCreditCard && currentBalance < 0) {
      return 'Due: \$${(-currentBalance).toStringAsFixed(2)}';
    }
    return '\$${currentBalance.toStringAsFixed(2)}';
  }

  // Copy with method for updates
  BankAccount copyWith({
    String? accountName,
    String? bankName,
    String? accountNumber,
    AccountType? accountType,
    double? currentBalance,
    double? creditLimit,
    String? description,
    bool? isActive,
    Timestamp? dateModified,
  }) {
    return BankAccount(
      id: id,
      userId: userId,
      accountName: accountName ?? this.accountName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      currentBalance: currentBalance ?? this.currentBalance,
      creditLimit: creditLimit ?? this.creditLimit,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      dateCreated: dateCreated,
      dateModified: dateModified ?? this.dateModified,
    );
  }
}
