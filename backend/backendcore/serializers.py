from rest_framework import serializers
from backendcore import models


#user
from django.contrib.auth.models import User
from rest_framework.validators import UniqueTogetherValidator
from models import Profile
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



# USER RELATED FROM HERE

class UserSerializer(serializers.ModelSerializer):

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user
    
    class Meta: 
        model = User
        fields = (
            'username',
            'full_name',
            'password',
            'email',
            'city',
        )

        validators = [
            
           UniqueTogetherValidator(
                queryset=User.objects.all(),
                fields=['username', 'email']
            )
        ]



class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = ('fullname', 'city')



