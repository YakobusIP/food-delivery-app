from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from ..models import Restaurant
from ..serializers.restaurant_serializers import RestaurantSerializer
from ..permissions import IsAuthenticated, IsAuthenticatedRestaurantRole
from ..pagination import CustomPagination
from django.shortcuts import get_object_or_404
from datetime import datetime

class RestaurantAPIView(APIView):
    def get_permissions(self):
        permission_classes = [IsAuthenticatedRestaurantRole] if self.request.method == "POST" else [IsAuthenticated]
        return [permission() for permission in permission_classes]
    
    def filter_queryset(self, queryset):
        name = self.request.query_params.get("name")
        current_time_str = self.request.query_params.get("time")
        sort = self.request.query_params.get("sort", "name")

        if name:
            queryset = queryset.filter(name__icontains=name)
        if current_time_str:
            current_time = datetime.strptime(current_time_str, "%H:%M").time()
            queryset = queryset.filter(opening_time__lte=current_time, closing_time__gte=current_time)

        return queryset.order_by(sort)

    def get(self, request):
        queryset = self.filter_queryset(Restaurant.objects.all())

        paginator = CustomPagination()
        page = paginator.paginate_queryset(queryset, request)

        if page is not None:
            serializer = RestaurantSerializer(page, many=True)
            return paginator.get_paginated_response(serializer.data)
        
        serializer = RestaurantSerializer(queryset, many=True)
        return Response({"data": serializer.data})
    
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
        permission_classes = [IsAuthenticatedRestaurantRole] if self.request.method == "PUT" else [IsAuthenticated]
        return [permission() for permission in permission_classes]
        
    def get(self, request, id):
        restaurant = get_object_or_404(Restaurant, id=id)
        serializer = RestaurantSerializer(restaurant)
        return Response({ "data": serializer.data })
    
    def put(self, request, id):
        restaurant = get_object_or_404(Restaurant, id=id, owner=request.user)
        serializer = RestaurantSerializer(instance=restaurant, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({ "message": "Restaurant successfully updated" }, status=status.HTTP_200_OK)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)