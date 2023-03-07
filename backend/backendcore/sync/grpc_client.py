from backendcore.sync.proto import coupon_pb2_grpc, coupon_pb2
from backendcore.sync.proto import vendor_pb2_grpc, vendor_pb2
import service_pb2_grpc
import grpc

class GRPCClient:

    def __init__(self, hosts):
        self.hosts = hosts

    def execute(self, func):
        for host in self.hosts:
            with(grpc.insecure_channel(host) as channel):
                 stub = service_pb2_grpc.RemoteServiceStub(channel)
                 func(stub)

    def CreateCoupon(self):
        execute(lambda stub: stub.CreateCoupon(
            coupon_pb2.Coupon(
                id=1,
                vendorID=12,
                expiryDate="2022-12-12",
                title="title test",
                description="test desc",
                quantity=5,
                isMultiuse=False
            )
        ))

    def CreateVendor(self):
        print("create vendor")

    def DestroyCoupon(self):
        print("destroy coupon")

    def DestroyVendor(self):
        print("destroy vendor")

