from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import UserSerializer, LoginSerializer

# Create your views here.
class UserCreateAPIView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({ "message": "Register successful" }, status=status.HTTP_201_CREATED)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)
    
class LoginApiView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            print(serializer.validated_data)
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        return Response({ "errors": serializer.errors }, status=status.HTTP_400_BAD_REQUEST)