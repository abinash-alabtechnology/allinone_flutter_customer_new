import 'package:handy_allinone/common/enums/data_source_enum.dart';
import 'package:handy_allinone/features/home/domain/models/advertisement_model.dart';

abstract class AdvertisementServiceInterface {
  Future<List<AdvertisementModel>?> getAdvertisementList(DataSourceEnum source);
}