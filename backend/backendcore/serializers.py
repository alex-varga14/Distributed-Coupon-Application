from rest_framework import serializers
from backendcore import models

# https://www.django-rest-framework.org/api-guide/serializers/#specifying-which-fields-to-include
class PlaceholderSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.PlaceholderModel
        fields = ["text", "number"]
