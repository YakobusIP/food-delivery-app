from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Restaurant, Menu
from .serializers import UserSerializer, LoginSerializer, RestaurantSerializer, MenuSerializer
from .permissions import IsAuthenticated, IsAuthenticatedRestaurantRole

from datetime import datetime

# Create your views here.
class UserCreateAPIView(APIView):
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({ "message": "Register successful" }, status=status.HTTP_201_CREATED)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)
    
class LoginAPIView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            return Response({ "data": serializer.validated_data }, status=status.HTTP_200_OK)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)
    
class RestaurantAPIView(APIView):
    def get_permissions(self):
        if self.request.method == "POST":
            permission_classes = [IsAuthenticatedRestaurantRole]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def get(self, request):
        queryset = Restaurant.objects.all()

        # Filter by name
        name = request.query_params.get("name")
        if name:
            queryset = queryset.filter(name__icontains=name)

        # Filter by currently opened
        current_time_str = request.query_params.get("time")
        if current_time_str:
            current_time = datetime.strptime(current_time_str, "%H:%M").time()
            queryset = queryset.filter(opening_time__lte=current_time, closing_time__gte=current_time)
        
        # Sorting
        sort = request.query_params.get("sort", "name")
        queryset = queryset.order_by(sort)

        serializer = RestaurantSerializer(queryset, many=True)
        return Response({ "data": serializer.data })
    
    def post(self, request):
        data = {
            **request.data,
            "owner_id": request.user.id
        }
        serializer = RestaurantSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({ "message": "Restaurant successfully created" }, status=status.HTTP_201_CREATED)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)

class RestaurantDetailAPIView(APIView):
    def get_permissions(self):
        if self.request.method == "PUT":
            permission_classes = [IsAuthenticatedRestaurantRole]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def get_restaurant(self, id):
        try:
            return Restaurant.objects.get(id=id)
        except Restaurant.DoesNotExist:
            return Response({ "errors": "Restaurant not found" }, status=status.HTTP_404_NOT_FOUND)
        
    def get(self, request, id):
        restaurant = self.get_restaurant(id)
        if isinstance(restaurant, Response):
            return restaurant
        serializer = RestaurantSerializer(restaurant)
        return Response({ "data": serializer.data })
    
    def put(self, request, id):
        try:
            restaurant = Restaurant.objects.get(id=id, owner=request.user)
        except Restaurant.DoesNotExist:
            return Response({ "errors": "Restaurant not found or you're not the owner" }, status=status.HTTP_404_NOT_FOUND)
        
        data = {
            **request.data,
            "id": id
        }
        serializer = RestaurantSerializer(instance=restaurant, data=data, partial=True)

        if serializer.is_valid():
            serializer.save()
            return Response({ "message": "Restaurant successfully updated" }, status=status.HTTP_200_OK)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)
    
class MenuAPIView(APIView):
    def get_permissions(self):
        if self.request.method == "POST":
            permission_classes = [IsAuthenticatedRestaurantRole]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def get(self, request, restaurant_id):
        menus = Menu.objects.filter(restaurant_id=restaurant_id)
        serializer = MenuSerializer(menus, many=True)
        return Response({ "data": serializer.data })
    
    def post(self, request, restaurant_id):
        # Check if owner is restaurant owner
        try:
            restaurant = Restaurant.objects.get(id=restaurant_id, owner=request.user)
        except Restaurant.DoesNotExist:
            return Response({ "error": "Restaurant not found or you're not the owner" }, status=status.HTTP_404_NOT_FOUND)
        
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
        if self.request.method == "PUT" or self.request.method == "DELETE":
            permission_classes = [IsAuthenticatedRestaurantRole]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def get_restaurant_menu(self, restaurant_id, menu_id):
        try:
            return Menu.objects.filter(restaurant_id=restaurant_id).get(id=menu_id)
        except Menu.DoesNotExist:
            return Response({ "errors": "Menu not found" }, status=status.HTTP_404_NOT_FOUND)
    
    def get(self, request, restaurant_id, menu_id):
        menu = self.get_restaurant_menu(restaurant_id, menu_id)
        if isinstance(menu, Response):
            return menu
        serializer = MenuSerializer(menu)
        return Response({ "data": serializer.data })
    
    def put(self, request, restaurant_id, menu_id):
        try:
            restaurant = Restaurant.objects.get(id=restaurant_id, owner=request.user)
            menu = Menu.objects.filter(restaurant=restaurant).get(id=menu_id)
        except Restaurant.DoesNotExist:
            return Response({ "errors": "Restaurant not found or you're not the owner" }, status=status.HTTP_404_NOT_FOUND)
        except Menu.DoesNotExist:
            return Response({ "errors": "Menu not found" }, status=status.HTTP_404_NOT_FOUND)
        
        data = {
            **request.data,
            "id": id
        }
        serializer = MenuSerializer(instance=menu, data=data, partial=True)

        if serializer.is_valid():
            serializer.save()
            return Response({ "message": "Menu successfully updated" }, status=status.HTTP_200_OK)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, restaurant_id, menu_id):
        try:
            restaurant = Restaurant.objects.get(id=restaurant_id, owner=request.user)
            menu = Menu.objects.filter(restaurant=restaurant).get(id=menu_id)
        except Restaurant.DoesNotExist:
            return Response({ "errors": "Restaurant not found or you're not the owner" }, status=status.HTTP_404_NOT_FOUND)
        except Menu.DoesNotExist:
            return Response({ "errors": "Menu not found" }, status=status.HTTP_404_NOT_FOUND)
        
        menu.delete()
        return Response({ "message": "Menu successfully deleted" }, status=status.HTTP_200_OK)


