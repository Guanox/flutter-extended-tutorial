import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Startup {
  String key;
  final String name;

  Startup({
    @required this.name,
  });

  Startup._internal(this.key, this.name);

  Startup copyWith({String key, String name }) {
    return Startup._internal(
        key ?? this.key,
        name ?? this.name,
      );
  }

  Startup.fromSnapshot(DataSnapshot snapshot) 
    : key = snapshot.key,
      name = snapshot.value['name'];

  Map toJson() => {
    'key': key,
    'name': name
  };

  @override 
  String toString() {
    return toJson().toString();
  }
}

class AppState {
  final List<Startup> startups;
  final FirebaseState firebaseState;

  const AppState({
    @required this.startups,
    @required this.firebaseState,
  });

  AppState.initialState()  
    : startups = List.unmodifiable(<Startup>[]),
    firebaseState = new FirebaseState();

  Map toJson() => {
    'startups': startups
  };

  @override
  String toString() {
    return toJson().toString();
  }
}

class FirebaseState {
  final DatabaseReference mainReference;
  final FirebaseUser user;

  const FirebaseState({this.mainReference, this.user});

  FirebaseState copyWith({ DatabaseReference mainReference, FirebaseUser user }) {
    return new FirebaseState(
        mainReference: mainReference ?? this.mainReference,
        user: user ?? this.user,
        );
  }
}