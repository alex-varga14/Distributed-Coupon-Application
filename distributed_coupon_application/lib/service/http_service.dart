import 'dart:convert';

import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:http/http.dart' as http;
import 'package:result_type/result_type.dart';

abstract class HttpService {

  String baseUrl();
  T? deserialize<T>(dynamic data);

  Future<Result<T, APIError>> postJson<T>(String endpoint, [Map<String, Object>? params]) async {
    var response = await http.post(Uri.parse(baseUrl() + endpoint), body: jsonEncode(params));

    if (response.statusCode < 200 || response.statusCode > 299) {
      return Failure(APIError.HTTPError(response.statusCode, response.reasonPhrase));
    }

    var json = jsonDecode(response.body) as Map<String, dynamic>;
    T? result = deserialize<T>(json);
    if (result == null) {
      return Failure(APIError.MappingError());
    }

    return Success(result);
  }

  Future<Result<T, APIError>> get<T>(String endpoint, [Map<String, Object>? params]) async {
    String url = "${baseUrl()}$endpoint";

    if (params != null) {
      String paramsStr = params.keys.map((key) => "$key=${params[key]}").join("&");
      url = "$url?$paramsStr";
    }

    final uri = Uri.parse(url);
    var response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode > 299) {
      return Failure(APIError.HTTPError(response.statusCode, response.reasonPhrase));
    }

    var json = jsonDecode(response.body);

    T? result = deserialize<T>(json);
    if (result == null) {
      return Failure(APIError.MappingError());
    }
    return Success(result);
  }
}