


class VacinationModel {
  String? vacineType;
  String? dueDate;
  String? lastDateGiven;


  VacinationModel({
    this.vacineType,
    this.dueDate,
    this.lastDateGiven,

  });

  VacinationModel.fromJson(Map<String, dynamic> json){
    vacineType = json['vacine_type'];
    dueDate = json['due_date'];
    lastDateGiven = json['last_date'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['vacine_type'] = vacineType;
    _data['due_date'] = dueDate;
    _data['last_date'] = lastDateGiven;
    return _data;
  }

}