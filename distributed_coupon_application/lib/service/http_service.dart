import 'dart:convert';

import 'package:distributed_coupon_application/model/api_error.dart';
import 'package:http/http.dart' as http;
import 'package:result_type/result_type.dart';

abstract class HttpService {

  String baseUrl();
  T? deserialize<T>(dynamic data);

  Future<Result<T, APIError>> post<T>(String endpoint, [Map<String, Object>? params]) async {
    var response = await http.post(Uri.parse(baseUrl() + endpoint), body: params);

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
    final uri = Uri.http(baseUrl(), endpoint, params);
    var response = await http.get(uri);

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
}