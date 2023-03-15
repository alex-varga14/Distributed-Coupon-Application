from rest_framework import serializers
from backendcore import models

# https://www.django-rest-framework.org/api-guide/serializers/#specifying-which-fields-to-include
class PlaceholderSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.PlaceholderModel
        fields = ["text", "number"]

class VendorSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Vendor
        fields = ['id', 'country', 'city', 'vendorName']

class CouponSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Coupon
        fields = ['id', 'vendorID', 'expiryDate', 'title', 'description', 'quantity','isMultiuse']

class ProcSerializer(serializers.Serializer):
    pid = serializers.IntegerField()
    leader_result = serializers.BooleanField()


