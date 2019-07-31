import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; //it allows us to convert our json to a list
import 'package:http/http.dart' as http;

const String URL = "http://192.168.12.69:2000";
String debtorsUrl = URL + '/api/v1/debtors';
String damagesUrl = URL + '/api/v1/damages';
String complementaryUrl = URL + '/api/v1/complementary';
String userAccountsUrl = URL + '/api/v1/user_accounts';
String productsPricesUrl = URL + '/api/v1/products_prices';
String priceHistoryUrl = URL + '/api/v1/price_history';
String productsUrl = URL + '/api/v1/products';
String productsRunningOutOfStockUrl =
    URL + '/api/v1/products_running_out_of_stock';
String productsOutOfStockUrl = URL + '/api/v1/products_out_of_stock';

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
  final String productID;
  final String productName;

  const NewPricePage({Key key, this.productID, this.productName})
      : super(key: key);

  @override
  _NewPricePageState createState() => _NewPricePageState();
}

class _NewPricePageState extends State<NewPricePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New price of ' + widget.productName),
      ),
      body: Center(
        child: Text('${widget.productID}'),
      ),
    );
  }
}

class PriceHistoryPage extends StatefulWidget {
  final String productID;
  final String productName;

  const PriceHistoryPage({Key key, this.productID, this.productName})
      : super(key: key);

  @override
  _PriceHistoryPageState createState() => _PriceHistoryPageState();
}

class _PriceHistoryPageState extends State<PriceHistoryPage> {
  List data;

  Future<String> getPriceHistory() async {
    var response = await http.get(
        Uri.encodeFull('${priceHistoryUrl}?product_id=${widget.productID}'),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
      print(jsonResponse);
    });
  }

  @override
  void initState() {
    this.getPriceHistory();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Price history of ' + widget.productName),
      ),
      body: ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            return Card(
              child: ListTile(
                title:
                    Text(data[i]["start_date"] + ' - ' + data[i]["end_date"]),
                subtitle: Text('Price: ${data[i]["price"]}'),
                isThreeLine: true,
              ),
            );
          }),
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

  List data;

  Future<String> getPricesList() async {
    var response = await http.get(Uri.encodeFull(productsPricesUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  @override
  void initState() {
    this.getPricesList();
  }

  final String _simpleValue1 = 'Menu item value one';
  final String _simpleValue2 = 'Menu item value two';
  final String _simpleValue3 = 'Menu item value three';
  String _simpleValue;

  final String _checkedValue1 = 'One';
  final String _checkedValue2 = 'Two';
  final String _checkedValue3 = 'Free';
  final String _checkedValue4 = 'Four';

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

  void showMenuSelection(String value) {
    //print(value);
    List array = value.split("|");
    var productID = array[1];
    var productName = array[2];
    if (array[0].contains('new_price')) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NewPricePage(productID: productID, productName: productName)),
      );
    }
    if (array[0].contains('price_history')) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PriceHistoryPage(
                productID: productID, productName: productName)),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pricing'),
      ),
      body: ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            return Card(
              child: ListTile(
                title: Text(data[i]["product_name"]),
                subtitle: Text(
                    'Product category: ${data[i]["product_category"]} | Product Price: ${data[i]["product_price"]}'),
                trailing: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    onSelected: showMenuSelection,
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuItem<String>>[
                          PopupMenuItem<String>(
                            value:
                                'new_price|${data[i]["product_id"]}|${data[i]["product_name"]}',
                            child: const Text('New price'),
                          ),
                          PopupMenuItem<String>(
                            value:
                                'price_history|${data[i]["product_id"]}|${data[i]["product_name"]}',
                            child: const Text('Price history'),
                          ),
                        ]),
                isThreeLine: true,
              ),
            );
          }),
    );
  }
}

class ProductsMainPage extends StatefulWidget {
  @override
  _ProductsMainPageState createState() => _ProductsMainPageState();
}

class _ProductsMainPageState extends State<ProductsMainPage> {
  List data;
  Future<String> getProductsList() async {
    var response = await http.get(
        Uri.encodeFull(productsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
      print(jsonResponse);
    });
  }

  @override
  void initState() {
    this.getProductsList();
  }

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
      body: ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            return Card(
              child: ListTile(
                title:
                Text(data[i]["product_name"]),
                subtitle: Text('Minimum required: ${data[i]["minimum_required"]} | Current stock: ${data[i]["current_stock"]}'),
                isThreeLine: true,
              ),
            );
          }),
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
  List data;

  Future<String> getDebtorsList() async {
    var response = await http.get(Uri.encodeFull(debtorsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  @override
  void initState() {
    this.getDebtorsList();
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
            return Card(
              child: ListTile(
                title: Text(data[i]["name"]),
                subtitle: Text(
                    'Amount owed: ${data[i]["amount_owed"]} | Date: ${data[i]["date"]} | Amount paid: ${data[i]["amount_paid"]} | Balance: ${data[i]["balance_due"]} | Phone #: ${data[i]["phone_number"]}'),
                isThreeLine: true,
              ),
            );
          }),
    );
  }
}

class DamagesPage extends StatefulWidget {
  @override
  _DamagesPageState createState() => _DamagesPageState();
}

class _DamagesPageState extends State<DamagesPage> {
  List data;

  Future<String> getDamagesList() async {
    var response = await http.get(Uri.encodeFull(damagesUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  @override
  void initState() {
    this.getDamagesList();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Damages'),
      ),
      body: ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            return Card(
              child: ListTile(
                title: Text(data[i]["product_name"]),
                subtitle: Text(
                    'Date: ${data[i]["stock_date"]} | Damaged quantity: ${data[i]["damaged_quantity"]} | Product price: ${data[i]["product_price"]} | Product category : ${data[i]["product_category"]} | Total amount : ${data[i]["damaged_value"]}'),
                isThreeLine: true,
              ),
            );
          }),
    );
  }
}

class ComplementaryPage extends StatefulWidget {
  @override
  _ComplementaryPageState createState() => _ComplementaryPageState();
}

class _ComplementaryPageState extends State<ComplementaryPage> {
  List data;

  Future<String> getComplementaryList() async {
    var response = await http.get(Uri.encodeFull(complementaryUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  @override
  void initState() {
    this.getComplementaryList();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complementary'),
      ),
      body: ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            return Card(
              child: ListTile(
                title: Text(data[i]["product_name"]),
                subtitle: Text(
                    'Date: ${data[i]["stock_date"]} | Complementary quantity: ${data[i]["complementary_quantity"]} | Product price: ${data[i]["product_price"]} | Product category : ${data[i]["product_category"]} | Total amount : ${data[i]["complementary_value"]}'),
                isThreeLine: true,
              ),
            );
          }),
    );
  }
}

class UserAccountsPage extends StatefulWidget {
  @override
  _UserAccountsPageState createState() => _UserAccountsPageState();
}

class _UserAccountsPageState extends State<UserAccountsPage> {
  List data;

  Future<String> getUserAccountList() async {
    var response = await http.get(Uri.encodeFull(userAccountsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  @override
  void initState() {
    this.getUserAccountList();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User accounts'),
      ),
      body: ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            return Card(
              child: ListTile(
                title: Text('${data[i]["first_name"]} ${data[i]["last_name"]}'),
                subtitle: Text(
                    'Username: ${data[i]["username"]} | E-mail: ${data[i]["email"]} | Role: ${data[i]["role"]} | Phone # : ${data[i]["phone_number"]}'),
                isThreeLine: true,
              ),
            );
          }),
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
  List data;

  Future<String> getProductsRunningOutOfStockList() async {
    var response = await http.get(Uri.encodeFull(productsRunningOutOfStockUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  @override
  void initState() {
    this.getProductsRunningOutOfStockList();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products running low'),
      ),
      body: ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            return Card(
              child: ListTile(
                title: Text('${data[i]["product_name"]}'),
                subtitle: Text(
                    'Minimum required: ${data[i]["minimum_required"]} | Product category: ${data[i]["product_category"]} | Current stock: ${data[i]["current_stock"]}'),
                isThreeLine: true,
              ),
            );
          }),
    );
  }
}

class ProductsOutOfStockPage extends StatefulWidget {
  @override
  _ProductsOutOfStockPageState createState() => _ProductsOutOfStockPageState();
}

class _ProductsOutOfStockPageState extends State<ProductsOutOfStockPage> {
  List data;

  Future<String> getProductsOutOfStockList() async {
    var response = await http.get(Uri.encodeFull(productsOutOfStockUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  @override
  void initState() {
    this.getProductsOutOfStockList();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products out of stock'),
      ),
      body: ListView.builder(
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, i) {
            return Card(
              child: ListTile(
                title: Text('${data[i]["product_name"]}'),
                subtitle: Text(
                    'Minimum required: ${data[i]["minimum_required"]} | Product category: ${data[i]["product_category"]} | Current stock: ${data[i]["current_stock"]}'),
                isThreeLine: true,
              ),
            );
          }),
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
                      builder: (context) => UserAccountsPage()),
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
