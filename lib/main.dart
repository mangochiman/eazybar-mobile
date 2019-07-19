import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final appTitle = 'eazy Bar';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(40.0),
                    margin: const EdgeInsets.only(top: 10.0, left: 5.0, bottom: 14.0, right: 5),
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [BoxShadow(
                          color: Colors.blueAccent,
                          blurRadius: 5.0,
                        ),]
                    ),

                    child: new Text("Debtors")
                ),

              ),
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(40.0),
                    margin: const EdgeInsets.only(top: 10.0, left: 5.0, bottom: 14.0, right: 5),
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [BoxShadow(
                          color: Colors.blueAccent,
                          blurRadius: 5.0,
                        ),]
                    ),
                    child: new Text("Damages")
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(40.0),
                    margin: const EdgeInsets.only(top: 10.0, left: 5.0, bottom: 14.0, right: 5),
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [BoxShadow(
                          color: Colors.blueAccent,
                          blurRadius: 5.0,
                        ),]
                    ),
                    child: new Text("Complementary")
                ),

              ),
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(40.0),
                    margin: const EdgeInsets.only(top: 10.0, left: 5.0, bottom: 14.0, right: 5),
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [BoxShadow(
                          color: Colors.blueAccent,
                          blurRadius: 5.0,
                        ),]
                    ),
                    child: new Text("User accounts")
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(40.0),
                    margin: const EdgeInsets.only(top: 10.0, left: 5.0, bottom: 14.0, right: 5),
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [BoxShadow(
                          color: Colors.blueAccent,
                          blurRadius: 5.0,
                        ),]
                    ),
                    child: new Text("Low stock")
                ),

              ),
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(40.0),
                    margin: const EdgeInsets.only(top: 10.0, left: 5.0, bottom: 14.0, right: 5),
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [BoxShadow(
                          color: Colors.blueAccent,
                          blurRadius: 5.0,
                        ),]
                    ),
                    child: new Text("Out of stock")
                ),
              )
            ],
          )
        ],
      ),



      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Ernest Matola <mngochiman@gmail.com>'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Stock card'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Pricing'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Products'),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('User accounts'),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Reports'),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: (){
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
