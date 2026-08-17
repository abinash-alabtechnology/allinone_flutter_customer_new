import 'package:get/get.dart';
import 'package:handy_allinone/features/item/domain/models/item_model.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';

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
  final int? storeId;
  final List<String>? serviceType;

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
    this.storeId,
    this.serviceType,
  });

  factory HandymanServiceModel.fromItem(Item item) {
    String? img = item.imageFullUrl ?? (item.image != null && item.image!.isNotEmpty
        ? (item.image!.startsWith('http')
            ? item.image
            : '${Get.find<SplashController>().configModel?.baseUrls?.itemImageUrl}/${item.image}')
        : null);

    double originalPrice = item.price ?? 0;
    double discountedPrice = originalPrice;
    String discountText = '';
    if (item.discount != null && item.discount! > 0) {
      if (item.discountType == 'percent') {
        discountedPrice = originalPrice - (originalPrice * item.discount! / 100);
        discountText = '${item.discount!.toInt()}% OFF';
      } else {
        discountedPrice = originalPrice - item.discount!;
        discountText = '₹${item.discount!.toInt()} OFF';
      }
    }

    List<HandymanServiceOption> optionsList = [];
    if (item.variations != null && item.variations!.isNotEmpty) {
      for (var v in item.variations!) {
        double vOriginal = v.price ?? originalPrice;
        double vDiscounted = vOriginal;
        if (item.discount != null && item.discount! > 0) {
          if (item.discountType == 'percent') {
            vDiscounted = vOriginal - (vOriginal * item.discount! / 100);
          } else {
            vDiscounted = vOriginal - item.discount!;
          }
        }
        optionsList.add(HandymanServiceOption(
          id: '${item.id}_${v.type ?? 'var'}',
          title: v.type ?? item.name ?? '',
          originalPrice: vOriginal.toInt(),
          discountedPrice: vDiscounted.toInt(),
          discountText: discountText,
          subtitle: item.description ?? '',
          imageAsset: img,
          rating: item.avgRating ?? 0.0,
          reviewCount: item.ratingCount?.toString() ?? '0',
        ));
      }
    }

    if (optionsList.isEmpty && item.foodVariations != null && item.foodVariations!.isNotEmpty) {
      for (var fv in item.foodVariations!) {
        if (fv.variationValues != null) {
          for (var vv in fv.variationValues!) {
            double vOriginal = vv.optionPrice ?? originalPrice;
            double vDiscounted = vOriginal;
            if (item.discount != null && item.discount! > 0) {
              if (item.discountType == 'percent') {
                vDiscounted = vOriginal - (vOriginal * item.discount! / 100);
              } else {
                vDiscounted = vOriginal - item.discount!;
              }
            }
            optionsList.add(HandymanServiceOption(
              id: '${item.id}_${vv.level ?? 'opt'}',
              title: '${fv.name ?? ''} - ${vv.level ?? ''}',
              originalPrice: vOriginal.toInt(),
              discountedPrice: vDiscounted.toInt(),
              discountText: discountText,
              subtitle: item.description ?? '',
              imageAsset: img,
              rating: item.avgRating ?? 0.0,
              reviewCount: item.ratingCount?.toString() ?? '0',
            ));
          }
        }
      }
    }

    if (optionsList.isEmpty) {
      optionsList.add(HandymanServiceOption(
        id: '${item.id}_opt1',
        title: item.name ?? '',
        originalPrice: originalPrice.toInt(),
        discountedPrice: discountedPrice.toInt(),
        discountText: discountText,
        subtitle: item.description ?? '',
        imageAsset: img,
        rating: item.avgRating ?? 0.0,
        reviewCount: item.ratingCount?.toString() ?? '0',
      ));
    }

    return HandymanServiceModel(
      id: item.id.toString(),
      name: item.name ?? '',
      category: (item.categoryIds != null && item.categoryIds!.isNotEmpty && item.categoryIds![0].name != null)
          ? item.categoryIds![0].name!
          : '',
      rating: item.avgRating ?? 0.0,
      reviewCount: item.ratingCount != null ? item.ratingCount.toString() : '0',
      startingPrice: discountedPrice.toInt(),
      optionsCount: optionsList.length > 1 ? optionsList.length : (item.choiceOptions?.length ?? 0),
      imageAsset: '',
      imageUrl: img,
      coverDescription: item.description,
      options: optionsList.length > 1 ? optionsList : [],
      storeId: item.storeId,
      serviceType: item.serviceType,
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
      imageUrl: imageUrl,
      coverImageAsset: coverImageAsset,
      coverTitle: coverTitle,
      coverDescription: coverDescription,
      isCoverTextDark: isCoverTextDark,
      options: options,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      cartQuantity: cartQuantity ?? this.cartQuantity,
      storeId: storeId,
      serviceType: serviceType,
    );
  }
}
