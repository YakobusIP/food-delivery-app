class Menu {
  final int id;
  final String name;
  final String description;
  final int price;
  final String category;
  final String imagePath;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      category: json['category'],
      imagePath: json['image_path'],
    );
  }
}
