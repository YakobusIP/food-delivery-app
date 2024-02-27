from rest_framework import serializers
from ..models import CustomUser, Restaurant, Order, OrderItem, Menu
from .menu_serializers import MenuSerializer
from .restaurant_serializers import RestaurantSerializer

class OrderRestaurantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Restaurant
        fields = ["id", "name", "image_path", "rating"]

class OrderMenuSerializer(serializers.ModelSerializer):
    class Meta:
        model = Menu
        fields = ["id", "name", "price", "image_path"]

class OrderItemSerializer(serializers.ModelSerializer):
    menu_item = OrderMenuSerializer(read_only=True)
    class Meta:
        model = OrderItem
        fields = ["id", "menu_item", "quantity"]

class OrderSerializer(serializers.ModelSerializer):
    customer = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.filter(role=CustomUser.Role.CUSTOMER))
    delivery_person = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.filter(role=CustomUser.Role.DELIVERY), allow_null=True)
    restaurant = OrderRestaurantSerializer(read_only=True)
    restaurant_id = serializers.PrimaryKeyRelatedField(write_only=True, queryset=Restaurant.objects.all(), source="restaurant")
    order_items = OrderItemSerializer(read_only=True, many=True, source="orderitem_set")

    class Meta:
        model = Order
        fields = ["id", "customer", "delivery_person", "restaurant", "restaurant_id", "status", "total_price", "delivery_time", "order_items"]

