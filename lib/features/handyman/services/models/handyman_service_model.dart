import 'package:handy_allinone/features/item/domain/models/item_model.dart';

class HandymanServiceOption {
  final String id;
  final String title;
  final int originalPrice;
  final int discountedPrice;
  final String discountText;
  final String subtitle;
  final String? imageAsset;
  final double? rating;
  final String? reviewCount;
  int quantity;

  HandymanServiceOption({
    required this.id,
    required this.title,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountText,
    required this.subtitle,
    this.imageAsset,
    this.rating,
    this.reviewCount,
    this.quantity = 0,
  });
}

class HandymanServiceModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String reviewCount; // e.g. "2.6M", "890K"
  final int startingPrice;
  final int optionsCount;
  final String imageAsset;
  final String? imageUrl;
  final String? coverImageAsset;
  final String? coverTitle;
  final String? coverDescription;
  final bool isCoverTextDark;
  final List<HandymanServiceOption> options;
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
    this.imageUrl,
    this.coverImageAsset,
    this.coverTitle,
    this.coverDescription,
    this.isCoverTextDark = true,
    this.options = const [],
    this.isWishlisted = false,
    this.cartQuantity = 0,
  });

  factory HandymanServiceModel.fromItem(Item item) {
    return HandymanServiceModel(
      id: item.id.toString(),
      name: item.name ?? '',
      category: item.categoryIds != null && item.categoryIds!.isNotEmpty
          ? item.categoryIds![0].name ?? ''
          : '',
      rating: item.avgRating ?? 4.8,
      reviewCount: item.ratingCount != null ? item.ratingCount.toString() : '100+',
      startingPrice: item.price?.toInt() ?? 0,
      optionsCount: item.choiceOptions?.length ?? 1,
      imageAsset: '',
      imageUrl: item.imageFullUrl,
      options: [
        HandymanServiceOption(
          id: '${item.id}_opt1',
          title: item.name ?? '',
          originalPrice: item.price?.toInt() ?? 0,
          discountedPrice: (item.price != null && item.discount != null && item.discount! > 0)
              ? (item.price! - item.discount!).toInt()
              : item.price?.toInt() ?? 0,
          discountText: item.discount != null && item.discount! > 0
              ? '${item.discount!.toInt()}% OFF'
              : '',
          subtitle: item.description ?? '',
          rating: item.avgRating ?? 4.8,
          reviewCount: item.ratingCount?.toString() ?? '100+',
        ),
      ],
    );
  }

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
      coverImageAsset: coverImageAsset,
      coverTitle: coverTitle,
      coverDescription: coverDescription,
      isCoverTextDark: isCoverTextDark,
      options: options,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      cartQuantity: cartQuantity ?? this.cartQuantity,
    );
  }
}
