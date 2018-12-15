import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class Startup {
  final int id;
  final String name;
  final bool favorited;

  Startup({
    @required this.id,
    @required this.name,
    this.favorited = false,
  });

  Startup copyWith({int id, String name, bool favorited}) {
    return Startup(
        id: id ?? this.id,
        name: name ?? this.name,
        favorited: favorited ?? this.favorited,
      );
  }

  Startup.fromJson(Map json)
    : id = json['id'],
      name = json['name'],
      favorited = json['favorited'];

  Map toJson() => {
    'id': id,
    'name': name,
    'favorited': favorited,
  };

  @override 
  String toString() {
    return toJson().toString();
  }
}

class AppState {
  final List<Startup> startups;

  const AppState({
    @required this.startups,
  });

  AppState.initialState()  
    : startups = List.unmodifiable(<Startup>[]);

  AppState.fromJson(Map json)
    : startups = (json['startups'] as List).map((i) => Startup.fromJson(i)).toList();

  Map toJson() => {
    'startups': startups
  };

  @override
  String toString() {
    return toJson().toString();
  }
}