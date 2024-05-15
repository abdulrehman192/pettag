
class DentalExamModel {
  String? examType;
  String? veterinaryNotes;
  String? dueDate;
  String? lastDateGiven;


  DentalExamModel({
    this.examType,
    this.veterinaryNotes,
    this.dueDate,
    this.lastDateGiven,

  });

  DentalExamModel.fromJson(Map<String, dynamic> json){
    examType = json['exam_type'];
    veterinaryNotes = json['veterinary_notes'];
    dueDate = json['due_date'];
    lastDateGiven = json['last_date'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['exam_type'] = examType;
    _data['veterinary_notes'] = veterinaryNotes;
    _data['due_date'] = dueDate;
    _data['last_date'] = lastDateGiven;
    return _data;
  }

}