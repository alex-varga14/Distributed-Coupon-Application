from backendcore.sync.proto import coupon_pb2
from backendcore.sync.proto import vendor_pb2
from backendcore import models

def from_grpc_model(grpc_model):
    if isinstance(grpc_model, coupon_pb2.Coupon):
        return models.Coupon(
            grpc_model.id,
            grpc_model.vendorID,
            grpc_model.expiryDate,
            grpc_model.title,
            grpc_model.description,
            grpc_model.quantity,
            grpc_model.isMultiuse
        )

    elif isinstance(grpc_model, vendor_pb2.Vendor):
        return models.Vendor(
            grpc_model.id,
            grpc_model.country,
            grpc_model.city,
            grpc_model.vendorName
        )
    return None

def from_backend_model(model):
    if isinstance(model, models.Vendor):
        print("serializing Vendor to grpc")
        return vendor_pb2.Vendor(
            id = model.id,
            country = model.country,
            city = model.city,
            vendorName = model.vendorName
        )

    elif isinstance(model, models.Coupon):
        print("serializing Coupon to grpc")
        return coupon_pb2.Coupon(
            id = model.id,
            vendorID = model.vendorID,
            expiryDate = model.expiryDate,
            title = model.title,
            description = model.description,
            quantity = model.quantity,
            isMultiuse = model.isMultiuse
        )
    print(f"unknown: {type(model)}")

    return None





