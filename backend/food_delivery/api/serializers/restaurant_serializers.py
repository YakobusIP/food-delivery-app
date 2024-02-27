from rest_framework import serializers
from ..models import CustomUser, Restaurant
from .auth_serializers import CustomUserSerializer

class RestaurantSerializer(serializers.ModelSerializer):
    owner = CustomUserSerializer(read_only=True)
    owner_id = serializers.PrimaryKeyRelatedField(write_only=True, queryset=CustomUser.objects.all(), source="owner")
    class Meta:
        model = Restaurant
        fields = ["id", "name", "address", "phone_number", "email", "rating", "delivery_radius", "opening_time", "closing_time", "image_path", "owner_id", "owner"]