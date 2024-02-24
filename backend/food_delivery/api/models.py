from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator

# Create your models here.
class UserProfile(models.Model):
    class Role(models.TextChoices):
        CUSTOMER = "CUSTOMER", "Customer"
        RESTAURANT = "RESTAURANT", "Restaurant"
        DELIVERY = "DELIVERY", "Delivery"

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=10, choices=Role.choices, default=Role.CUSTOMER)
    address = models.TextField(null=True)
    phone_number = models.CharField(max_length=20)

class DeliveryProfile(models.Model):
    class Availability(models.TextChoices):
        AVAILABLE = "AVAILABLE", "Available"
        BUSY = "BUSY", "Busy"
        OFF = "OFF", "Off"

    profile = models.OneToOneField(UserProfile, on_delete=models.CASCADE)
    availability = models.TextField(choices=Availability.choices, default=Availability.AVAILABLE)

class Restaurant(models.Model):
    name = models.CharField(max_length=100)
    address = models.TextField()
    phone_number = models.CharField(max_length=20)
    email = models.EmailField()
    rating = models.FloatField(
        default=5.0, 
        validators=[MinValueValidator(0.0), MaxValueValidator(5.0)])
    delivery_radius = models.IntegerField(validators=[MinValueValidator(1)])
    opening_time = models.TimeField()
    closing_time = models.TimeField()

class Menu(models.Model):
    class FoodCategory(models.TextChoices):
        ITALIAN = "ITALIAN", "Italian Food"
        CHINESE = "CHINESE", "Chinese Food"
        JAPANESE = "JAPANESE", "Japanese Food"
        KOREAN = "KOREAN", "Korean Food"
        MEXICAN = "MEXICAN", "Mexican Food"
        VEGETARIAN = "VEGETARIAN", "Vegetarian Food"
        FASTFOOD = "FASTFOOD", "Fast Food"
        INDIAN = "INDIAN", "Indian Food"
        AMERICAN = "AMERICAN", "American Food"
        INDONESIAN = "INDONESIAN", "Indonesian Food"
    
    restaurant = models.ForeignKey(Restaurant, related_name="restaurant_menu", on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    description = models.TextField(null=True)
    price = models.IntegerField()
    category = models.TextField(choices=FoodCategory.choices, null=True)
    image_path = models.ImageField()

class Order(models.Model):
    class OrderStatus(models.TextChoices):
        PLACED = "PLACED", "Order Placed" 
        IN_KITCHEN = "IN_KITCHEN", "In Kitchen" 
        OUT_FOR_DELIVERY = "OUT_FOR_DELIVERY", "Out for Delivery" 
        DELIVERED = "DELIVERED", "Delivered" 

    customer = models.ForeignKey(User, related_name="orders_placed", on_delete=models.CASCADE)
    delivery_person = models.ForeignKey(User, null=True, related_name="deliveries", on_delete=models.CASCADE)
    restaurant = models.ForeignKey(Restaurant, related_name="placed_orders", on_delete=models.CASCADE)
    status = models.TextField(choices=OrderStatus.choices, default=OrderStatus.PLACED)
    total_price = models.IntegerField()
    order_time = models.DateTimeField(auto_now_add=True)
    delivery_time = models.DateTimeField(null=True)

class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    menu_item = models.ForeignKey(Menu, on_delete=models.CASCADE)
    quantity = models.IntegerField()
