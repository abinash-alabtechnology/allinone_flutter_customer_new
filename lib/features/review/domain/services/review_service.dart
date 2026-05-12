import 'package:get/get.dart';
import 'package:handy_allinone/common/models/response_model.dart';
import 'package:handy_allinone/features/review/domain/models/captain_rating_model.dart';
import 'package:handy_allinone/features/review/domain/models/review_body_model.dart';
import 'package:handy_allinone/features/review/domain/models/review_model.dart';
import 'package:handy_allinone/features/review/domain/repositories/review_repository_interface.dart';
import 'package:handy_allinone/features/review/domain/services/review_service_interface.dart';

class ReviewService implements ReviewServiceInterface {
  final ReviewRepositoryInterface reviewRepositoryInterface;
  ReviewService({required this.reviewRepositoryInterface});

  @override
  Future<List<ReviewModel>?> getStoreReviewList(String? storeID) async {
    return await reviewRepositoryInterface.getList(storeID: storeID);
  }

  @override
  Future<List<ReviewModel>?> getItemReviewList(int? itemID) async {
    return await reviewRepositoryInterface.getItemReviewList(itemID);
  }


  @override
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody) async {
    return await reviewRepositoryInterface.submitReview(reviewBody);
  }

  @override
  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody) async {
    return await reviewRepositoryInterface.submitDeliveryManReview(reviewBody);
  }

  @override
  Future<CaptainRatingModel?> getCaptainRating(int captainId) async {
    Response response = await reviewRepositoryInterface.getCaptainRating(captainId);
    if (response.statusCode == 200) {
      return CaptainRatingModel.fromJson(response.body);
    }
    return null;
  }

}