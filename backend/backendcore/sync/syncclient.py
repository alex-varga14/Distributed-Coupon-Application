from backendcore.sync import grpc_client

grpcClient = grpc_client.GRPCClient(
    [
        "localhost:50000",
        "localhost:50001"
    ]
)

# Synchronization client for forwarding API requests to other passive replicas.
# This should ONLY be invoked by the DAL.


def createVendor():
    pass

def createCoupon():
    # TODO: receive model parameter, then pass parameter to grpcClient
    grpcClient.CreateCoupon()

