from django.db import models

###########################
## Note: after creating a class here, run 
#
# python manage.py makemigrations
# python manage.py migrate
#
# in order to sync the data models with the db. Otherwise there will be an error when trying to
# run the program.
###########################

# Create your models here.

# https://www.django-rest-framework.org/api-guide/fields/
class PlaceholderModel(models.Model):
    text = models.CharField(max_length=25)
    number = models.IntegerField()

    def __init__(self, text, number):
        self.text = text
        self.number = number
   

class Vendor(models.Model):
    id = models.IntegerField(primary_key=True)
    country = models.CharField(max_length=20)
    city = models.CharField(max_length=20)
    vendorName = models.CharField(max_length=20)

    def __init__(self, vendorID, country, city, vendorName):
        self.id = id
        self.country = country
        self.city = city
        self.vendorName = vendorName
    

class Coupon(models.Model):
    id = models.IntegerField(primary_key=True)
    vendorID = models.IntegerField()
    expiryDate = models.CharField(max_length=25)
    title = models.CharField(max_length=50)
    description = models.TextField(max_length=150)
    quantity = models.IntegerField()
    isMultiuse = models.BooleanField(default=False)

    def __init__(self, couponID, vendorID, expiryDate, title, description, quantity,isMultiuse):
        self.id = couponID
        self.vendorID = vendorID
        self.expiryDate = expiryDate
        self.title = title
        self.description = description
        self.quantity = quantity
        self.isMultiuse = isMultiuse

    def decrement_quantity(self):
        self.quantity = self.quantity - 1

