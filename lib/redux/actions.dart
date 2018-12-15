import 'package:liftr/model/model.dart';

class AddStartupAction {
  static int _id = 0;
  final String name;

  AddStartupAction(this.name) {
    _id = _id + 1;
  }  

  int get id => _id;
}

class RemoveStartupAction {
  final Startup startup;

  RemoveStartupAction(this.startup);
}

class GetStartupsAction { }

class LoadedStartupsAction {
  final List<Startup> startups;

  LoadedStartupsAction(this.startups);
}
