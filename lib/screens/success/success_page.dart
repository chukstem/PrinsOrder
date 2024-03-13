import 'dart:async';
import 'package:chukstem/constants.dart';
import 'package:flutter/material.dart';
import '../../../models/transactions_model.dart';
import '../../widgets/appbar.dart';
import '../transactions/view_transaction.dart';

class SuccessScreenWallet extends StatefulWidget {
  SuccessScreenWallet({required this.message, required this.Transaction});
  final String message;
  final TransactionsModel Transaction;

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreenWallet> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 6), () =>
    Navigator.pushReplacement(context, MaterialPageRoute<dynamic>(
    builder: (BuildContext context) => ViewTransaction(Transaction: widget.Transaction,)))

    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          backAppbar(context, "Thank You!"),
          SizedBox(
            height: 20,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3.0,
            margin: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 10),
            padding: EdgeInsets.all(25),
            child: Image.asset(
              'assets/images/success.gif',
              fit: BoxFit.scaleDown,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
             width: MediaQuery.of(context).size.width*0.70,
             child: Center(
             child: Text(
             '${widget.message}',
             overflow: TextOverflow.ellipsis,
             maxLines: 3,
             style: const TextStyle(
             fontSize: 20),
             textAlign: TextAlign.center,
             ))),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 10,
              left: 20,
              right: 20,
            ),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => ViewTransaction(Transaction: widget.Transaction)));
              },
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 1.0, color: kPrimaryDarkColor),
                  backgroundColor: kPrimaryDarkColor
              ),
              child: const Text(
                "View Transaction Details",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

          ),
        ],
      ),
    );
  }
}
