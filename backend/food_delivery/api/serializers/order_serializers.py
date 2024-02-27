from rest_framework import serializers
from ..models import CustomUser, Restaurant, Order
from .restaurant_serializers import RestaurantSerializer

class OrderSerializer(serializers.ModelSerializer):
    customer = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.filter(role=CustomUser.Role.CUSTOMER))
    delivery_person = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.filter(role=CustomUser.Role.DELIVERY), allow_null=True)
    restaurant = RestaurantSerializer(read_only=True)
    restaurant_id = serializers.PrimaryKeyRelatedField(write_only=True, queryset=Restaurant.objects.all(), source="restaurant")

    class Meta:
        model = Order
        fields = ["id", "customer", "delivery_person", "restaurant", "restaurant_id", "status", "total_price", "order_time", "delivery_time"]