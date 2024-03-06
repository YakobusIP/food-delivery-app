class Order {
  final int id;
  final int customer;
  final int? deliveryPerson;
  final OrderRestaurant restaurant;
  final String status;
  final int totalPrice;
  final String? deliveryTime;
  final List<OrderItems> orderItems;

  Order({
    required this.id,
    required this.customer,
    this.deliveryPerson,
    required this.restaurant,
    required this.status,
    required this.totalPrice,
    this.deliveryTime,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItems> orderItems = [];
    json['order_items'].forEach((v) {
      orderItems.add(OrderItems.fromJson(v));
    });

    return Order(
      id: json["id"],
      customer: json["customer"],
      deliveryPerson: json["delivery_person"],
      restaurant: OrderRestaurant.fromJson(json['restaurant']),
      status: json["status"],
      totalPrice: json["total_price"],
      deliveryTime: json["delivery_time"],
      orderItems: orderItems,
    );
  }
}

class OrderRestaurant {
  final int id;
  final String name;
  final String? imagePath;
  final double rating;

  OrderRestaurant({
    required this.id,
    required this.name,
    this.imagePath,
    required this.rating,
  });

  factory OrderRestaurant.fromJson(Map<String, dynamic> json) {
    return OrderRestaurant(
      id: json['id'],
      name: json['name'],
      imagePath: json['image_path'],
      rating: json['rating'],
    );
  }
}

class OrderItems {
  final int id;
  final OrderMenuItem menuItem;
  final int quantity;

  OrderItems({
    required this.id,
    required this.menuItem,
    required this.quantity,
  });

  factory OrderItems.fromJson(Map<String, dynamic> json) {
    return OrderItems(
      id: json['id'],
      menuItem: OrderMenuItem.fromJson(json['menu_item']),
      quantity: json['quantity'],
    );
  }
}

class OrderMenuItem {
  final int id;
  final String name;
  final int price;
  final String? imagePath;

  OrderMenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.imagePath,
  });

  factory OrderMenuItem.fromJson(Map<String, dynamic> json) {
    return OrderMenuItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      imagePath: json['image_path'],
    );
  }
}
