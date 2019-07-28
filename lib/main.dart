import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; //it allows us to convert our json to a list
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final appTitle = 'Mahara Wiphar Bar';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      home: MyHomePage(),
    );
  }
}

class StockCardMainPage extends StatefulWidget {
  @override
  _StockCardMainPageState createState() => _StockCardMainPageState();
}

class _StockCardMainPageState extends State<StockCardMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock card'),
      ),
      body: Center(),
    );
  }
}

class NewPricePage extends StatefulWidget {
  @override
  _NewPricePageState createState() => _NewPricePageState();
}

class _NewPricePageState extends State<NewPricePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New price'),
      ),
      body: Center(),
    );
  }
}

class PriceHistoryPage extends StatefulWidget {
  @override
  _PriceHistoryPageState createState() => _PriceHistoryPageState();
}

class _PriceHistoryPageState extends State<PriceHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Price history'),
      ),
      body: Center(),
    );
  }
}

class NewProductPage extends StatefulWidget {
  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New product'),
      ),
      body: Center(),
    );
  }
}

class NewUserAccountPage extends StatefulWidget {
  @override
  _NewUserAccountPageState createState() => _NewUserAccountPageState();
}

class _NewUserAccountPageState extends State<NewUserAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New user account'),
      ),
      body: Center(),
    );
  }
}

class PricingMainPage extends StatefulWidget {
  @override
  _PricingMainPageState createState() => _PricingMainPageState();
}

class _PricingMainPageState extends State<PricingMainPage> {
  GlobalKey key = new GlobalKey();

  @override
  _showPopupMenu() async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(65.0, 84.0, 0.0, 0.0),
      items: [
        PopupMenuItem(
          child: InkWell(
            child: Text("New price"),
            onTap: () {
              //Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewPricePage()),
              );
            },
          ),
        ),
        PopupMenuItem(
          child: InkWell(
            child: Text("Price history"),
            onTap: () {
              //Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PriceHistoryPage()),
              );
            },
          ),
        ),
      ],
      elevation: 8.0,
    );
  }

  Widget build(BuildContext context) {
    int _act = 1;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pricing'),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('Castel'),
              subtitle: Text('Price: MK700'),
              onTap: _showPopupMenu,
              trailing: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductsMainPage extends StatefulWidget {
  @override
  _ProductsMainPageState createState() => _ProductsMainPageState();
}

class _ProductsMainPageState extends State<ProductsMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewProductPage()),
              );
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('Special'),
              subtitle: Text('Starting stock: 20 | Minimum requred: 12'),
              trailing: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    );
  }
}

class UserAccountsMainPage extends StatefulWidget {
  @override
  _UserAccountsMainPageState createState() => _UserAccountsMainPageState();
}

class _UserAccountsMainPageState extends State<UserAccountsMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User accounts'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewUserAccountPage()),
              );
            },
          )
        ],
      ),
      body: ListView(
        children: const <Widget>[
          Card(
            child: ListTile(
              title: Text('First user'),
              subtitle: Text(
                  'Username: admin | Email: test@gmail.com | Role: admin | Phone #: 01300300'),
              isThreeLine: true,
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Second user'),
              subtitle: Text(
                  'Username: admin | Email: test@gmail.com | Role: admin | Phone #: 01300300'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportsMainPage extends StatefulWidget {
  @override
  _ReportsMainPageState createState() => _ReportsMainPageState();
}

class _ReportsMainPageState extends State<ReportsMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
      ),
      body: Center(),
    );
  }
}

class SettingsMainPage extends StatefulWidget {
  @override
  _SettingsMainPageState createState() => _SettingsMainPageState();
}

class _SettingsMainPageState extends State<SettingsMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(),
    );
  }
}

class Debtor {
  var name;
  var amountOwed;
  var phoneNumber;
  var date;
  var amountPaid;
  var balanceDue;

  Debtor(
      {this.name,
      this.amountOwed,
      this.phoneNumber,
      this.date,
      this.amountPaid,
      this.balanceDue});

  factory Debtor.fromJson(Map<String, dynamic> json) {
    return Debtor(
      name: json['name'],
      amountOwed: json['amount_owed'],
      phoneNumber: json['phone_number'],
      date: json['date'],
      amountPaid: json['amount_paid'],
      balanceDue: json['balance_due'],
    );
  }

  Map toMap() {
    var map = Map<String, dynamic>();
    map["name"] = name;
    map["amount_owed"] = amountOwed;
    map["phone_number"] = phoneNumber;
    map["date"] = date;
    map["amount_paid"] = amountPaid;
    map["balance_due"] = balanceDue;

    return map;
  }
}

class DebtorsPage extends StatefulWidget {
  @override
  _DebtorsPageState createState() => _DebtorsPageState();
}

class _DebtorsPageState extends State<DebtorsPage> {
  String debtorsUrl = 'http://192.168.43.102:2000/api/v1/debtors';

  /*Future<dynamic> getDebtorsList() async {
    var response = await http.get(Uri.encodeFull(debtorsUrl),
        headers: {"Accept": "application/json"});
    print(json.decode(response.body.runtimeType.toString()));
    return json.decode(response.body);
  }*/

  String url = 'https://randomuser.me/api/?results=15';
  List data;

  Future<String> makeRequest() async {
    var response = await http.get(Uri.encodeFull(debtorsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  @override
  void initState() {
    this.makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debtors'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ),
      body: ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            print(data);
            return Card(
              child: ListTile(
                title: Text(data[i]["name"]),
                subtitle: Text(
                    'Amount owed: ${data[i]["amount_owed"]} | Date: 01-July-2019 | Amount paid: ${data[i]["amount_paid"]} | Balance: ${data[i]["balance_due"]} | Phone #: ${data[i]["phone_number"]}'),
                isThreeLine: true,
              ),
            );

            /*return new ListTile(
                title: new Text(data[i]["name"]["first"]),
                subtitle: new Text(data[i]["phone"]),
                leading: new CircleAvatar(
                  backgroundImage:
                      new NetworkImage(data[i]["picture"]["thumbnail"]),
                ));*/
          }),
    );
  }
}

class DamagesPage extends StatefulWidget {
  @override
  _DamagesPageState createState() => _DamagesPageState();
}

class _DamagesPageState extends State<DamagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Damages'),
      ),
      body: ListView(
        children: const <Widget>[
          Card(
            child: ListTile(
              title: Text('Ginger'),
              subtitle: Text(
                  'Date: 01-July-2019 | Damaged quantity: 2 | Product price: MK400 | Total amount: MK800'),
              isThreeLine: true,
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Lays'),
              subtitle: Text(
                  'Date: 01-July-2019 | Damaged quantity: 2 | Product price: MK400 | Total amount: MK800'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}

class ComplementaryPage extends StatefulWidget {
  @override
  _ComplementaryPageState createState() => _ComplementaryPageState();
}

class _ComplementaryPageState extends State<ComplementaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complementary'),
      ),
      body: ListView(
        children: const <Widget>[
          Card(
            child: ListTile(
              title: Text('Ginger'),
              subtitle: Text(
                  'Date: 01-July-2019 | Complementary quantity: 2 | Product price: MK400 | Total amount: MK800'),
              isThreeLine: true,
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Lays'),
              subtitle: Text(
                  'Date: 01-July-2019 | Complementary quantity: 2 | Product price: MK400 | Total amount: MK800'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}

class UserAccountsPage extends StatefulWidget {
  @override
  _UserAccountsPageState createState() => _UserAccountsPageState();
}

class _UserAccountsPageState extends State<UserAccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User accounts'),
      ),
      body: ListView(
        children: const <Widget>[
          Card(
            child: ListTile(
              title: Text('First user'),
              subtitle: Text(
                  'Username: admin | Email: test@gmail.com | Role: admin | Phone #: 01300300'),
              isThreeLine: true,
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Second user'),
              subtitle: Text(
                  'Username: admin | Email: test@gmail.com | Role: admin | Phone #: 01300300'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductsRunningOutOfStockPage extends StatefulWidget {
  @override
  _ProductsRunningOutOfStockPageState createState() =>
      _ProductsRunningOutOfStockPageState();
}

class _ProductsRunningOutOfStockPageState
    extends State<ProductsRunningOutOfStockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products running low'),
      ),
      body: ListView(
        children: const <Widget>[
          Card(
            child: ListTile(
              title: Text('Gualana'),
              subtitle: Text(
                  'Minimum required: 12 | Product category: Standard | Current stock: 7'),
              isThreeLine: true,
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Castel'),
              subtitle: Text(
                  'Minimum required: 40 | Product category: Standard | Current stock: 33'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductsOutOfStockPage extends StatefulWidget {
  @override
  _ProductsOutOfStockPageState createState() => _ProductsOutOfStockPageState();
}

class _ProductsOutOfStockPageState extends State<ProductsOutOfStockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products out of stock'),
      ),
      body: ListView(
        children: const <Widget>[
          Card(
            child: ListTile(
              title: Text('Gualana'),
              subtitle: Text(
                  'Minimum required: 12 | Product category: Standard | Current stock: 0'),
              isThreeLine: true,
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Castel'),
              subtitle: Text(
                  'Minimum required: 40 | Product category: Standard | Current stock: 0'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final String title;

  //MyHomePage({Key key, this.title}) : super(key: key);
  String debtorsUrl = 'http://192.168.43.102:2000/api/v1/debtors';
  String damagesUrl = 'http://192.168.43.102:2000/api/v1/damages';
  String complementaryUrl = 'http://192.168.43.102:2000/api/v1/complementary';
  String userAccountsUrl = 'http://192.168.43.102:2000/api/v1/user_accounts';
  String productsRunningOutOfStockUrl =
      'http://192.168.43.102:2000/api/v1/products_running_out_of_stock';
  String productsOutOfStockUrl =
      'http://192.168.43.102:2000/api/v1/products_out_of_stock';

  Future<dynamic> getDebtors() async {
    var response = await http.get(Uri.encodeFull(debtorsUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    return jsonResponse;
  }

  Future<dynamic> getDamages() async {
    var response = await http.get(Uri.encodeFull(damagesUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    return jsonResponse;
  }

  Future<dynamic> getComplementary() async {
    var response = await http.get(Uri.encodeFull(complementaryUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    return jsonResponse;
  }

  Future<dynamic> getUserAccounts() async {
    var response = await http.get(Uri.encodeFull(userAccountsUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    return jsonResponse;
  }

  Future<dynamic> getProductsRunningOutOfStock() async {
    var response = await http.get(Uri.encodeFull(productsRunningOutOfStockUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    return jsonResponse;
  }

  Future<dynamic> getProductsOutOfStock() async {
    var response = await http.get(Uri.encodeFull(productsOutOfStockUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    return jsonResponse;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mahara Wipha Bar"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              getDebtors();
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 8.0 / 9.0,
        // TODO: Build a grid of cards (102)
        children: <Widget>[
          Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 15.0 / 6.0,
                      child: Icon(Icons.arrow_forward_ios,
                          color: Colors.blueAccent),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Debtors'),
                          SizedBox(height: 8.0),
                          FutureBuilder(
                            future: getDebtors(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              /*switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                      return Text('Press button to start.');
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                      return Text('Awaiting result...');
                                    case ConnectionState.done:
                                      if (snapshot.hasError)
                                        return Text('Error: ${snapshot.error}');
                                      return Text('Result: ${snapshot.data}');
                                  }*/

                              if (snapshot.hasData) {
                                return Text('${snapshot.data.length}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold));
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                          //Text('20',
                          //style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DebtorsPage()),
                  );
                },
              )),
          Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 15.0 / 6.0,
                        child: Icon(Icons.arrow_forward_ios,
                            color: Colors.blueAccent),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Damages'),
                            SizedBox(height: 8.0),
                            FutureBuilder(
                              future: getDamages(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                /*switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                      return Text('Press button to start.');
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                      return Text('Awaiting result...');
                                    case ConnectionState.done:
                                      if (snapshot.hasError)
                                        return Text('Error: ${snapshot.error}');
                                      return Text('Result: ${snapshot.data}');
                                  }*/

                                if (snapshot.hasData) {
                                  return Text('${snapshot.data.length}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold));
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DamagesPage()),
                    );
                  })),
          Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 15.0 / 6.0,
                        child: Icon(Icons.arrow_forward_ios,
                            color: Colors.blueAccent),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Complementary'),
                            SizedBox(height: 8.0),
                            FutureBuilder(
                              future: getComplementary(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                /*switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                      return Text('Press button to start.');
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                      return Text('Awaiting result...');
                                    case ConnectionState.done:
                                      if (snapshot.hasError)
                                        return Text('Error: ${snapshot.error}');
                                      return Text('Result: ${snapshot.data}');
                                  }*/

                                if (snapshot.hasData) {
                                  return Text('${snapshot.data.length}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold));
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ComplementaryPage()),
                    );
                  })),
          Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 15.0 / 6.0,
                        child: Icon(Icons.arrow_forward_ios,
                            color: Colors.blueAccent),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('User accounts'),
                            SizedBox(height: 8.0),
                            FutureBuilder(
                              future: getUserAccounts(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                /*switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                      return Text('Press button to start.');
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                      return Text('Awaiting result...');
                                    case ConnectionState.done:
                                      if (snapshot.hasError)
                                        return Text('Error: ${snapshot.error}');
                                      return Text('Result: ${snapshot.data}');
                                  }*/

                                if (snapshot.hasData) {
                                  return Text('${snapshot.data.length}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold));
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserAccountsPage()),
                    );
                  })),
          Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 15.0 / 6.0,
                        child: Icon(Icons.arrow_forward_ios,
                            color: Colors.blueAccent),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Products running out of stock'),
                            SizedBox(height: 8.0),
                            FutureBuilder(
                              future: getProductsRunningOutOfStock(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                /*switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                      return Text('Press button to start.');
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                      return Text('Awaiting result...');
                                    case ConnectionState.done:
                                      if (snapshot.hasError)
                                        return Text('Error: ${snapshot.error}');
                                      return Text('Result: ${snapshot.data}');
                                  }*/

                                if (snapshot.hasData) {
                                  return Text('${snapshot.data.length}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold));
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProductsRunningOutOfStockPage()),
                    );
                  })),
          Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 15.0 / 6.0,
                        child: Icon(Icons.arrow_forward_ios,
                            color: Colors.blueAccent),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Products out of stock'),
                            SizedBox(height: 8.0),
                            FutureBuilder(
                              future: getProductsOutOfStock(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                /*switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                      return Text('Press button to start.');
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                      return Text('Awaiting result...');
                                    case ConnectionState.done:
                                      if (snapshot.hasError)
                                        return Text('Error: ${snapshot.error}');
                                      return Text('Result: ${snapshot.data}');
                                  }*/

                                if (snapshot.hasData) {
                                  return Text('${snapshot.data.length}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold));
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductsOutOfStockPage()),
                    );
                  }))
        ],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StockCardMainPage()),
                );
              },
            ),
            ListTile(
              title: Text('Pricing'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PricingMainPage()),
                );
              },
            ),
            ListTile(
              title: Text('Products'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsMainPage()),
                );
              },
            ),
            ListTile(
              title: Text('User accounts'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserAccountsMainPage()),
                );
              },
            ),
            ListTile(
              title: Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportsMainPage()),
                );
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsMainPage()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
