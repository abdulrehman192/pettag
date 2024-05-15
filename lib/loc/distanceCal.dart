import 'dart:convert';

DistanceCal distanceCalFromJson(String str) => DistanceCal.fromJson(json.decode(str));

class DistanceCal {
  DistanceCal({
    this.routes,
  });

  List<Route>? routes;

  factory DistanceCal.fromJson(Map<String, dynamic> json) => DistanceCal(
    routes: List<Route>.from(json["routes"].map((x) => Route.fromJson(x))),
  );
}


class Route {
  Route({
    this.legs,
  });
  List<Leg>? legs;

  factory Route.fromJson(Map<String, dynamic> json) => Route(
    legs: List<Leg>.from(json["legs"].map((x) => Leg.fromJson(x))),
  );
}

class Leg {
  Leg({
    this.distance,
    this.duration,
  });

  Distance? distance;
  Distance? duration;


  factory Leg.fromJson(Map<String, dynamic> json) => Leg(
    distance: Distance.fromJson(json["distance"]),
    duration: Distance.fromJson(json["duration"]),
  );
}

class Distance {
  Distance({
    this.text,
    this.value,
  });

  String? text;
  int? value;

  factory Distance.fromJson(Map<String, dynamic> json) => Distance(
    text: json["text"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "value": value,
  };
}

