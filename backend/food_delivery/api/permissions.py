from rest_framework import permissions

class IsAuthenticated(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated
    
class IsAuthenticatedCustomerRole(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "CUSTOMER"
    
class IsAuthenticatedRestaurantRole(permissions.BasePermission):
    def has_permission(self, request, view):        
        return request.user.is_authenticated and request.user.role == "RESTAURANT"
    
class IsAuthenticatedDeliveriesRole(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "DELIVERY"