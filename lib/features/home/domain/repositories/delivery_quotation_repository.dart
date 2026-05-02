import 'package:get/get_connect/connect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/features/home/domain/repositories/delivery_quotation_repository_interface.dart';
import 'package:handy_allinone/util/app_constants.dart';

class DeliveryQuotationRepository implements DeliveryQuotationRepositoryInterface {
  final ApiClient apiClient;
  DeliveryQuotationRepository({required this.apiClient});

  @override
  Future<Response> uploadQuotationImages(List<XFile> images) async {
    List<MultipartBody> multipartImages = [];
    for(XFile image in images) {
      multipartImages.add(MultipartBody('images[]', image));
    }
    return await apiClient.postMultipartData(AppConstants.deliveryQuotationUri, {}, multipartImages);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Response> getDeliveryQuotationList(int offset) async {
    return await apiClient.getData('${AppConstants.deliveryQuotationListUri}?offset=$offset&limit=10');
  }
}
