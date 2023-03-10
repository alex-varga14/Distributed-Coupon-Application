
from backendcore import models
from backendcore import repository
from backendcore.sync import syncclient

from django.conf import settings

def createCoupon(vendorId, expiryDate, title, description, quantity, isMultiuse):
    coupon = models.Coupon(
        vendorID=vendorId,
        expiryDate=expiryDate,
        title=title,
        description=description,
        quantity=quantity,
        isMultiuse=isMultiuse,
    )

    coupon.save()

    syncclient.createCoupon(coupon)
    return coupon

def getCoupons(idd, vendorId, expiryDate, title, description, name, isMultiuse):
    return models.Coupon.objects.all().values()

def createVendor():
    pass

def getVendors():
    pass

