from django.shortcuts import render
from rest_framework import permissions
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from backendcore import models, serializers
from backendcore import dal

# Create your views here.

# https://www.django-rest-framework.org/tutorial/quickstart/
class PlaceholderAPIView(APIView):


    # GET /placeholder/?param1={},param2={}
    # param 1 is required, param 2 is optional
    def get(self, request, *args, **kwargs):

        param1 = request.query_params.get("param1")
        param2 = request.query_params.get("param2", "default_val")

        if param1 == None:
            return Response("Bad request. param1 is missing", status=status.HTTP_400_BAD_REQUEST)

        model = models.PlaceholderModel(f"param1 is {param1}, param2 is {param2}", 123)
        serializer = serializers.PlaceholderSerializer(model)

        return Response(serializer.data, status=status.HTTP_200_OK)


    # POST /placeholder with a body parameter "data"
    def post(self, request, *args, **kwargs):
        param = request.query_params.get("data")

        model = models.PlaceholderModel(f"post data is {param}", 456)
        serializer = serializers.PlaceholderSerializer(model)
        return Response(serializer.data, status=status.HTTP_200_OK)

# https://www.django-rest-framework.org/api-guide/filtering/
class Placeholder1APIView(APIView):
    # GET /placeholder1/{parameter}/
    def get(self, request, *args, **kwargs):
        query = kwargs["query"]

        model = models.PlaceholderModel(f"query is {query}", 5)
        serializer = serializers.PlaceholderSerializer(model)
        return Response(serializer.data, status=status.HTTP_200_OK)


class CouponsAPIView(APIView):

    # GET /coupons
    def get(self, request, *args, **kwargs):
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
        vendorId = request.query_params.get("vendorID")
        expiryDate = request.query_params.get("expiryDate")
        title = request.query_params.get("title")
        description = request.query_params.get("description")
        quantity = request.query_params.get("quantity")
        isMultiuse = request.query_params.get("isMultiuse")


        coupon = dal.createCoupon(vendorId, expiryDate, title, description, quantity, isMultiuse)
        serializer = serializers.CouponSerializer(coupon)
        return Response(serializer.data, status=status.HTTP_200_OK)

class VendorsAPIView(APIView):

    # GET /vendors
    def get(self, request, *args, **kwargs):
        couponID = request.query_params.get("id") # TODO: what is this for?
        vendorID = request.query_params.get("vendorID")
        title = request.query_params.get("title") # TODO: what is this for?
        country = request.query_params.get("country")
        city = request.query_params.get("city")
        name = request.query_params.get("name")

        # DAL call here, then return data model

        # temp code (can be reused)
        model = models.Vendor(vendorID, country, city, name)
        syncclient.createVendor(model)
        serializer = serializers.VendorSerializer(model)

        return Response(serializer.data, status=status.HTTP_200_OK)

    # POST /vendors
    def post(self, request, *args, **kwargs):
        couponID = request.query_params.get("id") # TODO: what is this for?
        vendorID = request.query_params.get("vendorID")
        title = request.query_params.get("title") # TODO: what is this for?
        country = request.query_params.get("country")
        city = request.query_params.get("city")
        name = request.query_params.get("name")

        # DAL call here, then return data model

        # temp code (can be reused)
        model = models.Vendor(vendorID, country, city, name)
        serializer = serializers.VendorSerializer(model)

        return Response(serializer.data, status=status.HTTP_200_OK)






