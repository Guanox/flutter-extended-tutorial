import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';

import 'package:liftr/model/model.dart';
import 'package:liftr/redux/actions.dart';
import 'package:liftr/redux/reducers.dart';
import 'package:liftr/redux/middleware.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DevToolsStore<AppState> store = DevToolsStore<AppState>(
      appStateReducer,
      initialState: AppState.initialState(),
      middleware: appStateMiddleware(),
    );

    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: StoreBuilder<AppState>(
          onInit: (store) => store.dispatch(InitAction()),
          builder: (BuildContext context, Store<AppState> store) =>
              RandomWords(store),
        ),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  final DevToolsStore<AppState> store;

  RandomWords(this.store);

  @override
  RandomWordsState createState() => new RandomWordsState(store);
}

class RandomWordsState extends State<RandomWords> {
  int _selectedIndex = 1;
  final DevToolsStore<AppState> store;

  final List<WordPair> _suggestions = <WordPair>[];

  RandomWordsState(this.store);

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
                new IconButton(
                    icon: const Icon(Icons.list), onPressed: _pushSaved),
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
                          image: viewModel.user?.isAnonymous ??
                                  true
                              ? AssetImage('assets/user.png')
                              : NetworkImage(
                                  viewModel.user.photoUrl))),
                ),
              ],
            ),
            body: _buildSuggestions(viewModel),
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
            drawer: Container(
              child: ReduxDevTools(store),
            ),
          );
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSuggestions(_ViewModel viewModel) {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return new Divider();
          }

          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index], viewModel);
        });
  }

  Widget _buildRow(WordPair pair, _ViewModel viewModel) {
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: TextStyle(fontSize: 18.0),
      ),
      onTap: () {
        _suggestions.remove(pair);
        viewModel.addStartup(pair.asPascalCase);
      },
    );
  }

  void _pushSaved() {
    _ViewModel viewModel = _ViewModel.create(store);
    Navigator.of(context)
        .push(new MaterialPageRoute<void>(builder: (BuildContext context) {
      final Iterable<ListTile> tiles =
          viewModel.startups.map((Startup startup) {
        return new ListTile(
          title: new Text(startup.name, style: TextStyle(fontSize: 18.0)),
          trailing: new MaterialButton(
              child: Text("remove"),
              textColor: Colors.red,
              onPressed: () {
                viewModel.removeStartup(startup);
              }),
        );
      });
      final List<Widget> divided = ListTile.divideTiles(
        context: context,
        tiles: tiles,
      ).toList();

      return new Scaffold(
        appBar: new AppBar(
          title: Text('Saved Suggestions'),
        ),
        body: new ListView(children: divided),
      );
    }));
  }
}

class _ViewModel {
  final List<Startup> startups;
  final FirebaseUser user;
  final Function(String) addStartup;
  final Function(Startup) removeStartup;
  final Function() login;
  final Function() logout;
  final Function(List<Startup>) onGoogleLogin;

  _ViewModel(
      {this.startups,
      this.user,
      this.addStartup,
      this.removeStartup,
      this.login,
      this.logout,
      this.onGoogleLogin});

  factory _ViewModel.create(Store<AppState> store) {
    _addStartup(String name) {
      store.dispatch(AddStartupAction(Startup(name: name)));
    }

    _removeStartup(Startup startup) {
      store.dispatch(RemoveStartupAction(startup));
    }

    _login() {
      store.dispatch(GoogleLoginAction(cachedStartups: store.state.startups));
    }

    _logout() {
      store.dispatch(GoogleLogoutAction());
    }

    _onGoogleLogin(List<Startup> cachedStartups) {
      store.dispatch(GoogleLoginAction(cachedStartups: cachedStartups));
    }

    return _ViewModel(
        startups: store.state.startups,
        user: store.state.firebaseState.user,
        addStartup: _addStartup,
        removeStartup: _removeStartup,
        onGoogleLogin: _onGoogleLogin,
        login: _login,
        logout: _logout);
  }
}
