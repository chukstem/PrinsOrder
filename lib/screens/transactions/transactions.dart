import 'dart:async';
import 'package:chukstem/screens/transactions/view_transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../helper/networklayer.dart';
import '../../helper/pusher.dart';
import '../../models/transactions_model.dart';

class Transactions extends StatefulWidget {
  Transactions({Key? key}) : super(key: key);

  @override
  _Transactions createState() => _Transactions();
}

class _Transactions extends State<Transactions> {
  List<TransactionsModel> aList = List.empty(growable: true);
  bool loading=true;

  cachedList() async {
    List<TransactionsModel> iList = await getTransactionsCached();
    setState(() {
      if(iList.isNotEmpty){
        loading=false;
      }
      aList = iList;
    });
  }

  fetchList() async {
    loading=true;
    try{
      List<TransactionsModel> iList = await getTransactions(new http.Client());
      setState(() {
        aList = iList;
      });
    }catch(e){

    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetchList(),
      generalPusher(context)
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFf2f2f2),
        body: Container(
            constraints: BoxConstraints(
                minHeight: 500, minWidth: double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
                  ),
                  padding: EdgeInsets.only(top: 20),
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 10),
                    child: Center(child: Text(
                      'Transactions',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),),
                  ),
                ),
                loading? Container(
                    margin: const EdgeInsets.all(50),
                    child: const Center(
                        child: CircularProgressIndicator()))
                    :
                aList.length <= 0 ?
                Container(
                  height: 200,
                  margin: EdgeInsets.all(20),
                  child: Center(
                    child: Text("No Transaction Yet!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryDarkColor),),
                  ),
                )
                    :
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(0),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: 0),
                            itemCount: aList.length,
                            itemBuilder: (context, index) {
                              return getListItem(
                                  aList[index], index, context);
                            })
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  Container getListItem(TransactionsModel obj, int index, BuildContext context) {
    return Container(
      child: Card(
        margin: const EdgeInsets.only(
          bottom: 5,
          top: 5,
          left: 10,
          right: 10,
        ),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => ViewTransaction(Transaction: obj,))).whenComplete(() => fetchList());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 5.0, top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width*0.10,
                        height: MediaQuery.of(context).size.width*0.10,
                        margin: EdgeInsets.all(10),
                        child: new CircleAvatar(
                          maxRadius: 23,
                          minRadius: 23,
                          child: obj.status=="success" || obj.status=="Success" ?
                          SvgPicture.asset(
                            "assets/icons/success.svg" ,
                            height: 35.0,
                            width: 35.0,
                            color: Colors.green,
                          ) : SvgPicture.asset(
                            "assets/icons/pending.svg",
                            height: 35.0,
                            width: 35.0,
                            color: yellow80,
                          ),
                          backgroundColor: Colors.white,
                        ),
                        padding: EdgeInsets.all(1.0),
                        decoration: new BoxDecoration( // border color
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )),
                    Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            obj.services+" - "+obj.beneficiary,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                          SizedBox(height: 10,),
                          Text(
                            obj.time,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                "₦"+obj.amount,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                              obj.status=="pending" || obj.status=="Pending" ?
                              Text(
                                obj.status.toUpperCase(),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: yellow80,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ) : obj.status=="success" || obj.status=="Success" ?
                              Text(
                                obj.status.toUpperCase(),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ) : Text(
                                obj.status.toUpperCase(),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}