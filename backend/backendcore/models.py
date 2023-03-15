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

class Vendor(models.Model):
    id = models.IntegerField(primary_key=True)
    country = models.CharField(max_length=20)
    city = models.CharField(max_length=20)
    vendorName = models.CharField(max_length=20)

class Coupon(models.Model):
    id = models.IntegerField(primary_key=True) # TODO: id is bad name
    vendorID = models.IntegerField()
    expiryDate = models.CharField(max_length=25)
    title = models.CharField(max_length=50)
    description = models.TextField(max_length=150)
    quantity = models.IntegerField()
    isMultiuse = models.BooleanField(default=False)

    def decrement_quantity(self):
        self.quantity = self.quantity - 1

class Proc():

    def __init__(self, *args, **kwargs):
        self.pid = kwargs.get("pid", -1)
        self.leader_result = kwargs.get("leader_result", False)



