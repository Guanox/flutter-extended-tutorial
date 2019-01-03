import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';

import 'suggestions_page.dart';
import 'favorites_page.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => new MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final _widgetTabs = [
    new SuggestionsPage(),
    new FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        onInit: (store) => store.dispatch(InitAction()),
        builder: (context, viewModel) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Startup Name Generator'),
              actions: <Widget>[
                new Container(
                  height: 50,
                  width: 50,
                  child: new FlatButton(
                    onPressed: () {
                      if (viewModel.user?.isAnonymous) {
                        viewModel.login();
                      } else {
                        viewModel.logout();
                      }
                    },
                    child: new ConstrainedBox(
                      constraints: new BoxConstraints.expand(),
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(
                          color: Colors.white,
                          style: BorderStyle.solid,
                          width: 2.0),
                      image: DecorationImage(
                          image: viewModel.user?.isAnonymous ?? true
                              ? AssetImage('assets/user.png')
                              : NetworkImage(viewModel.user.photoUrl))),
                ),
              ],
            ),
            body: _widgetTabs.elementAt(_selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), title: Text('home')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle), title: Text('account'))
              ],
              fixedColor: Colors.lightBlue,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // void _pushSaved() {
  //   _ViewModel viewModel = _ViewModel.create(store);
  //   Navigator.of(context)
  //       .push(new MaterialPageRoute<void>(builder: (BuildContext context) {
  //     final Iterable<ListTile> tiles =
  //         viewModel.startups.map((Startup startup) {
  //       return new ListTile(
  //         title: new Text(startup.name, style: TextStyle(fontSize: 18.0)),
  //         trailing: new MaterialButton(
  //             child: Text("remove"),
  //             textColor: Colors.red,
  //             onPressed: () {
  //               viewModel.removeStartup(startup);
  //             }),
  //       );
  //     });
  //     final List<Widget> divided = ListTile.divideTiles(
  //       context: context,
  //       tiles: tiles,
  //     ).toList();

  //     return new Scaffold(
  //       appBar: new AppBar(
  //         title: Text('Saved Suggestions'),
  //       ),
  //       body: new ListView(children: divided),
  //     );
  //   }));
  // }
}

class _ViewModel {
  final FirebaseUser user;
  final Function() login;
  final Function() logout;

  _ViewModel({this.user, this.login, this.logout});

  factory _ViewModel.create(Store<AppState> store) {
    _login() {
      store.dispatch(GoogleLoginAction(cachedStartups: store.state.startups));
    }

    _logout() {
      store.dispatch(GoogleLogoutAction());
    }

    return _ViewModel(
        user: store.state.firebaseState.user, login: _login, logout: _logout);
  }
}
