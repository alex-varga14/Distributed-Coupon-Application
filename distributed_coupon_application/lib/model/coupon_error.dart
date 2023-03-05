import 'package:flutter/material.dart';

class RequestError {
  @protected
  RequestError();

  factory RequestError.InvalidRequest() = RequestErrorInvalidRequest;
  factory RequestError.DoesNotExist() = RequestErrorDoesNotExist;
}

class RequestErrorInvalidRequest extends RequestError {
}

class RequestErrorDoesNotExist extends RequestError {

}
