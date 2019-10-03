class OfferCancellation {
  String cancellationId, offer, user;
  String date;

  OfferCancellation({this.cancellationId, this.offer, this.user, this.date});

  OfferCancellation.fromJson(Map data) {
    this.cancellationId = data['cancellationId'];
    this.offer = data['offer'];
    this.user = data['user'];
    this.date = data['date'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'cancellationId': cancellationId == null ? ' n/a ' : cancellationId,
        'offer': offer,
        'user': user == null ? ' n/a ' : user,
        'date': date == null ? ' n/a ' : date,
      };
}
