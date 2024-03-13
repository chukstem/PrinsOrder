import 'package:chukstem/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import '../../../models/transactions_model.dart'; 
import '../../widgets/appbar.dart';

class ViewTransaction extends StatefulWidget {
  ViewTransaction({required this.Transaction});
  TransactionsModel Transaction;

  @override
  _ViewTransactionState createState() => _ViewTransactionState();
}

class _ViewTransactionState extends State<ViewTransaction> {
  String errormsg="", comment="", email="", token="";
  bool error=false, success=false, showprogress=false, loading=false;
  bool progress=false, progress2=false; 
  Uint8List? logo;

    
  

  @override
  void initState() { 
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          backAppbar(context, "Transaction"),
          SizedBox(
            height: 20,
          ),
         Container(
           height: 800,
                margin: const EdgeInsets.only(
                  bottom: 5,
                  top: 5,
                  left: 10,
                  right: 5,
                ),
                  padding: const EdgeInsets.only(left: 15.0, right: 2, top: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20,),
                      Divider(),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Transaction",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Text(
                              widget.Transaction.services,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Transaction Type",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Text(
                              widget.Transaction.type.toUpperCase(),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Beneficiary",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Text(
                              widget.Transaction.beneficiary,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Time",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Text(
                              widget.Transaction.time,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Amount",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Text(
                              '₦'+widget.Transaction.amount,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Status",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: widget.Transaction.status=="pending" || widget.Transaction.status=="Pending" ?
                            Text(
                              widget.Transaction.status.toUpperCase(),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: yellow80,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ) : widget.Transaction.status=="success" || widget.Transaction.status=="Success" ?
                            Text(
                              widget.Transaction.status.toUpperCase(),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ) :
                            Text(
                              widget.Transaction.status.toUpperCase(),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      widget.Transaction.token.isNotEmpty ?
                      Column(
                        children: [
                          SizedBox(height: 10,),
                          Divider(),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width*0.25,
                                child: Text(
                                  "Token",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 20,),
                              Container(
                                width: MediaQuery.of(context).size.width*0.55,
                                child: InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: widget.Transaction.token));
                                    Toast.show("Token copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                                  },
                                  child: Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width*0.45,
                                          child: Text(
                                            widget.Transaction.token,
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        Icon(
                                          Icons.copy,
                                          color: kPrimaryDarkColor,
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ) ,
                        ],
                      ) : SizedBox(width: 0,),

                      SizedBox(height: 10,),
                      Divider(),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.25,
                            child: Text(
                              "Reference",
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: widget.Transaction.reference));
                                Toast.show("Reference copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                              },
                              child: Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.50,
                                      child: Text(
                                        widget.Transaction.reference.substring(0, 18)+"...",
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ),
                                    Icon(
                                      Icons.copy,
                                      color: kPrimaryDarkColor,
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,), 
                    ],
                  ), 
          ), 
        ],
      ),
      ),
    );
  } 
}
