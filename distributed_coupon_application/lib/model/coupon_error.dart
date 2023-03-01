import 'package:flutter/material.dart';

class CouponError {
  @protected
  CouponError();

  factory CouponError.InvalidRequest() = InvalidRequest;
}

class InvalidRequest extends CouponError {

}
