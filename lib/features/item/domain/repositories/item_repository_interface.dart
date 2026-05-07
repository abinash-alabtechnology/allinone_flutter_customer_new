import 'package:handy_allinone/common/enums/data_source_enum.dart';
import 'package:handy_allinone/features/item/domain/models/basic_medicine_model.dart';
import 'package:handy_allinone/interfaces/repository_interface.dart';

abstract class ItemRepositoryInterface implements RepositoryInterface {
  @override
  Future getList({int? offset, String? type, bool isPopularItem = false, bool isReviewedItem = false, bool isFeaturedCategoryItems = false, bool isRecommendedItems = false,
    bool isCommonConditions = false, bool isDiscountedItems = false, bool isSubscriptionItems = false, bool isFreshItems = false, DataSourceEnum? source,
    String? search, List<int>? categoryIds, List<String>? filter, int? rating, double? minPrice, double? maxPrice,
  });
  Future<BasicMedicineModel?> getBasicMedicine(DataSourceEnum source);
  @override
  Future get(String? id, {bool isConditionWiseItem = false});
}