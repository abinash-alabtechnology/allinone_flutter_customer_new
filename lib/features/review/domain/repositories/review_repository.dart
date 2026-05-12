import 'package:get/get.dart';
import 'package:handy_allinone/common/models/response_model.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/features/review/domain/models/review_body_model.dart';
import 'package:handy_allinone/features/review/domain/models/review_model.dart';
import 'package:handy_allinone/features/review/domain/repositories/review_repository_interface.dart';
import 'package:handy_allinone/util/app_constants.dart';

class ReviewRepository implements ReviewRepositoryInterface {
  final ApiClient apiClient;
  ReviewRepository({required this.apiClient});

  @override
  Future<List<ReviewModel>?> getList({int? offset, String? storeID}) async {
    List<ReviewModel>? storeReviewList;
    Response response = await apiClient.getData('${AppConstants.storeReviewUri}?store_id=$storeID');
    if (response.statusCode == 200) {
      storeReviewList = [];
      response.body.forEach((review) => storeReviewList!.add(ReviewModel.fromJson(review)));
    }
    return storeReviewList;
  }

  @override
  Future<List<ReviewModel>?> getItemReviewList(int? itemID) async {
    List<ReviewModel>? itemReviewList;
    Response response = await apiClient.getData('${AppConstants.itemReviewUri}$itemID');
    if (response.statusCode == 200) {
      itemReviewList = [];
      if (response.body is List) {
        response.body.forEach((review) => itemReviewList!.add(ReviewModel.fromJson(review)));
      } else if (response.body['reviews'] != null) {
        response.body['reviews'].forEach((review) => itemReviewList!.add(ReviewModel.fromJson(review)));
      }
    }
    return itemReviewList;
  }

  @override
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.reviewUri, reviewBody.toJson(), handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'review_submitted_successfully'.tr);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(AppConstants.deliveryManReviewUri, reviewBody.toJson(), handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, 'review_submitted_successfully'.tr);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
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
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
  @override
  Future<Response> getCaptainRating(int captainId) async {
    return await apiClient.getData('${AppConstants.captainReviewRatingUri}$captainId');
  }

}