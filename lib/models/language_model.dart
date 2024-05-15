class LanguageModel {
  bool? isSelected;
   String? pic;
   String? name;

  LanguageModel({this.pic, this.name,  this.isSelected});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageModel && runtimeType == other.runtimeType && isSelected == other.isSelected && pic == other.pic && name == other.name;

  @override
  int get hashCode => isSelected.hashCode ^ pic.hashCode ^ name.hashCode;
}
