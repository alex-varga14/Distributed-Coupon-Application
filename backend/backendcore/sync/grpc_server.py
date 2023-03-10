from backendcore.sync.proto import coupon_pb2_grpc, coupon_pb2
from backendcore.sync.proto import vendor_pb2_grpc, vendor_pb2
from backendcore.sync.proto import service_pb2_grpc
from backendcore import models
from backendcore.sync import grpc_helper

from django.conf import settings

import grpc
from concurrent import futures
import socket, errno
from random import randrange

from backendcore.sync import syncserver
import threading

# port = 0

class GRPCServer(service_pb2_grpc.RemoteService):
    """
    All methods here will be invoked via RPC by the leader replica.
    """

    def __init__(self, syncServer):
        self.syncServer = syncServer

    def CreateCoupon(self, request, context):
        # request is coupon_pb2.Coupon
        model = grpc_helper.from_grpc_model(request)

        self.syncServer.createCoupon(model)

        return grpc_helper.from_backend_model(model)

        # self.syncServer.createCoupon()
        # return coupon_pb2.Coupon(
        #     id=1,
        #     vendorID=12,
        #     expiryDate="2022-12-12",
        #     title="title test",
        #     description="test desc",
        #     quantity=5,
        #     isMultiuse=False
        # )


    def CreateVendor(self, request, context):
        # request is vendor_pb2.Vendor
        model = grpc_helper.from_grpc_model(request)
        self.syncServer.createVendor(model)
        return grpc_helper.from_backend_model(model)

    def DestroyCoupon(self, request, context):
        print("destroy coupon")

    def DestroyVendor(self, request, context):
        print("destroy vendor")

# def is_port_available(port):
#     s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#     try:
#         s.bind(("127.0.0.1", port))
#         return True
#     except socket.error as e:
#         return False
#     finally:
#         s.close()

def serve(syncServer):
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=2))
    service_pb2_grpc.add_RemoteServiceServicer_to_server(GRPCServer(syncServer), server)

    # p = randrange(10000) + 50000 # port 50000-59999
    # while (not is_port_available(p)):
    #     p = randrange(10000) + 50000

    # p = 50000
    # while (not is_port_available(p)):
        # p += 1

    # global port
    # port = p

    p = settings.GRPC_PORT

    def task():
        server.add_insecure_port(f"[::]:{p}")
        server.start()
        print(f"gRPC server started on port {p}")
        server.wait_for_termination()
        print("gRPC server dead")

    th = threading.Thread(target=task, args={}, kwargs={})
    th.start()


