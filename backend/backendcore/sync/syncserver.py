from backendcore.sync import grpc_server
from backendcore import dal

class SyncServer:
    """
    Synchronization server for receiving API requests from the leader replica.

    Each method implementation in here must be only invoked by the gRPC server
    (or alternative server communication protocols). Each method implementation
    must only call methods in the DAL (i.e. a layer below it).
    """

    def createVendor(self, vendor):
        print(f"Invocation createVendor received from leader. Model: {vendor}")
        dal.createVendor(vendor.id, vendor.country, vendor.city, vendor.vendorName)

    def createCoupon(self, coupon):
        print(f"Invocation createCoupon received from leader. Model: {coupon}")
        dal.createCoupon(coupon.id, coupon.vendorID, coupon.expiryDate, coupon.title, coupon.description, coupon.quantity, coupon.isMultiuse)

def serve():
    grpc_server.serve(SyncServer());


