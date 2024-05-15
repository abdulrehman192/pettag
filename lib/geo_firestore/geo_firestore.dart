import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'geo_hash.dart';
import 'geo_hash_query.dart';
import 'geo_utils.dart';

///
/// A GeoFirestore instance is used to store and query geo location data in Firestore.
///
class GeoFirestore {
  CollectionReference collectionReference;

  GeoFirestore(this.collectionReference);

  ///
  /// Build a GeoPoint from a [documentSnapshot]
  ///
  static GeoPoint? getLocationValue(DocumentSnapshot documentSnapshot) {
    try {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      if (data != null &&
          data['longitude'] != null &&
          data['latitude'] != null) {
        final GeoPoint location = GeoPoint(data['latitude'], data['longitude']);
        final latitude = location.latitude;
        final longitude = location.longitude;
        if (GeoUtils.coordinatesValid(latitude, longitude)) {
          return location;
        }
      }
      return null;
    } catch (e) {
      print('Error occurred when getLocationValue: $e');
      return null;
    }
  }

  /// Sets the [location] of a document for the given [documentID].
  Future<Map<String, dynamic>> setLocation(
      String documentID, GeoPoint location) async {
    if (documentID == null) {
      throw const FormatException('Document ID is null');
    }
    var docRef = collectionReference.doc(documentID);
    var geoHash = GeoHash.encode(location.latitude, location.longitude);
    // Create a Map with the fields to add
    var updates = <String, dynamic>{};
    updates['geoHash'] = geoHash;
    updates['latitude'] = location.latitude;
    updates['longitude'] = location.longitude;
    // Update the DocumentReference with the location data
    await docRef.set(updates, SetOptions(merge: true));
    return updates;
  }

  ///
  /// Removes the [location] of a document for the given [documentID].
  ///
  Future<dynamic> removeLocation(String documentID, GeoPoint location) async {
    if (documentID == null) {
      throw const FormatException('Document ID is null');
    }
    //Get the DocumentReference for this documentID
    var docRef = collectionReference.doc(documentID);
    //Create a Map with the fields to add
    var updates = <String, dynamic>{};
    updates['geoHash'] = null;
    updates['latitude'] = null;
    updates['longitude'] = null;
    //Update the DocumentReference with the location data
    await docRef.set(updates, SetOptions(merge: true));
  }

  ///
  /// Gets the current location of a document for the given [documentID].
  ///
  Future<GeoPoint?> getLocation(String documentID) async {
    final snapshot = await collectionReference.doc(documentID).get();
    final geoPoint = getLocationValue(snapshot);
    return geoPoint;
  }

  Future<List<DocumentSnapshot>> getAtLocation(
    GeoPoint center,
    double radius, {
    bool exact = true,
    bool addDistance = true,
  }) async {
    final futures = GeoHashQuery.queriesAtLocation(
            center, GeoUtils.capRadius(radius) * 1000)
        .map((query) => query.createFirestoreQuery(this).get());

    try {
      List<DocumentSnapshot> documents = [];
      final snapshots = await Future.wait(futures);
      for (var snapshot in snapshots) {
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (addDistance || exact) {
            final distance = GeoUtils.distance(
                center, GeoPoint(data['latitude'], data['longitude']));
            if (exact) {
              if (distance <= radius) {
                data['distance'] = distance;
                documents.add(doc);
              }
            } else {
              data['distance'] = distance;
              documents.add(doc);
            }
          } else {
            documents.add(doc);
          }
        }
      }
      return documents;
    } catch (e) {
      print('Failed retrieving data for geo query: $e');
      rethrow;
    }
  }
}
