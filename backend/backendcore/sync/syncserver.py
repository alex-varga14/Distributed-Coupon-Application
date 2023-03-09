from backendcore.sync import grpc_server

class SyncServer:
    """
    Synchronization server for receiving API requests from the leader replica.

    Each method implementation in here must be only invoked by the gRPC server
    (or alternative server communication protocols). Each method implementation
    must only call methods in the DAL (i.e. a layer below it).
    """

    def createVendor(self):
        pass

    def createCoupon(self, coupon):
        print(f"Invocation received from leader. Model: {coupon}")

def serve():
    grpc_server.serve(SyncServer());


