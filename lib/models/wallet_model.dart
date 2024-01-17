class WalletModel {
  String description;
  String time;
  String amount;

  WalletModel({
  required this.description, required this.time, required this.amount});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      description: json['description'] as String,
      time: json['time'] as String,
      amount: json['amount'] as String,
    );
  }
}