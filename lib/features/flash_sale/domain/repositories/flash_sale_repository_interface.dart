import 'package:handy_allinone/common/enums/data_source_enum.dart';
import 'package:handy_allinone/interfaces/repository_interface.dart';

abstract class FlashSaleRepositoryInterface<T> implements RepositoryInterface {
  Future<dynamic> getFlashSale({required DataSourceEnum source});
  Future<dynamic> getFlashSaleWithId(int id, int offset);
}