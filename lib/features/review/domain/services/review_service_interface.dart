import 'package:handy_allinone/common/models/response_model.dart';
import 'package:handy_allinone/features/review/domain/models/captain_rating_model.dart';
import 'package:handy_allinone/features/review/domain/models/review_body_model.dart';
import 'package:handy_allinone/features/review/domain/models/review_model.dart';

abstract class ReviewServiceInterface {
  Future<List<ReviewModel>?> getStoreReviewList(String? storeID);
  Future<List<ReviewModel>?> getItemReviewList(int? itemID);
  Future<ResponseModel> submitReview(ReviewBodyModel reviewBody);
  Future<ResponseModel> submitDeliveryManReview(ReviewBodyModel reviewBody);
  Future<CaptainRatingModel?> getCaptainRating(int captainId);
}