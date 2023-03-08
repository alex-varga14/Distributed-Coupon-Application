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
        fields = ['vendorID', 'country', 'city', 'vendorName']

class CouponSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Coupon
        fields = ['couponID', 'vendorID', 'date', 'title', 'description', 'quantity','isMultiuse']