from django.shortcuts import render, redirect
from rest_framework import permissions
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from backendcore import models, serializers
from backendcore import dal
from backendcore import proc
from backendcore import utils

import requests

def port(request):
    return request.META["SERVER_PORT"]

def notALeader():
    return Response("Not a leader.", status = status.HTTP_421_MISDIRECTED_REQUEST)

# Create your views here.

# https://www.django-rest-framework.org/tutorial/quickstart/
class PlaceholderAPIView(APIView):


    # GET /placeholder/?param1={},param2={}
    # param 1 is required, param 2 is optional
    def get(self, request, *args, **kwargs):

        if not proc.is_leader(port(request)): return notALeader()

        param1 = request.query_params.get("param1")
        param2 = request.query_params.get("param2", "default_val")

        if param1 == None:
            return Response("Bad request. param1 is missing", status=status.HTTP_400_BAD_REQUEST)

        model = models.PlaceholderModel(f"param1 is {param1}, param2 is {param2}", 123)
        serializer = serializers.PlaceholderSerializer(model)

        return Response(serializer.data, status=status.HTTP_200_OK)


    # POST /placeholder with a body parameter "data"
    def post(self, request, *args, **kwargs):

        if not proc.is_leader(port(request)): return notALeader()

        param = request.query_params.get("data")

        model = models.PlaceholderModel(f"post data is {param}", 456)
        serializer = serializers.PlaceholderSerializer(model)
        return Response(serializer.data, status=status.HTTP_200_OK)

# https://www.django-rest-framework.org/api-guide/filtering/
class Placeholder1APIView(APIView):
    # GET /placeholder1/{parameter}/
    def get(self, request, *args, **kwargs):

        if not proc.is_leader(port(request)): return notALeader()

        query = kwargs["query"]

        model = models.PlaceholderModel(f"query is {query}", 5)
        serializer = serializers.PlaceholderSerializer(model)
        return Response(serializer.data, status=status.HTTP_200_OK)


class CouponsAPIView(APIView):

    # GET /coupons
    def get(self, request, *args, **kwargs):

        if not proc.is_leader(port(request)): return notALeader()

        idd = request.query_params.get("id")
        vendorId = request.query_params.get("vendorID")
        expiryDate = request.query_params.get("expiryDate")
        title = request.query_params.get("title")
        description = request.query_params.get("description")
        name = request.query_params.get("name")
        isMultiuse = request.query_params.get("isMultiuse")

        coupons = dal.getCoupons(idd, vendorId, expiryDate, title, description, name, isMultiuse)
        serializer = serializers.CouponSerializer(coupons, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)

    # POST /coupons
    def post(self, request, *args, **kwargs):

        if not proc.is_leader(port(request)): return notALeader()

        vendorId = int(request.query_params.get("vendorID"))
        expiryDate = request.query_params.get("expiryDate")
        title = request.query_params.get("title")
        description = request.query_params.get("description")
        quantity = int(request.query_params.get("quantity"))
        isMultiuse = bool(request.query_params.get("isMultiuse"))
        lat = float(request.query_params.get("lat"))
        long = float(request.query_params.get("long"))


        coupon = dal.createCoupon(None, vendorId, expiryDate, title, description, quantity, isMultiuse, lat, long, True)
        serializer = serializers.CouponSerializer(coupon)
        return Response(serializer.data, status=status.HTTP_200_OK)

class VendorsAPIView(APIView):

    # GET /vendors
    def get(self, request, *args, **kwargs):

        if not proc.is_leader(port(request)): return notALeader()

        couponID = request.query_params.get("id") # TODO: what is this for?
        vendorID = request.query_params.get("vendorID")
        title = request.query_params.get("title") # TODO: what is this for?
        country = request.query_params.get("country")
        city = request.query_params.get("city")
        name = request.query_params.get("name")

        vendor = dal.getVendors(vendorID, country, city, name)
        serializer = serializers.VendorSerializer(vendor, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)

    # POST /vendors
    def post(self, request, *args, **kwargs):

        if not proc.is_leader(port(request)): return notALeader()

        couponID = request.query_params.get("id") # TODO: what is this for?
        vendorID = request.query_params.get("vendorID") # TODO: should we eliminate this:
        title = request.query_params.get("title") # TODO: what is this for?
        country = request.query_params.get("country")
        city = request.query_params.get("city")
        name = request.query_params.get("name")


        vendor = dal.createVendor(None, country, city, name, True)
        serializer = serializers.VendorSerializer(vendor)

        return Response(serializer.data, status=status.HTTP_200_OK)


class ProcLeaderAPIView(APIView):

    # GET /proc/leader
    # returns True if the replica is a leader
    def get(self, request, *args, **kwargs):
        p = port(request)
        data = vars(models.ProcLeader(proc.is_leader(p), proc.get_leader(p)))
        serializer = serializers.ProcLeaderSerializer(data)
        return Response(serializer.data, status=status.HTTP_200_OK)


    # POST /proc/leader?hosts=a,b,c
    #
    # initiates leader election with the given hosts, or attempt to connect
    # to all if not given
    def post(self, request, *args, **kwargs):
        # hosts = request.query_params.get("hosts", [])
        hosts = request.data.get("hosts", [])
        if len(hosts) != 0:
            # hosts = requests.utils.unquote(hosts)
            # hosts = utils.fromBase64(hosts)
            hosts = hosts.split(",")

        # subsequent leadre eldctions will have hosts filled with IPs. for new
        # elections, the hosts is empty.
        p = port(request)
        leader_host = proc.elect_leader(p, hosts)

        data = vars(models.ProcLeader(proc.is_leader(p), leader_host))
        serializer = serializers.ProcLeaderSerializer(data)

        return Response(serializer.data, status=status.HTTP_200_OK)


class ProcLeaderReqAPIView(APIView):

    # GET /proc/leader/<req>
    #
    # returns {"leader_result": False} if the 
    # remote process has a lower PID
    def get(self, request, *args, **kwargs):
        pid = kwargs["pid"]
        try:
            int(pid)
        except TypeError:
            return Response("Bad request. Not an integer", status=status.HTTP_400_BAD_REQUEST)

        result = proc.is_remote_pid_higher(int(pid))

        data = vars(models.ProcInternalReq(result))
        serializer = serializers.ProcInternalReqSerializer(data)

        return Response(serializer.data, status=status.HTTP_200_OK)


