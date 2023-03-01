import 'package:flutter/material.dart';

class RequestError {
  @protected
  RequestError();

  factory RequestError.InvalidRequest() = InvalidRequest;
  factory RequestError.DoesNotExist() = DoesNotExist;
}

class InvalidRequest extends RequestError {
}

class DoesNotExist extends RequestError {

}
