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

class ProcLeaderSerializer(serializers.Serializer):
    is_leader = serializers.BooleanField()
    leader_host = serializers.CharField(max_length=255)

class ProcInternalReqSerializer(serializers.Serializer):
    leader_result = serializers.BooleanField()


