import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';
import 'package:handy_allinone/features/home/domain/repositories/delivery_quotation_repository_interface.dart';

import 'package:handy_allinone/features/home/domain/models/delivery_quotation_model.dart';

class DeliveryQuotationController extends GetxController implements GetxService {
  final DeliveryQuotationRepositoryInterface deliveryQuotationRepositoryInterface;
  DeliveryQuotationController({required this.deliveryQuotationRepositoryInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<XFile> _pickedImages = [];
  List<XFile> get pickedImages => _pickedImages;

  List<DeliveryQuotationModel>? _quotationList;
  List<DeliveryQuotationModel>? get quotationList => _quotationList;

  int? _totalSize;
  int? get totalSize => _totalSize;

  int _offset = 1;
  int get offset => _offset;

  void pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      _pickedImages.add(image);
      update();
    }
  }

  void removeImage(int index) {
    _pickedImages.removeAt(index);
    update();
  }

  Future<bool> uploadQuotationImages() async {
    _isLoading = true;
    update();
    bool success = false;
    Response response = await deliveryQuotationRepositoryInterface.uploadQuotationImages(_pickedImages);
    if (response.statusCode == 200) {
      _pickedImages = [];
      showCustomSnackBar('Quotation submitted successfully!', isError: false);
      success = true;
    } else {
      String errorMessage = response.statusText ?? 'Something went wrong';
      if (response.body != null && response.body['errors'] != null) {
        errorMessage = response.body['errors'][0]['message'];
      }
      showCustomSnackBar(errorMessage);
    }
    _isLoading = false;
    update();
    return success;
  }

  Future<void> getDeliveryQuotationList(int offset, bool reload) async {
    if (offset == 1 || reload) {
      _offset = 1;
      _quotationList = null;
      if (reload) {
        update();
      }
    } else {
      _offset = offset;
    }

    _isLoading = true;
    // update();

    Response response = await deliveryQuotationRepositoryInterface.getDeliveryQuotationList(_offset);
    if (response.statusCode == 200) {
      PaginatedDeliveryQuotationModel paginatedModel = PaginatedDeliveryQuotationModel.fromJson(response.body);
      if (_offset == 1) {
        _quotationList = [];
      }
      _quotationList!.addAll(paginatedModel.data!);
      _totalSize = paginatedModel.totalSize;
    } else {
      // Handle error
    }

    _isLoading = false;
    update();
  }
}
