import 'package:flutter/material.dart';

class APIError {
  @protected
  APIError();

  factory APIError.HTTPError(int code, [String? message]) = APIHTTPError;
  factory APIError.MappingError() = APIMappingError;
}

class APIHTTPError extends APIError {
  int code;
  String? message;

  APIHTTPError(this.code, [this.message]);

  @override
  String toString() {
    return "APIHTTPError $code: $message";
  }
}

class APIMappingError extends APIError {
}
