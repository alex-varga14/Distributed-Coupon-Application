import 'package:flutter/material.dart';

class RequestError {
  @protected
  RequestError();

  factory RequestError.InvalidRequest() = RequestErrorInvalidRequest;
  factory RequestError.DoesNotExist() = RequestErrorDoesNotExist;
  factory RequestError.NotYetImplemented() = RequestErrorNotYetImplemented;
}

class RequestErrorInvalidRequest extends RequestError {}

class RequestErrorDoesNotExist extends RequestError {}

class RequestErrorNotYetImplemented extends RequestError {}
