import 'package:pettag/search_places/geolocation.dart';
import 'geocoding.dart';

class Place {
  Place(
    Geocoding geocode, {
    this.description,
    this.placeId,
    this.types,
  }) {
    _geocode = geocode;
  }

  Place.fromJSON(place, Geocoding geocode) {
    try {
      description = place["description"];
      placeId = place["place_id"];
      types = place["types"];

      _geocode = geocode;
      fullJSON = place;
    } catch (e) {
      print("The argument you passed for Place is not compatible.");
    }
  }
  String? description;

  String? placeId;
  List<dynamic>? types;
  var fullJSON;
  Geocoding? _geocode;
  Geolocation? _geolocation;
  Future<Geolocation?> get geolocation async {
    if (_geolocation == null) {
      _geolocation = await _geocode!.getGeolocation(description!);
      return _geolocation;
    }
    return _geolocation;
  }
}
