class ThriftTransactionsModel {
  String description;
  String amount;
  String time;
  String status;
  String method;
  String month;

  ThriftTransactionsModel({
  required this.description, required this.amount, required this.time, required this.status, required this.method, required this.month});

  factory ThriftTransactionsModel.fromJson(Map<String, dynamic> json) {
    return ThriftTransactionsModel(
      description: json['description'] as String,
      amount: json['amount'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
      method: json['method'] as String,
      month: json['month'] as String,
    );
  }
}