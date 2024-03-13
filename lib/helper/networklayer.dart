import 'dart:async';
import 'dart:convert';

import 'package:chukstem/models/explore_model.dart';
import 'package:chukstem/models/timeline_comment_replies_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversations_model.dart';
import '../models/notifications_model.dart';
import '../models/reviews.dart';
import '../models/thrift_transactions_model.dart';
import '../models/timeline_model.dart';
import '../models/transactions_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';
import '../strings.dart';



Future<String> getQuery() async {
  var res="";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/query'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  var user = json.decode(response.body);
  try {
    var jsond = user["user_details"] as List<dynamic>;
    for (var jsondata in jsond) {
      if (user["status"] != null &&
          user["status"].toString().contains("success")) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("pin", "${jsondata["app_pin"]}");
        prefs.setString("avatar", "${jsondata["image"]}");
        prefs.setString("wallet", "${jsondata["wallet"]}");
        prefs.setString("save_wallet", "${jsondata["save_wallet"]}");
        prefs.setString("cover", "${jsondata["cover"]}");
        prefs.setString("about", "${jsondata["about"]}");
        prefs.setString("kyc_status", "${jsondata["kyc_verified_at"]}");
        prefs.setString("rejected_reason", "${jsondata["rejected_reason"]}");
      }
    }
  } catch (e) {
    if(user!=null){
      try {
        res = user["response_message"].toString();
      }catch(ex){
      }
    }
  }

  try{
    var jsond = user["virtual_accounts"] as List<dynamic>;
    for (var jsondata in jsond) {
      String bankname = jsondata["bank_name"] ?? "";
      String accountname = jsondata["account_name"] ?? "";
      String accountnumber = jsondata["account_number"] ?? "";
      prefs.setString("bankname", bankname);
      prefs.setString("accountname", accountname);
      prefs.setString("accountnumber", accountnumber);
    }
  }catch(e){
    prefs.setString("bankname", "");
    prefs.setString("accountname", "");
    prefs.setString("accountnumber", "");
  }

  try{
    prefs.setString("banks", user["banks"]);
    prefs.setString("electricity", user["electricity"]);
    prefs.setString("betting", user["betting"]);
    prefs.setString("cable", user["cable"]);
    prefs.setString("data", user["data"]);
    prefs.setString("vtu", user["vtu"]);
  }catch(e){
  }

  return res;
}

Future<List<TimelineModel>> getTimeline(http.Client client, String user, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'query': user,
    'start': start
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/timeline'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
    if(start=="0"){
      prefs.setString("timeline", response.body);
    }
  return compute(parseTimeline, response.body);
}

Future<List<TimelineModel>> getTimelineSearch(http.Client client, String state, String lga, String type, String category, String search) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'state': state,
    'lga': lga,
    'search': search,
    'category': type,
    'sub_category': category
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/timeline-search'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseTimeline, response.body);
}

Future<List<TimelineModel>> getTimelineCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("timeline");
  return compute(parseTimeline, cache);
}

List<TimelineModel> parseTimeline(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<TimelineModel> list =
  parsed.map<TimelineModel>((json) => new TimelineModel.fromJson(json)).toList();
  return list;
}


Future<List<ExploreModel>> getExplore(http.Client client, String search, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'query': search,
    'start': start
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/explore'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(search.contains("ALL")){
    prefs.setString("explore", response.body);
  }
  return compute(parseExplore, response.body);
}


Future<List<ExploreModel>> getExploreCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("explore");
  return compute(parseExplore, cache);
}

List<ExploreModel> parseExplore(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<ExploreModel> list =
  parsed.map<ExploreModel>((json) => new ExploreModel.fromJson(json)).toList();
  return list;
}


Future<List<UserModel>> getFollowers(http.Client client, String user, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'user': user,
    'start': start
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/user_followers'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseFollowers, response.body);
}

List<UserModel> parseFollowers(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<UserModel> list =
  parsed.map<UserModel>((json) => new UserModel.fromJson(json)).toList();
  return list;
}


Future<List<UserModel>> getFollowing(http.Client client, String user, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'user': user,
    'start': start
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/user_following'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseFollowing, response.body);
}

List<UserModel> parseFollowing(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<UserModel> list =
  parsed.map<UserModel>((json) => new UserModel.fromJson(json)).toList();
  return list;
}


Future<List<TimelineModel>> getTimelineComments(http.Client client, String cid, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'cid': cid,
    'start': start
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/timeline_comments'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseTimeline, response.body);
}



Future<List<TimelineCommentRepliesModel>> getTimelineCommentReplies(http.Client client, String cid, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'cid': cid,
    'start': start
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/timeline_comment_replies'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseReplies, response.body);
}
List<TimelineCommentRepliesModel> parseReplies(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<TimelineCommentRepliesModel> list =
  parsed.map<TimelineCommentRepliesModel>((json) => new TimelineCommentRepliesModel.fromJson(json)).toList();
  return list;
}



Future<List<TransactionsModel>> getTransactions(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/bills-transactions'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  prefs.setString("cache_transactions", response.body);
  return compute(parseTransactions, response.body);
}
Future<List<TransactionsModel>> getTransaction(http.Client client, String reference) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'reference': reference
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/view-transaction'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseTransactions, response.body);
}
Future<List<TransactionsModel>> getTransactionsCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_transactions");
  return compute(parseTransactions, cache);
}
// A function that will convert a response body into a List
List<TransactionsModel> parseTransactions(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<TransactionsModel> list =
  parsed.map<TransactionsModel>((json) => new TransactionsModel.fromJson(json)).toList();
  return list;
}


Future<List<NotificationsModel>> getNotifications(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/notifications'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseNotifications, response.body);
}
// A function that will convert a response body into a List
List<NotificationsModel> parseNotifications(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<NotificationsModel> list =
  parsed.map<NotificationsModel>((json) => new NotificationsModel.fromJson(json)).toList();
  return list;
}


Future<List<ConversationsModel>> getConversations(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/conversations'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  prefs.setString("cache_conversations", response.body);
  return compute(parseConversations, response.body);
}

Future<List<ConversationsModel>> getUserConversations(http.Client client, String to, String from, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  var username = prefs.getString("username");
  Map data = {
    'email': email,
    'to': to,
    'from': from,
    'start': start
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/user_conversations'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  if(start=="0"){
    prefs.setString(username!.toLowerCase()==to.toLowerCase()?"cache_$from":"cache_$to", response.body);
  }
  return compute(parseConversations, response.body);
}
Future<List<ConversationsModel>> getUserConversationsCached(String to, String from) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var username = prefs.getString("username");
  var cache = prefs.getString(username!.toLowerCase()==to.toLowerCase()?"cache_$from":"cache_$to");
  return compute(parseConversations, cache);
}
Future<List<ConversationsModel>> getConversationsCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_conversations");
  return compute(parseConversations, cache);
}
List<ConversationsModel> parseConversations(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<ConversationsModel> list =
  parsed.map<ConversationsModel>((json) => new ConversationsModel.fromJson(json)).toList();
  return list;
}


Future<List<WalletModel>> getWallet(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/account-txn'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  prefs.setString("cache_wallet", response.body);
  return compute(parseWallet, response.body);
}

Future<List<WalletModel>> getWalletCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_wallet");
  return compute(parseWallet, cache);
}
// A function that will convert a response body into a List
List<WalletModel> parseWallet(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<WalletModel> list =
  parsed.map<WalletModel>((json) => new WalletModel.fromJson(json)).toList();
  return list;

}


Future<List<ThriftTransactionsModel>> getSavings(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/thrift_savings'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  prefs.setString("cache_savings", response.body);
  return compute(parseSavings, response.body);
}

Future<List<ThriftTransactionsModel>> getSavingsCached() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var cache = prefs.getString("cache_savings");
  return compute(parseSavings, cache);
}
// A function that will convert a response body into a List
List<ThriftTransactionsModel> parseSavings(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  List<ThriftTransactionsModel> list =
  parsed.map<ThriftTransactionsModel>((json) => new ThriftTransactionsModel.fromJson(json)).toList();
  return list;

}



Future<List<ReviewsModel>> getReviews(http.Client client, String username, String start) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var token = prefs.getString("token");
  var email = prefs.getString("email");
  Map data = {
    'email': email,
    'user': username,
    'start': start
  };

  var body = json.encode(data);
  final response = await http.post(Uri.parse(Strings.url+'/trade-review/index'),
      headers: {
        "Content-Type": "application/json",
        "Authentication": "Bearer $token"},
      body: body
  );
  return compute(parseReviews, response.body);
}
List<ReviewsModel> parseReviews(var responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  List<ReviewsModel> list =
  parsed.map<ReviewsModel>((json) => new ReviewsModel.fromJson(json)).toList();
  return list;
}
