from typing import Dict
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model, authenticate
from django.core.exceptions import ValidationError
from ..models import CustomUser, CustomerProfile, DeliveryProfile

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
        # Extract profile related ada
        role = validated_data.pop("role")
        profile_data = { k: validated_data.pop(k, None) for k in ["address", "image_path"] if k in validated_data }

        # Create the new user based on the role
        user = CustomUser.objects.create_user(**validated_data, role=role)

        # Create profile based on role
        if role == CustomUser.Role.CUSTOMER and any(profile_data.values()):
            CustomerProfile.objects.create(user=user, **profile_data)
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