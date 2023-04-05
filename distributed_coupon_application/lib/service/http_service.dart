import 'dart:convert';
import 'dart:io';

import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:http/http.dart' as http;
import 'package:result_type/result_type.dart';

abstract class HttpService {

  Future<String> baseUrl();
  T? deserialize<T>(dynamic data);

  Future<Result<T, APIError>> postJson<T>(String endpoint, [Map<String, Object>? params]) async {
    String base_url =  await baseUrl();

    Uri uri = Uri.https(Uri.parse(base_url).host, Uri.parse(base_url).path + endpoint, params);
    var response = await http.post(uri);

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
    String base_url =  await baseUrl();
    String url = "$base_url$endpoint";

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

  Future<bool> isUrlAlive(String url) async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode != 200)
      {
        return false;
      }
      return true;
    } on SocketException {
      return false;
    }
  }
}