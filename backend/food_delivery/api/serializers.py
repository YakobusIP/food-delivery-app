from typing import Any, Dict
from rest_framework import serializers
from rest_framework_simplejwt.tokens import Token, RefreshToken
from django.contrib.auth import get_user_model, authenticate
from django.core.exceptions import ValidationError
from .models import CustomUser, CustomerProfile, DeliveryProfile, Restaurant, Menu, Order, OrderItem

User = get_user_model()

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)

    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

class UserSerializer(serializers.ModelSerializer):
    role = serializers.ChoiceField(choices=CustomUser.Role.choices, write_only=True)
    address = serializers.CharField(write_only=True, required=False)
    image_path = serializers.ImageField(write_only=True, required=False)

    class Meta:
        model = CustomUser
        fields = ["username", "email", "password", "role", "phone_number", "address", "image_path"]
        extra_kwargs = { "password": { "write_only": True } }

    def create(self, validated_data):
        role = validated_data.pop("role")
        address = validated_data.pop("address", None)
        image_path = validated_data.pop("image_path", None)

        user = CustomUser.objects.create_user(**validated_data, role=role)

        if role == CustomUser.Role.CUSTOMER:
            customer_profile_data = {}

            if address:
                customer_profile_data["address"] = address
            if image_path:
                customer_profile_data["image_path"] = image_path

            CustomerProfile.objects.create(user=user, **customer_profile_data)

        if role == CustomUser.Role.DELIVERY:
            DeliveryProfile.objects.create(user=user)

        return user
    
class CustomUserSerializer(serializers.ModelSerializer):    
    class Meta:
        model = CustomUser
        fields = ["username", "role"]
    
class LoginSerializer(serializers.Serializer):
    identifier = serializers.CharField(max_length=255, write_only=True)
    password = serializers.CharField(max_length=255, write_only=True)

    user = serializers.SerializerMethodField(read_only=True)
    tokens = serializers.SerializerMethodField(read_only=True)

    def validate(self, attrs: Dict[str, str]):
        identifier = attrs.get("identifier")
        password = attrs.get("password")

        user = User.objects.filter(email=identifier).first() or \
            User.objects.filter(username=identifier).first() or \
            User.objects.filter(phone_number=identifier).first()

        if not user or not authenticate(username=user.username, password=password):
            raise ValidationError("Invalid credentials")
        
        user_data = CustomUserSerializer(user).data

        tokens = get_tokens_for_user(user)
        
        return {
            "user": user_data,
            "tokens": tokens
        }      

class RestaurantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Restaurant
        fields = ["id", "name", "address", "phone_number", "email", "rating", "delivery_radius", "opening_time", "closing_time", "image_path"]

class MenuSerializer(serializers.ModelSerializer):
    class Meta:
        model = Menu
        fields = ["id", "name", "description", "price", "category", "image_path", "restaurant"]
        
class OrderSerializer(serializers.ModelSerializer):
    customer = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.filter(role=CustomUser.Role.CUSTOMER))
    delivery_person = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.filter(role=CustomUser.Role.DELIVERY), allow_null=True)
    restaurant = RestaurantSerializer(read_only=True)
    restaurant_id = serializers.PrimaryKeyRelatedField(write_only=True, queryset=Restaurant.objects.all(), source="restaurant")

    class Meta:
        model = Order
        fields = ["id", "customer", "delivery_person", "restaurant", "restaurant_id", "status", "total_price", "order_time", "delivery_time"]