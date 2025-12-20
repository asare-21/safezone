"""Utility functions for the alerts app."""
from math import radians, cos, sin, asin, sqrt


def haversine_distance(lon1, lat1, lon2, lat2):
    """
    Calculate the great circle distance between two points on Earth.
    
    Args:
        lon1: Longitude of point 1 in degrees
        lat1: Latitude of point 1 in degrees
        lon2: Longitude of point 2 in degrees
        lat2: Latitude of point 2 in degrees
    
    Returns:
        Distance in kilometers
    """
    # Convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    
    # Haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    
    # Radius of Earth in kilometers
    km = 6371 * c
    return km
