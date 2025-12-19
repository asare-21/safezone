"""
Custom permission classes for SafeZone API.
"""
from rest_framework import permissions


class IsAuthenticatedOrReadOnly(permissions.BasePermission):
    """
    Allow read-only access to unauthenticated users,
    but require authentication for write operations.
    """
    
    def has_permission(self, request, view):
        # Allow GET, HEAD, OPTIONS for anyone
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Require authentication for POST, PUT, PATCH, DELETE
        return request.user and request.user.is_authenticated
