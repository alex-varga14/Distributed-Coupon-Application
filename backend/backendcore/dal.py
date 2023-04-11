from backendcore import models
from backendcore import repository
from backendcore.sync import syncclient

from django.conf import settings

def createCoupon(idd, vendorId, expiryDate, title, description, quantity, isMultiuse, leader=False):
    coupon = models.Coupon(
        id=idd,
        vendorID=vendorId,
        expiryDate=expiryDate,
        title=title,
        description=description,
        quantity=quantity,
        isMultiuse=isMultiuse,
    )

    coupon.save()

    if leader:
        syncclient.createCoupon(coupon)
    return coupon

def getCoupons(idd, vendorId, expiryDate, title, description, name, isMultiuse):
    return models.Coupon.objects.all().values()

def createVendor(vendorID, country, city, name, leader=False):
    vendor = models.Vendor(
        id=vendorID,
        country=country,
        city=city,
        vendorName=name)

    vendor.save()

    if leader:
        syncclient.createVendor(vendor)
    return vendor

def getVendors(vendorID, country, city, name):
    return models.Vendor.objects.all().values()