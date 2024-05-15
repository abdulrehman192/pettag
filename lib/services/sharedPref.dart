import 'package:shared_preferences/shared_preferences.dart';

class  SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  bool get isSeen => _sharedPrefs!.getBool("seen") ?? false;
  String get petType => _sharedPrefs!.getString("PetType").toString();
  String get currentUserPetType => _sharedPrefs!.getString('CurrentUserPetType').toString();
  int get leftBoostCounter => _sharedPrefs!.getInt("leftBoost") ?? 0;
  int get treatCounter => _sharedPrefs!.getInt("likeCountLeft") ?? 25;
  int get superTreatCounter => _sharedPrefs!.getInt('superLikesCountLeft') ?? 1;
  int get superLikesCount => _sharedPrefs!.getInt('superLikesCount')??0;
  int get likeCount=> _sharedPrefs!.getInt('likeCount')??0;
  bool get emailNewMatchNotification => _sharedPrefs!.getBool("emailNewMatchNotification") ?? false;
  bool get emailNewMessageNotification => _sharedPrefs!.getBool("emailNewMessageNotification") ?? false;
  bool get pushNotificationNewMatches => _sharedPrefs!.getBool("pushNotificationNewMatches") ?? false;
  bool get pushNotificationNewMessages => _sharedPrefs!.getBool("pushNotificationNewMessages") ?? false;
  bool get pushNotificationNewTreat => _sharedPrefs!.getBool("pushNotificationNewTreat") ?? false;
  bool get pushNotificationNewSuperTreat => _sharedPrefs!.getBool("pushNotificationNewSuperTreat") ?? false;
  bool get pushNotificationNewTopPick => _sharedPrefs!.getBool("pushNotificationNewTopPick") ?? false;
  bool get pushNotificationNewPetWall => _sharedPrefs!.getBool("pushNotificationNewPetWall") ?? false;
  String get distanceUnit => _sharedPrefs!.getString("distUnit").toString();
  bool get isDistanceAvailable => _sharedPrefs!.containsKey('distUnit');
  int get getRadius => _sharedPrefs!.getInt('radius')??0;


  setRadius(int radius) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('radius', radius);
  }

  /*Future<int> getRadius() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    int radiusValue = prefs.getInt('radius');
    print(radiusValue);
    return radiusValue;
  }*/


  set distanceUnit(String value) {
    _sharedPrefs!.setString("distUnit", value);
  }

  set pushNotificationNewMatches(bool value) {
    _sharedPrefs!.setBool("pushNotificationNewMatches", value);
  }
  set pushNotificationNewMessages(bool value) {
    _sharedPrefs!.setBool("pushNotificationNewMessages", value);
  }
  set pushNotificationNewTreat(bool value) {
    _sharedPrefs!.setBool("pushNotificationNewTreat", value);
  }
  set pushNotificationNewSuperTreat(bool value) {
    _sharedPrefs!.setBool("pushNotificationNewSuperTreat", value);
  }
  set pushNotificationNewTopPick(bool value) {
    _sharedPrefs!.setBool("pushNotificationNewTopPick", value);
  }
  set pushNotificationNewPetWall(bool value) {
    _sharedPrefs!.setBool("pushNotificationNewPetWall", value);
  }

  set emailNewMatchNotification(bool value) {
    _sharedPrefs!.setBool("emailNewMatchNotification", value);
  }

  set emailNewMessageNotification(bool value) {
    _sharedPrefs!.setBool("emailNewMessageNotification", value);
  }

  set superLikesCount(int superLikes){
    _sharedPrefs!.setInt('superLikesCount', superLikes);
  }

  set likeCount(int likes){
    _sharedPrefs!.setInt('likeCount', likes);
  }

  set leftBoostCounter(int boost){
    _sharedPrefs!.setInt("leftBoost", boost);
  }

  set treatCounter(int treats){
    _sharedPrefs!.setInt("likeCountLeft", treats);
  }

  set superTreatCounter(int superTreats){
    _sharedPrefs!.setInt("superLikesCountLeft", superTreats);
  }

  set currentUserPetType(String value){
    _sharedPrefs!.setString("CurrentUserPetType", value);
  }

  set petType(String value) {
    _sharedPrefs!.setString("PetType", value);
  }

  set isSeen(bool value) {
    _sharedPrefs!.setBool("seen", value);
  }

  clearPetType(){
    _sharedPrefs!.remove("PetType");
  }

  clearPackageDetails(){
    _sharedPrefs!.remove('packageName');
  }

}