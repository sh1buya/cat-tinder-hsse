class Cat {
  final String imageUrl;
  final String breedName;
  final String temperament;
  final String origin;
  final String description;

  Cat({
    required this.imageUrl,
    required this.breedName,
    required this.temperament,
    required this.origin,
    required this.description,
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      imageUrl: json['url'] ?? '',
      breedName: json['breeds'][0]['name'] ?? 'Unknown',
      temperament: json['breeds'][0]['temperament'] ?? '',
      origin: json['breeds'][0]['origin'] ?? '',
      description: json['breeds'][0]['description'] ?? '',
    );
  }
}
