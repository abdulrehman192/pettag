
enum Packages {
  STANDARD,
  pettagPLUS,
  BREEDER,
  RESCUER,
}

extension packagesExtension on Packages {
  dynamic get getPackage {
    switch (this) {
      case Packages.STANDARD:
        return StandardPackagesModel(
          pkgName: 'Standard',
          likesLimit: 25,
          time: 8,
          adLimit: 10,
          ownerPicLimit: 3,
          petPicLimit: 5,
          petVideoLimit: 2,
          profileLimit: 1,
        );
      case Packages.pettagPLUS:
        return pettagPlusPackagesModel(
          pkgName: 'pettagPlus',
          superLikeLimit: 5,
          profileLimit: 2,
          petVideoLimit: 2,
          petPicLimit: 5,
          ownerPicLimit: 5,
          boosterShotLimit: 1,
        );
      case Packages.BREEDER:
        return BreederPackagesModel(
          pkgName: 'Breeder',
          boosterShotLimit: 3,
          petPicLimit: 30,
          profileLimit: 6,
        );
      case Packages.RESCUER:
        return RescuerPackagesModel(
          pkgName: 'Rescuer',
          petPicLimit: 3,
          boosterShotLimit: 3,
          petVideoLimit: 1,
          profileCount: 15,
        );
      /*case Packages.BREEDER:
        return 'Ms White Cat';
      case Packages.pettagPLUS:
        return 'Ms White Cat';
      case Packages.RESCUER:
        return 'Ms White Cat';*/
      default:
        return null;
    }
  }

  String? get name {
    switch (this) {
      case Packages.STANDARD:
        return 'STANDARD';
      case Packages.RESCUER:
        return 'RESCUER';
      case Packages.pettagPLUS:
        return 'pettagPLUS';
      case Packages.BREEDER:
        return 'BREEDER';
      default:
        return null;
    }
  }
}

class StandardPackagesModel {
  String? pkgName;
  int? likesLimit;
  int? time;
  int? adLimit;
  int? profileLimit;
  int? petPicLimit;
  int? petVideoLimit;
  int? ownerPicLimit;

  StandardPackagesModel(
      {this.pkgName,
      this.likesLimit,
      this.time,
      this.adLimit,
      this.profileLimit,
      this.petPicLimit,
      this.petVideoLimit,
      this.ownerPicLimit});
}

class pettagPlusPackagesModel {
  String? pkgName;
  int? boosterShotLimit;
  int? superLikeLimit;
  int? profileLimit;
  int? petPicLimit;
  int? petVideoLimit;
  int? ownerPicLimit;

  pettagPlusPackagesModel({
    this.boosterShotLimit,
    this.ownerPicLimit,
    this.petPicLimit,
    this.petVideoLimit,
    this.pkgName,
    this.profileLimit,
    this.superLikeLimit,
  });
}

class BreederPackagesModel {
  String? pkgName;
  int? petPicLimit;
  int? boosterShotLimit;
  int? profileLimit;

  BreederPackagesModel({
    this.profileLimit,
    this.pkgName,
    this.petPicLimit,
    this.boosterShotLimit,
  });
}

class RescuerPackagesModel {
  String? pkgName;
  int? profileCount;
  int? petPicLimit;
  int? boosterShotLimit;
  int? petVideoLimit;

  RescuerPackagesModel({
    this.petPicLimit,
    this.pkgName,
    this.boosterShotLimit,
    this.profileCount,
    this.petVideoLimit,
  });
}
