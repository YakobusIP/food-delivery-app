class Restaurant {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final double rating;
  final int deliveryRadius;
  final String openingTime;
  final String closingTime;
  final String imagePath;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.rating,
    required this.deliveryRadius,
    required this.openingTime,
    required this.closingTime,
    required this.imagePath,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        phoneNumber: json['phone_number'],
        email: json['email'],
        rating: json['rating'].toDouble(), // Ensure this is a double
        deliveryRadius: json['delivery_radius'],
        openingTime: json['opening_time'],
        closingTime: json['closing_time'],
        imagePath: json['image_path']);
  }
}
