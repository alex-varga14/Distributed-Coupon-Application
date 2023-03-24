
from backendcore import models
from backendcore import repository
from backendcore.sync import syncclient

from django.conf import settings

from backendcore import geolocation

def createCoupon(idd, vendorId, expiryDate, title, description, quantity, isMultiuse, lat, long, leader=False):
    coupon = models.Coupon(
        id=idd,
        vendorID=vendorId,
        expiryDate=expiryDate,
        title=title,
        description=description,
        quantity=quantity,
        isMultiuse=isMultiuse,
        lat=lat,
        long=long
    )

    coupon.save()

    if leader:
        syncclient.createCoupon(coupon)
    return coupon

def getCoupons(idd, vendorId, expiryDate, title, description, name, isMultiuse):
    return models.Coupon.objects.all().values()

# prevents attackers from injecting random parameters
MODE_1KM = 0
MODE_5KM = 1
MODE_10KM = 2
MODE_25KM = 3
MODE_50KM = 4
MODE_100KM = 5

def _mode_to_km(mode):
    if mode == MODE_1KM: return 1
    if mode == MODE_5KM: return 5
    if mode == MODE_10KM: return 10
    if mode == MODE_25KM: return 2
    if mode == MODE_50KM: return 50
    if mode == MODE_100KM: return 100

    return 0


def getCouponsInRange(lat, long, mode):
    bounds = geolocation.getBounds(_mode_to_km(mode))

    return models.Coupons.objects \
        .filter(
            lat__range=bounds[0],
            long__range=bounds[1]
        )


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

