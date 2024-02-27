from django.urls import path
from .views import UserCreateAPIView, LoginAPIView, RestaurantAPIView, RestaurantDetailAPIView, MenuAPIView, MenuListAPIView

urlpatterns = [
    # Auth Path
    path("auth/register/", UserCreateAPIView.as_view(), name="auth_register"),
    path("auth/login/", LoginAPIView.as_view(), name="auth_login"),

    # Restaurant Path
    path("restaurants/", RestaurantAPIView.as_view(), name="restaurant_get_create"),
    path("restaurants/<int:id>", RestaurantDetailAPIView.as_view(), name="restaurant_detail_get_put"),

    # Menu Path
    path("restaurants/<int:restaurant_id>/menus", MenuAPIView.as_view(), name="menu_get_add"),
    path("restaurants/<int:restaurant_id>/menus/<int:menu_id>", MenuListAPIView.as_view(), name="menu_detail_get_put_delete")
]