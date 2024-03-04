from rest_framework import serializers
from ..models import CustomUser, Restaurant
from .auth_serializers import CustomUserSerializer

class RestaurantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Restaurant
        fields = ["id", "name", "address", "phone_number", "email", "rating", "delivery_radius", "opening_time", "closing_time", "image_path"]