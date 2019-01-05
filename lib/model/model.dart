import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Startup {
  Startup({
    @required this.name,
  });

  Startup.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'];

  Startup._internal(this.key, this.name);

  String key;
  final String name;

  Startup copyWith({String key, String name}) {
    return Startup._internal(
      key ?? this.key,
      name ?? this.name,
    );
  }

  Map toJson() => {'key': key, 'name': name};

  @override
  String toString() {
    return toJson().toString();
  }
}

class AppState {
  const AppState({
    @required this.startups,
    @required this.firebaseState,
  });

  AppState.initialState()
      : startups = List.unmodifiable(<Startup>[]),
        firebaseState = FirebaseState();


  final List<Startup> startups;
  final FirebaseState firebaseState;

  Map toJson() => {'startups': startups};

  @override
  String toString() {
    return toJson().toString();
  }
}

class FirebaseState {
  final DatabaseReference mainReference;
  final StreamSubscription<Event> subAddStartup;
  final StreamSubscription<Event> subRemoveStartup;
  final FirebaseUser user;

  const FirebaseState(
      {this.mainReference,
      this.user,
      this.subAddStartup,
      this.subRemoveStartup});

  FirebaseState copyWith(
      {DatabaseReference mainReference,
      FirebaseUser user,
      StreamSubscription<Event> subAddStartup,
      StreamSubscription<Event> subRemoveStartup}) {
    return FirebaseState(
      mainReference: mainReference ?? this.mainReference,
      user: user ?? this.user,
      subAddStartup: subAddStartup ?? this.subAddStartup,
      subRemoveStartup: subRemoveStartup ?? this.subRemoveStartup,
    );
  }
}
