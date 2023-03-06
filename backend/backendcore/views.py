from django.shortcuts import render
from rest_framework import permissions
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from backendcore import models, serializers

# Create your views here.

# https://www.django-rest-framework.org/tutorial/quickstart/
class PlaceholderAPIView(APIView):

    def get(self, request, *args, **kwargs):
        model = models.PlaceholderModel("abc_get", 123)
        serializer = serializers.PlaceholderSerializer(model)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, *args, **kawargs):
        model = models.PlaceholderModel("abc_post", 123)
        serializer = serializers.PlaceholderSerializer(model)
        return Response(serializer.data, status=status.HTTP_200_OK)



class UserAPIView(APIView):
    pass




