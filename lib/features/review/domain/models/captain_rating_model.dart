class CaptainRatingModel {
  double? averageRating;
  int? totalReviews;

  CaptainRatingModel({this.averageRating, this.totalReviews});

  CaptainRatingModel.fromJson(Map<String, dynamic> json) {
    averageRating = json['average_rating']?.toDouble();
    totalReviews = json['total_reviews'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['average_rating'] = averageRating;
    data['total_reviews'] = totalReviews;
    return data;
  }
}
