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

