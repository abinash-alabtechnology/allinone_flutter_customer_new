import 'package:get/get_connect/connect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_allinone/interfaces/repository_interface.dart';

abstract class DeliveryQuotationRepositoryInterface implements RepositoryInterface {
  Future<Response> uploadQuotationImages(List<XFile> images);
  Future<Response> getDeliveryQuotationList(int offset);
}
