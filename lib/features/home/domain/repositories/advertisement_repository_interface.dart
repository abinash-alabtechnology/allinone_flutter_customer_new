import 'package:handy_allinone/common/enums/data_source_enum.dart';
import 'package:handy_allinone/features/home/domain/models/advertisement_model.dart';
import 'package:handy_allinone/interfaces/repository_interface.dart';

abstract class AdvertisementRepositoryInterface extends RepositoryInterface{
  @override
  Future<List<AdvertisementModel>?> getList({int? offset, DataSourceEnum source = DataSourceEnum.client});
}