# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: service.proto
"""Generated protocol buffer code."""
from google.protobuf.internal import builder as _builder
from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import symbol_database as _symbol_database
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()


import vendor_pb2 as vendor__pb2
import coupon_pb2 as coupon__pb2
from google.protobuf import empty_pb2 as google_dot_protobuf_dot_empty__pb2


DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\rservice.proto\x12\x06remote\x1a\x0cvendor.proto\x1a\x0c\x63oupon.proto\x1a\x1bgoogle/protobuf/empty.proto2\xe9\x01\n\rRemoteService\x12\x30\n\x0c\x43reateCoupon\x12\x0e.remote.Coupon\x1a\x0e.remote.Coupon\"\x00\x12\x30\n\x0c\x43reateVendor\x12\x0e.remote.Vendor\x1a\x0e.remote.Vendor\"\x00\x12\x39\n\rDestroyCoupon\x12\x0e.remote.Coupon\x1a\x16.google.protobuf.Empty\"\x00\x12\x39\n\rDestroyVendor\x12\x0e.remote.Vendor\x1a\x16.google.protobuf.Empty\"\x00\x62\x06proto3')

_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, globals())
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'service_pb2', globals())
if _descriptor._USE_C_DESCRIPTORS == False:

  DESCRIPTOR._options = None
  _REMOTESERVICE._serialized_start=83
  _REMOTESERVICE._serialized_end=316
# @@protoc_insertion_point(module_scope)
