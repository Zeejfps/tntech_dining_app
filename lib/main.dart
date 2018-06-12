import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:tntech_dining_app/api.dart';
import 'package:tntech_dining_app/models.dart';
import 'package:tntech_dining_app/repo.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'TNTech Dinning',
      theme: new ThemeData(
        primaryColor: new Color(0xFF4F2984),
        accentColor: new Color(0xFFFFDD00),
        primaryColorDark: new Color(0xFF000000),
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  var _date = new DateTime.now();
  var _formatter = new DateFormat.MMMEd();
  Set<Location> _favorites = new Set();
  TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(_formatter.format(_date)),
        centerTitle: true,
        bottom: new TabBar(
          controller: _tabCtrl,
          tabs: [
            new Tab(
              text: "Favorites",
            ),
            new Tab(
              text: "Locations",
            )
          ],
        ),
      ),
      body: new TabBarView(
        controller: _tabCtrl,
        children: [
          _buildFavoritesTab(DefaultTabController.of(context)),
          new FutureBuilder<Set<Location>>(
              future: loadLocations(_date),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return new ListView(
                    children: _buildList(snapshot.data),
                  );
                }
                return new Center(child: new CircularProgressIndicator());
              }),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => _changeDate(context),
        child: new Icon(
          Icons.date_range,
          color: Theme.of(context).primaryColor,
          semanticLabel: "Choose date",
        ),
      ),
    );
  }

  Widget _buildFavoritesTab(TabController controller) {
    if (_favorites.isEmpty) {
      return new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
                padding: EdgeInsets.all(12.0),
                child: new Text(
                  "You do not have any favorites.",
                )),
            new RaisedButton(
              color: Theme.of(context).primaryColor,
              child: new Text(
                "View Locations",
                style: new TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                _tabCtrl.animateTo(1);
              },
            ),
          ],
        ),
      );
    } else {
      return new ListView(
        children: _buildFavoritesList(),
      );
    }
  }

  List<Widget> _buildFavoritesList() {
    List<Widget> favorites = new List();
    for (var location in _favorites) {
      favorites.add(new Column(
        children: <Widget>[
          new ListTile(
            enabled: location.opened,
            title: new Text(location.name),
            leading: new IconButton(
                icon: _chooseIcon(location),
                onPressed: () {
                  _toggleFavorite(location);
                }),
            onTap: () => _showDetailScreen(location),
          ),
          const Divider(height: 1.0)
        ],
      ));
    }
    return favorites;
  }

  List<Widget> _buildList(Set<Location> locations) {
    print("Building");
    List<Widget> items = new List();
    for (var location in locations) {
      if (location.name != null)
        items.add(new Column(
          children: <Widget>[
            new ListTile(
              enabled: location.opened,
              title: new Text(location.name),
              leading: new IconButton(
                  icon: _chooseIcon(location),
                  onPressed: () {
                    _toggleFavorite(location);
                  }),
              onTap: () => _showDetailScreen(location),
            ),
            const Divider(height: 1.0)
          ],
        ));
    }
    return items;
  }

  Icon _chooseIcon(Location location) {
    if (_favorites.contains(location)) {
      return new Icon(
        Icons.star,
        color: Theme.of(context).accentColor,
        size: 24.0,
      );
    } else {
      return new Icon(Icons.star_border);
    }
  }

  void _toggleFavorite(Location location) {
    setState(() {
      if (_favorites.contains(location)) {
        _favorites.remove(location);
      } else {
        _favorites.add(location);
      }
    });
  }

  void _showDetailScreen(Location location) {
    Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new DetailedScreen(
                location: location,
                date: _date,
              )),
    );
  }

  Future<Null> _changeDate(BuildContext context) async {
    var now = new DateTime.now();
    var ini = now.isBefore(_date) ? _date : now;
    var lst = now.add(new Duration(days: 31));
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: ini,
      firstDate: now,
      lastDate: lst,
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }
}

class DetailedScreen extends StatelessWidget {
  final Location location;
  final DateTime date;

  DetailedScreen({Key key, this.location, this.date});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(location.name),
      ),
      body: new FutureBuilder<Menu>(
          future: fetchMenuForLocation(location, date),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return new ListView(
                children: _buildPanels(snapshot.data),
              );
            } else if (snapshot.hasError) {
              return new Text("${snapshot.error}");
            }

            return new Center(child: new CircularProgressIndicator());
          }),
    );
  }

  List<ExpansionTile> _buildPanels(Menu menu) {
    List<ExpansionTile> views = new List();
    for (var period in menu.periods.keys) {
      List<Widget> categories = new List();
      for (var category in menu.periods[period]) {
        if (category.items.isEmpty) continue;
        List<Widget> items = new List();
        category.items.forEach((item) {
          items.add(new ListTile(
            title: new Text(item.name),
            subtitle: new Text(item.description),
          ));
        });
        categories.add(new ExpansionTile(
          title: new Text(category.name),
          children: items,
        ));
      }
      views.add(new ExpansionTile(
        title: new Text(period),
        children: categories,
      ));
    }
    return views;
  }
}
