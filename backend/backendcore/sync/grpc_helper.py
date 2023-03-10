from backendcore.sync.proto import coupon_pb2
from backendcore.sync.proto import vendor_pb2
from backendcore import models

def from_grpc_model(grpc_model):
    if isinstance(grpc_model, coupon_pb2.Coupon):
        if grpc_model.id == -1:
            idd = None
        else:
            idd = grpc_model.id
        return models.Coupon(
            idd,
            grpc_model.vendorID,
            grpc_model.expiryDate,
            grpc_model.title,
            grpc_model.description,
            grpc_model.quantity,
            grpc_model.isMultiuse
        )

    elif isinstance(grpc_model, vendor_pb2.Vendor):
        if grpc_model.id == -1:
            idd = None
        else:
            idd = grpc_model.id
        return models.Vendor(
            idd,
            grpc_model.country,
            grpc_model.city,
            grpc_model.vendorName
        )
    return None

def from_backend_model(model):
    if isinstance(model, models.Vendor):
        print("serializing Vendor to grpc")
        if model.id == None:
            idd = -1
        else:
            idd = model.id
        return vendor_pb2.Vendor(
            id = idd,
            country = model.country,
            city = model.city,
            vendorName = model.vendorName
        )

    elif isinstance(model, models.Coupon):
        print("serializing Coupon to grpc")
        if model.id == None:
            idd = -1
        else:
            idd = model.id
        return coupon_pb2.Coupon(
            id = idd,
            vendorID = model.vendorID,
            expiryDate = model.expiryDate,
            title = model.title,
            description = model.description,
            quantity = model.quantity,
            isMultiuse = model.isMultiuse
        )
    print(f"unknown: {type(model)}")

    return None





