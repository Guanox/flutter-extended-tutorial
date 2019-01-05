import 'dart:async';
import 'package:liftr/model/model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLoadedAction {
  final FirebaseUser user;

  UserLoadedAction(this.user);
}

class GoogleLoginAction {
  final List<Startup> cachedStartups;

  GoogleLoginAction({this.cachedStartups = const []});
}

class GoogleLogoutAction {}

class RemoveStartupsAction {}

class AddStartupAction {
  final Startup startup;

  AddStartupAction(this.startup);
}

class AddedStartupAction {
  final Event event;

  AddedStartupAction(this.event);
}

class RemoveStartupAction {
  final Startup startup;

  RemoveStartupAction(this.startup);
}

class RemovedStartupAction {
  final Event event;

  RemovedStartupAction(this.event);
}

class InitAction { }

class AddDatabaseReferenceAction {
  final DatabaseReference databaseReference;
  final StreamSubscription<Event> subAddStartup;
  final StreamSubscription<Event> subRemoveStartup;

  AddDatabaseReferenceAction(this.databaseReference, this.subAddStartup, this.subRemoveStartup);
}