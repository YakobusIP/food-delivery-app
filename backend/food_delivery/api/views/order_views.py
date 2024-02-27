from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from ..models import Restaurant, Menu, Order, OrderItem
from ..serializers.order_serializers import OrderSerializer
from ..permissions import IsAuthenticated, IsAuthenticatedCustomerRole, IsAuthenticatedRestaurantRole, IsAuthenticatedDeliveriesRole
from django.shortcuts import get_object_or_404

class OrderCustomerAPIView(APIView):
    def get_permissions(self):
        permission_classes = [IsAuthenticatedCustomerRole]
        return [permission() for permission in permission_classes]
    
    def get(self, request):
        order_status = request.query_params.get("status", "PENDING")
        orders = Order.objects.filter(customer=request.user, status=order_status)
        serializer = OrderSerializer(orders, many=True)
        return Response({ "data": serializer.data }, status=status.HTTP_200_OK)
    
    def post(self, request):
        restaurant_id = request.data.get("restaurant_id")
        menu_id = request.data.get("menu_id")
        quantity = request.data.get("quantity")

        try:
            restaurant = Restaurant.objects.get(id=restaurant_id)

            order, _ = Order.objects.get_or_create(
                customer=request.user, 
                restaurant=restaurant, 
                status=Order.OrderStatus.PENDING, 
                defaults={"total_price": 0})
            
            total_price = order.total_price

            menu_item = Menu.objects.get(id=menu_id)
            price = menu_item.price * quantity
            total_price += price

            OrderItem.objects.create(
                order=order,
                menu_item=menu_item,
                quantity=quantity
            )

            order.total_price = total_price
            order.save()

            return Response({ "message": "Order successfully added" }, status=status.HTTP_201_CREATED)
        except Restaurant.DoesNotExist:
            return Response({ "errors": "Restaurant not found" }, status=status.HTTP_404_NOT_FOUND)
        except Menu.DoesNotExist:
            return Response({ "errors": "Menu not found" }, status=status.HTTP_404_NOT_FOUND)

class OrderCustomerDetailAPIView(APIView):
    def get_permissions(self):
        permission_classes = [IsAuthenticatedCustomerRole]
        return [permission() for permission in permission_classes]
    
    def put(self, request, id):
        new_quantity = request.data.get("quantity")
        order_item = get_object_or_404(OrderItem, id=id)
        original_quantity = order_item.quantity

        if new_quantity != original_quantity:
            difference = new_quantity - original_quantity

            price_adjustment = difference * order_item.menu_item.price
            order_item.order.total_price += price_adjustment
            order_item.order.save()

            order_item.quantity = new_quantity
            order_item.save()

            return Response({ "message": "Order item successfully updated" }, status=status.HTTP_200_OK)

    def delete(self, request, id):
        order_item = get_object_or_404(OrderItem, id=id)
        order_item.order.total_price -= order_item.quantity * order_item.menu_item.price
        order_item.order.save()
        order_item.delete()
        return Response({ "message": "Item successfully deleted" }, status=status.HTTP_200_OK) 
        
            