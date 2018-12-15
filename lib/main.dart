import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

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
          onInit: (store) => store.dispatch(GetStartupsAction()),
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
  final DevToolsStore<AppState> store;

  final List<WordPair> _suggestions = <WordPair>[];
  final _saved = new Set<WordPair>();

  RandomWordsState(this.store);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: StoreConnector<AppState, _ViewModel>(
        converter: (Store<AppState> store) => _ViewModel.create(store),
        builder: (BuildContext context, _ViewModel viewModel) =>
            _buildSuggestions(viewModel),
      ),
      drawer: Container(
        child: ReduxDevTools(store),
      ),
    );
  }

  Widget _buildSuggestions(_ViewModel viewModel) {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        // The itemBuilder callback is called once per suggested
        // word pairing, and places each suggestion into a ListTile
        // row. For even rows, the function adds a ListTile row for
        // the word pairing. For odd rows, the function adds a
        // Divider widget to visually separate the entries. Note that
        // the divider may be difficult to see on smaller devices.
        itemBuilder: (BuildContext _context, int i) {
          // Add a one-pixel-high divider widget before each row
          // in the ListView.
          if (i.isOdd) {
            return new Divider();
          }

          // The syntax "i ~/ 2" divides i by 2 and returns an
          // integer result.
          // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
          // This calculates the actual number of word pairings
          // in the ListView,minus the divider widgets.
          final int index = i ~/ 2;
          // If you've reached the end of the available word
          // pairings...
          if (index >= _suggestions.length) {
            // ...then generate 10 more and add them to the
            // suggestions list.
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index], viewModel);
        });
  }

  Widget _buildRow(WordPair pair, _ViewModel viewModel) {
    final alreadySaved =
        viewModel.startups.where((s) => s.name == pair.asPascalCase).isNotEmpty;
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: TextStyle(fontSize: 18.0),
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        if (alreadySaved) {
          Startup s = viewModel.startups
              .firstWhere((startup) => startup.name == pair.asPascalCase);
          viewModel.onRemoveStartup(s);
        } else {
          viewModel.onAddStartup(pair.asPascalCase);
        }
      }, // ... to here.
    );
  }

  void _pushSaved() {
    _ViewModel viewModel = _ViewModel.create(store);
    Navigator.of(context)
        .push(new MaterialPageRoute<void>(builder: (BuildContext context) {
      final Iterable<ListTile> tiles =
          viewModel.startups.map((Startup startup) {
        return new ListTile(
            title: new Text(
          startup.name,
          style: TextStyle(fontSize: 18.0),
        ));
      });
      final List<Widget> divided = ListTile.divideTiles(
        context: context,
        tiles: tiles,
      ).toList();

      return new Scaffold(
        appBar: new AppBar(
          title: const Text('Saved Suggestions'),
        ),
        body: new ListView(children: divided),
      );
    }));
  }
}

class _ViewModel {
  final List<Startup> startups;
  final Function(String) onAddStartup;
  final Function(Startup) onRemoveStartup;

  _ViewModel({this.startups, this.onAddStartup, this.onRemoveStartup});

  factory _ViewModel.create(Store<AppState> store) {
    _onAddStartup(String name) {
      store.dispatch(AddStartupAction(name));
    }

    _onRemoveStartup(Startup startup) {
      store.dispatch(RemoveStartupAction(startup));
    }

    return _ViewModel(
      startups: store.state.startups,
      onAddStartup: _onAddStartup,
      onRemoveStartup: _onRemoveStartup,
    );
  }
}
