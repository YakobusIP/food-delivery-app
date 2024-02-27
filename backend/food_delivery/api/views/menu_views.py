from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from ..models import Restaurant, Menu
from ..serializers.menu_serializers import MenuSerializer
from ..permissions import IsAuthenticated, IsAuthenticatedRestaurantRole
from django.shortcuts import get_object_or_404

class MenuAPIView(APIView):
    def get_permissions(self):
        permission_classes = [IsAuthenticatedRestaurantRole] if self.request.method == "POST" else [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def get(self, request, restaurant_id):
        menus = Menu.objects.filter(restaurant_id=restaurant_id)
        serializer = MenuSerializer(menus, many=True)
        return Response({ "data": serializer.data })
    
    def post(self, request, restaurant_id):
        restaurant = get_object_or_404(Restaurant, id=restaurant_id, owner=request.user)
        
        data = {
            **request.data,
            "restaurant_id": restaurant.id
        }
        
        serializer = MenuSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({ "message": "Menu successfully added" }, status=status.HTTP_201_CREATED)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)
    
class MenuListAPIView(APIView):
    def get_permissions(self):
        permission_classes = [IsAuthenticatedRestaurantRole] if self.request.method in ["PUT", "DELETE"] else [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def get_restaurant_menu(self, restaurant_id, menu_id):
        try:
            return Menu.objects.filter(restaurant_id=restaurant_id).get(id=menu_id)
        except Menu.DoesNotExist:
            return Response({ "errors": "Menu not found" }, status=status.HTTP_404_NOT_FOUND)
    
    def get(self, request, restaurant_id, menu_id):
        menu = get_object_or_404(Menu, id=menu_id, restaurant_id=restaurant_id)
        serializer = MenuSerializer(menu)
        return Response({ "data": serializer.data })
    
    def put(self, request, restaurant_id, menu_id):
        menu = get_object_or_404(Menu, id=menu_id, restaurant_id=restaurant_id)
        
        if menu.restaurant.owner != request.user:
            return Response({"errors": "You are not authorized to update this menu"}, status=status.HTTP_403_FORBIDDEN)

        serializer = MenuSerializer(instance=menu, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({ "message": "Menu successfully updated" }, status=status.HTTP_200_OK)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, restaurant_id, menu_id):
        menu = get_object_or_404(Menu, id=menu_id, restaurant_id=restaurant_id)
        
        if menu.restaurant.owner != request.user:
            return Response({"errors": "You are not authorized to update this menu"}, status=status.HTTP_403_FORBIDDEN)
        
        menu.delete()
        return Response({ "message": "Menu successfully deleted" }, status=status.HTTP_200_OK)