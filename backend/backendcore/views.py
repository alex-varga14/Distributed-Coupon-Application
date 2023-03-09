from django.shortcuts import render
from rest_framework import permissions
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from backendcore import models, serializers

from backendcore.sync import syncclient

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


class CouponAPIView(APIView):

    # GET /coupons
    def get(self, request, *args, **kwargs):
        idd = request.query_params.get("id")
        vendorId = request.query_params.get("vendorID")
        expiryDate = request.query_params.get("expiryDate")
        title = request.query_params.get("title")
        description = request.query_params.get("description")
        name = request.query_params.get("name")
        isMultiuse = request.query_params.get("isMultiuse")

        model = models.Coupon(123, 456, "2022-12-22", "title", "desc", 5, False)
        syncclient.createCoupon(model)
        serializer = serializers.CouponSerializer(model)

        return Response(serializer.data, status=status.HTTP_200_OK)

    # POST /coupons
    def post(self, request, *args, **kwargs):
        idd = request.query_params.get("id")
        vendorId = request.query_params.get("vendorID")
        expiryDate = request.query_params.get("expiryDate")
        title = request.query_params.get("title")
        description = request.query_params.get("description")
        name = request.query_params.get("name")
        isMultiuse = request.query_params.get("isMultiuse")

        # DAL call here, then return data model

        model = models.Coupon(123, 456, "2022-12-22", "title", "desc", 5, False)
        serializer = serializers.CouponSerializer(model)
        return Response(serializer.data, status=status.HTTP_200_OK)




