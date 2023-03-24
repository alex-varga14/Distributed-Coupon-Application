from math import *

def getBounds(lat, long, distance):
    """
        Creates a bounding box from the center point (lat, long) +-
        (distance_lat, distance_long) around the point.

        Returns a tuple of tuples:
            ( (latMin, latMax), (longMin, longMax) )
    """

    # lat per 100 km = 1 deg / 110.574 km
    # long per 100 km = 1 deg / (111.320 * cos(latitude) km)
    
    latMin = lat - distance / 110.574
    longMin = long - distance / (111.320 * cos(radians(latMin)))

    latMax = lat + distance / 110.574
    longMax = long + distance / (111.320 * cos(radians(longMax)))

    return ( (latMin, latMax), (longMin, longMax) )


