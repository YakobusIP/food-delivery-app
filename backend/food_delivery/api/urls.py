from django.urls import path
from .views.auth_views import RegisterAPIView, LoginAPIView
from .views.restaurant_views import RestaurantAPIView, RestaurantDetailAPIView 
from .views.menu_views import MenuAPIView, MenuListAPIView
from .views.order_views import OrderCustomerAPIView, OrderCustomerDetailAPIView

urlpatterns = [
    # Auth Path
    path("auth/register", RegisterAPIView.as_view(), name="auth_register"),
    path("auth/login", LoginAPIView.as_view(), name="auth_login"),

    # Restaurant Path
    path("restaurants", RestaurantAPIView.as_view(), name="restaurant_get_create"),
    path("restaurants/<int:id>", RestaurantDetailAPIView.as_view(), name="restaurant_detail_get_put"),

    # Menu Path
    path("restaurants/<int:restaurant_id>/menus", MenuAPIView.as_view(), name="menu_get_add"),
    path("restaurants/<int:restaurant_id>/menus/<int:menu_id>", MenuListAPIView.as_view(), name="menu_detail_get_put_delete"),

    # Customer Order Path
    path("orders/customers", OrderCustomerAPIView.as_view(), name="order_customer_get_add"),
    path("orders/customers/<int:id>", OrderCustomerDetailAPIView.as_view(), name="order_customer_get_add")
    # path("orders/restaurants")
    # path("orders/deliveries")
]