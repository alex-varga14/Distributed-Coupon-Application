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

    lat = models.FloatField()
    long = models.FloatField()

    def decrement_quantity(self):
        self.quantity = self.quantity - 1

class ProcLeader():
    def __init__(self, is_leader, leader_host):
        self.is_leader = is_leader
        self.leader_host = leader_host


class ProcInternalReq():
    def __init__(self, leader_result):
        self.leader_result = leader_result





