class TransactionsModel {
  String services;
  String amount;
  String status;
  String time;
  String reference;
  String type;
  String token;
  String beneficiary;

  TransactionsModel({
  required this.services, required this.amount, required this.status, required this.time, required this.reference, required this.type, required this.token, required this.beneficiary});

  factory TransactionsModel.fromJson(Map<String, dynamic> json) {
    return TransactionsModel(
      services: json['services'] as String,
      amount: json['amount'] as String,
      status: json['status'] as String,
      time: json['time'] as String,
      reference: json['reference'] as String,
      type: json['type'] as String,
      token: json['token'] as String,
      beneficiary: json['beneficiary'] as String,
    );
  }
}