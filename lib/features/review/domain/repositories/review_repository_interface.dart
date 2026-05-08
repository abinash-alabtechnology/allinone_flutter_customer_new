import 'package:handy_allinone/features/review/domain/models/review_body_model.dart';
import 'package:handy_allinone/features/review/domain/models/review_model.dart';
import 'package:handy_allinone/interfaces/repository_interface.dart';

abstract class ReviewRepositoryInterface extends RepositoryInterface {
  @override
  Future<List<ReviewModel>?> getList({int? offset, String? storeID});
  Future<List<ReviewModel>?> getItemReviewList(int? itemID);
  Future<dynamic> submitReview(ReviewBodyModel reviewBody);
  Future<dynamic> submitDeliveryManReview(ReviewBodyModel reviewBody);
}