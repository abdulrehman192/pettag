
class WeightTrackerModel {
  String? weight;
  String? date;
  String? format;


  WeightTrackerModel({
    this.weight,
    this.date,
    this.format,

  });

  factory WeightTrackerModel.fromJson(Map<String, dynamic> json){
    return WeightTrackerModel(
        weight : json['weight'],
        date : json['date'],
        format : json['format'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['weight'] = weight;
    _data['date'] = date;
    _data['format'] = format;
    return _data;
  }

}