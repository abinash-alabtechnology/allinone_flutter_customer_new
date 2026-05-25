class HandymanServiceModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String reviewCount; // e.g. "2.6M", "890K"
  final int startingPrice;
  final int optionsCount;
  final String imageAsset;
  bool isWishlisted;
  int cartQuantity;

  HandymanServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.startingPrice,
    required this.optionsCount,
    required this.imageAsset,
    this.isWishlisted = false,
    this.cartQuantity = 0,
  });

  HandymanServiceModel copyWith({
    bool? isWishlisted,
    int? cartQuantity,
  }) {
    return HandymanServiceModel(
      id: id,
      name: name,
      category: category,
      rating: rating,
      reviewCount: reviewCount,
      startingPrice: startingPrice,
      optionsCount: optionsCount,
      imageAsset: imageAsset,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      cartQuantity: cartQuantity ?? this.cartQuantity,
    );
  }
}
