from backendcore.sync.proto import coupon_pb2_grpc, vendor_pb2_grpc, service_pb2_grpc
import grpc
from concurrent import futures
import socket, errno
from random import randrange

class GRPCServer(service_pb2_grpc.RemoteService):
    def CreateCoupon(self, request, context):
        print("create coupon")
    
    def CreateVendor(self, request, context):
        print("create vendor")

    def DestroyCoupon(self, request, context):
        print("destroy coupon")

    def DestroyVendor(self, request, context):
        print("destroy vendor")

def is_port_available(port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.bind(("127.0.0.1", port))
        return True
    except socket.error as e:
        return False
    finally:
        s.close()

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=2))
    service_pb2_grpc.add_RemoteServiceServicer_to_server(GRPCServer(), server)
    p = randrange(10000) + 50000 # port 50000-59999
    while (not is_port_available(p)):
        p = randrange(10000) + 50000

    server.add_insecure_port(f"[::]:{p}")
    server.start()

    print(f"gRPC server started on port {p}")

