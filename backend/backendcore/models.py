from django.db import models

# Create your models here.

# https://www.django-rest-framework.org/api-guide/fields/
class PlaceholderModel(models.Model):
    text = models.CharField(max_length=25)
    number = models.IntegerField()

    def __init__(self, text, number):
        self.text = text
        self.number = number

