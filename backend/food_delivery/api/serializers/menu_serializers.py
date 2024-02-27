from rest_framework import serializers
from ..models import Restaurant, Menu

class MenuSerializer(serializers.ModelSerializer):
    restaurant_id = serializers.PrimaryKeyRelatedField(write_only=True, queryset=Restaurant.objects.all(), source="restaurant")
    class Meta:
        model = Menu
        fields = ["id", "name", "description", "price", "category", "image_path", "restaurant_id"]