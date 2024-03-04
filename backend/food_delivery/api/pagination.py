from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response

class CustomPagination(PageNumberPagination):
    page_size = 10
    page_query_param = "currentPage"

    def get_paginated_response(self, data):
        return Response({
            "data": data,
            "total_pages": self.page.paginator.num_pages,
            "current_page": int(self.request.GET.get(self.page_query_param, 1)),
            "page_size": self.page_size,
            "total_items": self.page.paginator.count
        })