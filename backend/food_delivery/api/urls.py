from django.urls import path
from .views import UserCreateAPIView, LoginApiView

urlpatterns = [
    # Auth Path
    path("auth/register/", UserCreateAPIView.as_view(), name="auth_register"),
    path("auth/login/", LoginApiView.as_view(), name="auth_login")

    # Restaurant Path
    # path("restaurants/")
    # path("restaurants/<int:id>")

    # Menu Path
    # path("restaurants/<int:restaurant_id>/menus")
    # path("restaurants/<int:restaurant_id>/menus/<int:menu_id>")
]