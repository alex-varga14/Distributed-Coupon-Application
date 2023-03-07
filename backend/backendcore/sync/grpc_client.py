from backendcore.sync.proto import coupon_pb2_grpc, coupon_pb2
from backendcore.sync.proto import vendor_pb2_grpc, vendor_pb2
from backendcore.sync.proto import service_pb2_grpc
from backendcore.sync import grpc_server

import grpc
import threading

class GRPCClient:

    def __init__(self, hosts):
        self.hosts = hosts

    def execute(self, func):
        def task():
            for host in self.hosts:
                # don't send it to ourselves
                if host[-5:] == str(grpc_server.port): # to bypass, add 'and False'
                    continue

                with(grpc.insecure_channel(host) as channel):
                    try:
                        print(f"Performing RPC on {host}")
                        grpc.channel_ready_future(channel).result(timeout=2) # seconds
                        stub = service_pb2_grpc.RemoteServiceStub(channel)
                        func(stub)
                    except grpc.FutureTimeoutError:
                        print(f"Dead server at {host}")

        th = threading.Thread(target=task, args={}, kwargs={})
        th.start()

    def CreateCoupon(self):
        self.execute(lambda stub: stub.CreateCoupon(
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

