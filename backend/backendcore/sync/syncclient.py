from backendcore.sync import grpc_client

grpcClient = grpc_client.GRPCClient(
    [
        "localhost:50000",
        "localhost:50001",
        "localhost:50002",
        "localhost:50003",
    ]
)

# Synchronization client for forwarding API requests to other passive replicas.
# This should ONLY be invoked by the DAL.


def createVendor():
    pass

def createCoupon(coupon):
    grpcClient.CreateCoupon(coupon)

