


class ParasiteControlModel {
  String? medicineType;
  String? dueDate;
  String? lastDateGiven;


  ParasiteControlModel({
    this.medicineType,
    this.dueDate,
    this.lastDateGiven,

  });

  ParasiteControlModel.fromJson(Map<String, dynamic> json){
    medicineType = json['medicine_type'];
    dueDate = json['due_date'];
    lastDateGiven = json['last_date'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['medicine_type'] = medicineType;
    _data['due_date'] = dueDate;
    _data['last_date'] = lastDateGiven;
    return _data;
  }

}