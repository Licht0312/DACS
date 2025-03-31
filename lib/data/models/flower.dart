class Flower {
  final String name;
  final String scientificName; //Tên khoa học
  final String description; // mô tả
  final List<String> imageUrls; // Could be multiple image
  final String genus; //loài hoa
  final String bloomingSeason; // mùa nở
  final String color; // màu sắc

  Flower({
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imageUrls,
    required this.genus,
    required this.bloomingSeason,
    required this.color,
  });

  // You may also want a method to create a Flower from JSON:
  factory Flower.fromJson(Map<String, dynamic> json) {
    return Flower(
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      description: json['description'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      genus: json['genus'] as String,
      bloomingSeason: json['bloomingSeason'] as String,
      color: json['color'] as String,
    );
  }
  // and a method to convert to JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'scientificName': scientificName,
    'description': description,
    'imageUrls': imageUrls,
    'genus': genus,
    'bloomingSeason': bloomingSeason,
    'color': color,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Flower && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}