import 'dart:convert';

import 'package:flutter_pos_app/core/constants/variables.dart';
import 'package:flutter_pos_app/data/models/request/order_request_model.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'auth_local_datasource.dart';

class OrderRemoteDatasource {
  OrderRemoteDatasource._init();
  static final OrderRemoteDatasource instance = OrderRemoteDatasource._init();
  Future<bool> sendOrder(OrderRequestModel requestModel) async {
    final url = Uri.parse('${Variables.baseUrl}/api/orders');
    final authData = await AuthLocalDatasource().getAuthData();
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${authData.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    print(requestModel.toJson());
    final response = await http.post(
      url,
      headers: headers,
      body: requestModel.toJson(),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteOrder(List uuids) async {
    final url = Uri.parse('${Variables.baseUrl}/api/orders/delete');
    final authData = await AuthLocalDatasource().getAuthData();
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${authData.token}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final log = Logger();
    Map<String, dynamic> data = {
      "orders": uuids.map((uuid) => {"uuid": uuid}).toList(),
    };
    String jsonStr = jsonEncode(data);
    // log.d(jsonStr);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonStr,
      );
      log.d(response.body);
      // ignore: unnecessary_null_comparison
      if (response.statusCode == 201 || response != null) {
        return true;
      } else {
        return false;
      }
    } catch (err) {
      // 4. return Failure here too
      return false;
    }
  }
}
