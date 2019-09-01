import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; //it allows us to convert our json to a list
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

const String URL = "http://192.168.43.102:2000";
//const String URL = "http://71.19.148.18:5000";
//const String URL = "http://71.19.148.18:3000";

String debtorsUrl = URL + '/api/v1/debtors';
String damagesUrl = URL + '/api/v1/damages';
String complementaryUrl = URL + '/api/v1/complementary';
String userAccountsUrl = URL + '/api/v1/user_accounts';
String productsPricesUrl = URL + '/api/v1/products_prices';
String priceHistoryUrl = URL + '/api/v1/price_history';
String productsUrl = URL + '/api/v1/products';
String searchDebtorsUrl = URL + '/api/v1/search_debtors';
String overdueDebtorsUrl = URL + '/api/v1/overdue_debtors';
String searchOverdueDebtorsUrl = URL + '/api/v1/search_overdue_debtors';
String debtorPaymentsUrl = URL + '/api/v1/debtor_payments';
String searchDebtorPaymentsUrl = URL + '/api/v1/search_debtor_payments';
String productsRunningOutOfStockUrl =
    URL + '/api/v1/products_running_out_of_stock';
String productsOutOfStockUrl = URL + '/api/v1/products_out_of_stock';
String createProductUrl = URL + '/api/v1/create_product';
String createPriceUrl = URL + '/api/v1/create_product_prices';
String reportsUrl = URL + '/api/v1/reports';
String debtPaymentPropertyURL = URL + '/api/v1/debt_payment_period';
String updateSettingsURL = URL + '/api/v1/update_settings';
String standardProductsDataURL = URL + '/api/v1/standard_products_data';
String nonStandardProductsDataURL = URL + '/api/v1/non_standard_products_data';
String debtorsOnDateURL = URL + '/api/v1/debtors_on_date';

String addStockURL = URL + '/api/v1/add_stock';
String addDebtorsURL = URL + '/api/v1/create_debtors';
String productsTotalURL = URL + '/api/v1/products_count';
String authenticateUserURL = URL + '/api/v1/authenticate';
String createStockURL = URL + '/api/v1/create_stock';
String passwordReminderURL = URL + '/api/v1/reset_password';
String newUserURL = URL + '/api/v1/new_user';
String debtorPaymentsOnDateURL = URL + '/api/v1/debtor_payments_on_date';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

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

String stockDate = DateFormat("yyyy-MM-dd")
    .format(DateTime.parse(DateTime.now().toIso8601String()));

class StockCardMainPage extends StatefulWidget {
  @override
  _StockCardMainPageState createState() => _StockCardMainPageState();
}

class _StockCardMainPageState extends State<StockCardMainPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = new TextEditingController();
  GlobalKey<_StandardItemsPageState> _keyChild1 = GlobalKey();

  Future<String> getStandardItems() async {
    var response = await http.get(
        Uri.encodeFull(standardProductsDataURL + "?date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      standardProducts = [];
      var jsonResponse = json.decode(response.body);
      standardProducts = jsonResponse;
      if (standardProducts.length > 0) {
        stockCardAvailable = standardProducts[0]["stock_card_available"];
      }
    });
  }

  Future<String> getNonStandardItems() async {
    var response = await http.get(
        Uri.encodeFull(nonStandardProductsDataURL + "?date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      nonStandardProducts = [];
      var jsonResponse = json.decode(response.body);
      nonStandardProducts = jsonResponse;
      if (nonStandardProducts.length > 0) {
        stockCardAvailable = nonStandardProducts[0]["stock_card_available"];
      }
    });
  }

  Future<String> getDebtorsOnDate() async {
    var response = await http.get(
        Uri.encodeFull(debtorsOnDateURL + "?stock_date=" + stockDate),
        headers: {"Accept": "application/json"});
    setState(() {
      debtorsOnDate = [];
      var jsonResponse = json.decode(response.body);
      debtorsOnDate = jsonResponse;
    });
  }

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now());

    if (result == null) return;
    setState(() {
      stockDate = DateFormat("yyyy-MM-dd")
          .format(DateTime.parse(result.toIso8601String()));
      _controller.text = new DateFormat.yMd().format(result);
    });

    getStandardItems();
    getNonStandardItems();
    getDebtorsOnDate();
    selectedPositions = [];
    selectedButtons = [];

    //_keyChild1.currentState.initState();
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: _keyChild1,
      home: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
              ),
              bottom: TabBar(tabs: [
                Tab(text: 'Standard'),
                Tab(text: 'Non standard'),
                Tab(text: 'Debtors'),
                Tab(text: 'Summary')
              ], isScrollable: true),
              title: Text('Stock card (' + stockDate + ')'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _chooseDate(context, _controller.text);
                  },
                )
              ]),
          body: TabBarView(
            children: [
              StandardItemsPage(),
              NonStandardItemsPage(),
              DebtorsOnDatePage(),
              StockSummaryPage()
            ],
          ),
        ),
      ),
    );
  }
}

List standardProducts = [];
List nonStandardProducts = [];
bool stockCardAvailable = false;
List selectedPositions = [];
List selectedButtons = [];
Map closedProducts = {};
int productsCount = 0;

class StandardItemsPage extends StatefulWidget {
  StandardItemsPage({Key key}) : super(key: key);

  @override
  _StandardItemsPageState createState() => _StandardItemsPageState();
}

class _StandardItemsPageState extends State<StandardItemsPage>
    with AutomaticKeepAliveClientMixin<StandardItemsPage> {
  TextEditingController _textFieldController = TextEditingController();
  bool isLoading = true;

  Future<String> getStandardItems() async {
    var response = await http.get(
        Uri.encodeFull(standardProductsDataURL + "?date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      standardProducts = jsonResponse;
      isLoading = false;
      if (standardProducts.length > 0) {
        stockCardAvailable = standardProducts[0]["stock_card_available"];
      }
    });
  }

  Future<String> getProductsCount() async {
    var response = await http.get(Uri.encodeFull(productsTotalURL),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      productsCount = jsonResponse["count"];
    });
  }

  @override
  bool get wantKeepAlive => true;

  void initState() {
    this.getStandardItems();
    this.getProductsCount();
  }

  bool _isPositiveNumber(String str) {
    if (str == null) {
      return false;
    }

    double number = double.tryParse(str);
    if (number != null && number >= 0) {
      return true;
    } else {
      return false;
    }
  }

  ListView getListView() => new ListView.builder(
      itemCount: standardProducts.length,
      itemBuilder: (BuildContext context, int position) {
        return getRow(position);
      });

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    Scaffold.of(context).showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void updateDifferenceAndTotalSales(int i) {
    int defaultValue = 0;
    final formatCurrency = NumberFormat("#,##0.00", "en_US");
    int closingStock =
        int.tryParse(standardProducts[i]["closing_stock"]) ?? defaultValue;
    int currentStock =
        int.tryParse(standardProducts[i]["current_stock"]) ?? defaultValue;
    int damagedStock =
        int.tryParse(standardProducts[i]["damaged_stock"]) ?? defaultValue;
    int complementaryStock =
        int.tryParse(standardProducts[i]["complementary_stock"]) ??
            defaultValue;
    double currentPrice =
        double.tryParse(standardProducts[i]["price"]) ?? defaultValue;
    int difference = currentStock - closingStock;
    var totalSales =
        currentPrice * (difference - damagedStock - complementaryStock);
    setState(() {
      standardProducts[i]["difference"] = difference.toString();
      standardProducts[i]["total_sales"] =
          'MWK ${formatCurrency.format(totalSales)}'; //totalSales.toString();
    });
  }

  void updateAddedStock(BuildContext context, int i) {
    var productAdditionService = ProductAdditionService();
    ProductAddition newProductAddition = new ProductAddition();
    newProductAddition.quantity = _textFieldController.text;
    newProductAddition.productID = standardProducts[i]["product_id"].toString();
    newProductAddition.stockDate = stockDate;

    productAdditionService
        .createProductAddition(newProductAddition)
        .then((value) {
      if (value.errors != null && value.errors.length > 0) {
        showMessage('Errors:\n ${value.errors.join('\n')}', Colors.red);
      } else {
        Navigator.of(context).pop();
        setState(() {
          standardProducts[i]["add"] = value.quantity;
          standardProducts[i]["current_stock"] = value.currentStock;
        });
        _textFieldController.text = "";
        showMessage('Success', Colors.blue);
      }
    });
  }

  void updateClosedStock(BuildContext context, int i) {
    if (!_isPositiveNumber(_textFieldController.text)) {
      showMessage('Please input a valid number');
      return null;
    }

    int defaultValue = 0;

    int currentClosingStock =
        int.tryParse(_textFieldController.text) ?? defaultValue;

    int currentProductStock =
        int.tryParse(standardProducts[i]["current_stock"]) ?? defaultValue;
    int currentDamagedStock =
        int.tryParse(standardProducts[i]["damaged_stock"]) ?? defaultValue;
    int currentComplementaryStock =
        int.tryParse(standardProducts[i]["complementary_stock"]) ??
            defaultValue;

    int currentDifference = currentProductStock - currentClosingStock;
    int totalSales =
        currentDifference - currentDamagedStock - currentComplementaryStock;

    if (currentClosingStock > currentProductStock) {
      showMessage('Closing amount exceeds current stock');
      return null;
    }

    if (totalSales < 0) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    int totalInputValue =
        totalSales + currentDamagedStock + currentComplementaryStock;
    if (totalInputValue > currentProductStock) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    Navigator.of(context).pop();
    setState(() {
      standardProducts[i]["closing_stock"] = _textFieldController.text;
      var productID = standardProducts[i]["product_id"];
      if (closedProducts[productID] == null) {
        closedProducts[productID] = {};
      }
      closedProducts[productID]["stock"] = _textFieldController.text;
      closedProducts[productID]["price"] = standardProducts[i]["price"];
      closedProducts[productID]["product_type"] =
          standardProducts[i]["product_type"];
      closedProducts[productID]["current_stock"] =
          standardProducts[i]["current_stock"];
    });

    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  void updateDamagedStock(BuildContext context, int i) {
    if (!_isPositiveNumber(_textFieldController.text)) {
      showMessage('Please input a valid number');
      return null;
    }

    int defaultValue = 0;
    int currentDamagedStock =
        int.tryParse(_textFieldController.text) ?? defaultValue;

    int currentClosingStock =
        int.tryParse(standardProducts[i]["closing_stock"]) ?? defaultValue;

    int currentProductStock =
        int.tryParse(standardProducts[i]["current_stock"]) ?? defaultValue;

    int currentComplementaryStock =
        int.tryParse(standardProducts[i]["complementary_stock"]) ??
            defaultValue;

    int currentDifference = currentProductStock - currentClosingStock;
    int totalSales =
        currentDifference - currentDamagedStock - currentComplementaryStock;

    if (currentDamagedStock > currentProductStock) {
      showMessage('Damages exceed current stock');
      return null;
    }

    if (totalSales < 0) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    int totalInputValue =
        totalSales + currentDamagedStock + currentComplementaryStock;
    if (totalInputValue > currentProductStock) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    Navigator.of(context).pop();
    setState(() {
      standardProducts[i]["damaged_stock"] = _textFieldController.text;
      var productID = standardProducts[i]["product_id"];
      if (closedProducts[productID] == null) {
        closedProducts[productID] = {};
      }
      closedProducts[productID]["damage"] = _textFieldController.text;
      closedProducts[productID]["price"] = standardProducts[i]["price"];
      closedProducts[productID]["product_type"] =
          standardProducts[i]["product_type"];
      closedProducts[productID]["current_stock"] =
          standardProducts[i]["current_stock"];
    });

    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  void updateComplementaryStock(BuildContext context, int i) {
    if (!_isPositiveNumber(_textFieldController.text)) {
      showMessage('Please input a valid number');
      return null;
    }

    int defaultValue = 0;
    int currentComplementaryStock =
        int.tryParse(_textFieldController.text) ?? defaultValue;

    int currentClosingStock =
        int.tryParse(standardProducts[i]["closing_stock"]) ?? defaultValue;

    int currentProductStock =
        int.tryParse(standardProducts[i]["current_stock"]) ?? defaultValue;

    int currentDamagedStock =
        int.tryParse(standardProducts[i]["damaged_stock"]) ?? defaultValue;

    int currentDifference = currentProductStock - currentClosingStock;
    int totalSales =
        currentDifference - currentDamagedStock - currentComplementaryStock;

    if (currentComplementaryStock > currentProductStock) {
      showMessage('Complementary exceeds current stock');
      return null;
    }

    if (totalSales < 0) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    int totalInputValue =
        totalSales + currentDamagedStock + currentComplementaryStock;
    if (totalInputValue > currentProductStock) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    Navigator.of(context).pop();
    setState(() {
      standardProducts[i]["complementary_stock"] = _textFieldController.text;
      var productID = standardProducts[i]["product_id"];
      if (closedProducts[productID] == null) {
        closedProducts[productID] = {};
      }
      closedProducts[productID]["complementary"] = _textFieldController.text;
      closedProducts[productID]["price"] = standardProducts[i]["price"];
      closedProducts[productID]["product_type"] =
          standardProducts[i]["product_type"];
      closedProducts[productID]["current_stock"] =
          standardProducts[i]["current_stock"];
    });

    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  _showAddStockDialog(BuildContext context, int position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add stock'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Add stock"),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Update stock'),
                onPressed: () {
                  setState(() {
                    selectedPositions.add(position);
                    selectedButtons.add("add" + "-" + position.toString());
                  });
                  updateAddedStock(context, position);
                },
              )
            ],
          );
        });
  }

  _showCloseStockDialog(BuildContext context, int position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Close stock'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Closing amount"),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Close stock'),
                onPressed: () {
                  setState(() {
                    selectedPositions.add(position);
                    selectedButtons.add("close" + "-" + position.toString());
                  });
                  updateClosedStock(context, position);
                  //_updateSettings();
                },
              )
            ],
          );
        });
  }

  _showDamagedStockDialog(BuildContext context, int position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update damages'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Damaged stock"),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Update'),
                onPressed: () {
                  setState(() {
                    selectedPositions.add(position);
                    selectedButtons.add("damage" + "-" + position.toString());
                  });
                  updateDamagedStock(context, position);
                  //_updateSettings();
                },
              )
            ],
          );
        });
  }

  _showComplementaryStockDialog(BuildContext context, int position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update complementary'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Complementary stock"),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Update'),
                onPressed: () {
                  setState(() {
                    selectedPositions.add(position);
                    selectedButtons
                        .add("complementary" + "-" + position.toString());
                  });
                  updateComplementaryStock(context, position);
                  //_updateSettings();
                },
              )
            ],
          );
        });
  }

  Widget getRow(int i) {
    return new Padding(
        padding: new EdgeInsets.all(1.0),
        child: new Card(
          child: new Column(
            children: <Widget>[
              ListTile(
                  title: Text(
                standardProducts[i]["product_name"],
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )),
              Container(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  dataRowHeight: 16,
                  headingRowHeight: 0,
                  columns: [
                    DataColumn(
                      label: Text(""),
                      numeric: false,
                      tooltip: "",
                    ),
                    DataColumn(
                      label: Text(''),
                      numeric: false,
                      tooltip: "",
                    ),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text("Opening stock")),
                      DataCell(Text(standardProducts[i]["opening"]))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Added stock")),
                      DataCell(Text(standardProducts[i]["add"],
                          style: (selectedPositions.contains(i) &&
                                  selectedButtons
                                      .contains("add" + "-" + i.toString()))
                              ? TextStyle(color: Colors.green)
                              : TextStyle(color: Colors.black)))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Current stock")),
                      DataCell(Text(standardProducts[i]["current_stock"]))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Closing stock")),
                      DataCell(Text(
                        standardProducts[i]["closing_stock"],
                        style: (selectedPositions.contains(i) &&
                                selectedButtons
                                    .contains("close" + "-" + i.toString()))
                            ? TextStyle(color: Colors.green)
                            : TextStyle(color: Colors.black),
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Damaged stock")),
                      DataCell(Text(
                        standardProducts[i]["damaged_stock"],
                        style: (selectedPositions.contains(i) &&
                                selectedButtons
                                    .contains("damage" + "-" + i.toString()))
                            ? TextStyle(color: Colors.green)
                            : TextStyle(color: Colors.black),
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Complementary stock")),
                      DataCell(Text(
                        standardProducts[i]["complementary_stock"],
                        style: (selectedPositions.contains(i) &&
                                selectedButtons.contains(
                                    "complementary" + "-" + i.toString()))
                            ? TextStyle(color: Colors.green)
                            : TextStyle(color: Colors.black),
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Difference")),
                      DataCell(Text(standardProducts[i]["difference"]))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Price")),
                      DataCell(Text(standardProducts[i]["product_price"]))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Total sales")),
                      DataCell(Text(standardProducts[i]["total_sales"]))
                    ])
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: !stockCardAvailable ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: ButtonTheme.bar(
                  child: new ButtonBar(
                    children: <Widget>[
                      new FlatButton(
                        child: const Text('Add'),
                        onPressed: () {
                          _showAddStockDialog(context, i);
                        },
                      ),
                      new FlatButton(
                        child: const Text('Close'),
                        onPressed: () {
                          _showCloseStockDialog(context, i);
                        },
                      ),
                      new FlatButton(
                        child: const Text('Damages'),
                        onPressed: () {
                          _showDamagedStockDialog(context, i);
                        },
                      ),
                      new FlatButton(
                        child: const Text('Complementary'),
                        onPressed: () {
                          _showComplementaryStockDialog(context, i);
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      color: Colors.blueGrey[500],
      child: Container(
        child: new Stack(
          children: <Widget>[
            new Container(child: getListView()),
            AnimatedOpacity(
              opacity: (isLoading == true) ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//*******************************************************************************************************************************
//*******************************************************************************************************************************

class NonStandardItemsPage extends StatefulWidget {
  NonStandardItemsPage({Key key}) : super(key: key);

  @override
  _NonStandardItemsPageState createState() => _NonStandardItemsPageState();
}

class _NonStandardItemsPageState extends State<NonStandardItemsPage>
    with AutomaticKeepAliveClientMixin<NonStandardItemsPage> {
  TextEditingController _textFieldController = TextEditingController();
  bool isLoading = true;

  bool _isPositiveNumber(String str) {
    if (str == null) {
      return false;
    }

    double number = double.tryParse(str);
    if (number != null && number >= 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> getNonStandardItems() async {
    var response = await http.get(
        Uri.encodeFull(nonStandardProductsDataURL + "?date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      nonStandardProducts = jsonResponse;
      isLoading = false;
      if (nonStandardProducts.length > 0) {
        stockCardAvailable = nonStandardProducts[0]["stock_card_available"];
      }
    });
  }

  Future<String> getProductsCount() async {
    var response = await http.get(Uri.encodeFull(productsTotalURL),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      productsCount = jsonResponse["count"];
    });
  }

  @override
  bool get wantKeepAlive => true;

  void initState() {
    this.getNonStandardItems();
    this.getProductsCount();
  }

  ListView getListView() => new ListView.builder(
      itemCount: nonStandardProducts.length,
      itemBuilder: (BuildContext context, int position) {
        return getRow(position);
      });

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    Scaffold.of(context).showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void updateDifferenceAndTotalSales(int i) {
    int defaultValue = 0;
    final formatCurrency = NumberFormat("#,##0.00", "en_US");
    int closingStock =
        int.tryParse(nonStandardProducts[i]["closing_stock"]) ?? defaultValue;
    double currentPrice =
        double.tryParse(nonStandardProducts[i]["price"]) ?? defaultValue;
    var totalSales = currentPrice * closingStock;
    setState(() {
      nonStandardProducts[i]["total_sales"] =
          'MWK ${formatCurrency.format(totalSales)}';
    });
  }

  void updateAddedStock(BuildContext context, int i) {
    var productAdditionService = ProductAdditionService();
    ProductAddition newProductAddition = new ProductAddition();
    newProductAddition.quantity = _textFieldController.text;
    newProductAddition.productID =
        nonStandardProducts[i]["product_id"].toString();
    newProductAddition.stockDate = stockDate;

    productAdditionService
        .createProductAddition(newProductAddition)
        .then((value) {
      if (value.errors != null && value.errors.length > 0) {
        showMessage('Errors:\n ${value.errors.join('\n')}', Colors.red);
      } else {
        Navigator.of(context).pop();
        setState(() {
          nonStandardProducts[i]["add"] = value.quantity;
          nonStandardProducts[i]["current_stock"] = value.currentStock;
        });
        _textFieldController.text = "";
        showMessage('Success', Colors.blue);
      }
    });
  }

  void updateClosedStock(BuildContext context, int i) {
    if (!_isPositiveNumber(_textFieldController.text)) {
      showMessage('Please input a valid number');
      return null;
    }

    int defaultValue = 0;

    int currentClosingStock =
        int.tryParse(_textFieldController.text) ?? defaultValue;

    int currentProductStock =
        int.tryParse(nonStandardProducts[i]["current_stock"]) ?? defaultValue;
    int currentDamagedStock =
        int.tryParse(nonStandardProducts[i]["damaged_stock"]) ?? defaultValue;
    int currentComplementaryStock =
        int.tryParse(nonStandardProducts[i]["complementary_stock"]) ??
            defaultValue;

    int totalSales = currentClosingStock;

    if (currentClosingStock > currentProductStock) {
      showMessage('Closing amount exceeds current stock');
      return null;
    }

    if (totalSales < 0) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    int totalInputValue =
        totalSales + currentDamagedStock + currentComplementaryStock;
    if (totalInputValue > currentProductStock) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    Navigator.of(context).pop();
    setState(() {
      nonStandardProducts[i]["closing_stock"] = _textFieldController.text;
      var productID = nonStandardProducts[i]["product_id"];
      if (closedProducts[productID] == null) {
        closedProducts[productID] = {};
      }
      closedProducts[productID]["stock"] = _textFieldController.text;
      closedProducts[productID]["price"] = nonStandardProducts[i]["price"];
      closedProducts[productID]["product_type"] =
          nonStandardProducts[i]["product_type"];
      closedProducts[productID]["current_stock"] =
          nonStandardProducts[i]["current_stock"];
    });
    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  void updateDamagedStock(BuildContext context, int i) {
    if (!_isPositiveNumber(_textFieldController.text)) {
      showMessage('Please input a valid number');
      return null;
    }

    int defaultValue = 0;
    int currentDamagedStock =
        int.tryParse(_textFieldController.text) ?? defaultValue;

    int currentClosingStock =
        int.tryParse(nonStandardProducts[i]["closing_stock"]) ?? defaultValue;

    int currentProductStock =
        int.tryParse(nonStandardProducts[i]["current_stock"]) ?? defaultValue;

    int currentComplementaryStock =
        int.tryParse(nonStandardProducts[i]["complementary_stock"]) ??
            defaultValue;

    int totalSales = currentClosingStock;

    if (currentDamagedStock > currentProductStock) {
      showMessage('Damages exceed current stock');
      return null;
    }

    if (totalSales < 0) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    int totalInputValue =
        totalSales + currentDamagedStock + currentComplementaryStock;
    if (totalInputValue > currentProductStock) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    Navigator.of(context).pop();
    setState(() {
      nonStandardProducts[i]["damaged_stock"] = _textFieldController.text;
      var productID = nonStandardProducts[i]["product_id"];
      if (closedProducts[productID] == null) {
        closedProducts[productID] = {};
      }
      closedProducts[productID]["damage"] = _textFieldController.text;
      closedProducts[productID]["price"] = nonStandardProducts[i]["price"];
      closedProducts[productID]["product_type"] =
          nonStandardProducts[i]["product_type"];
      closedProducts[productID]["current_stock"] =
          nonStandardProducts[i]["current_stock"];
    });

    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  void updateComplementaryStock(BuildContext context, int i) {
    if (!_isPositiveNumber(_textFieldController.text)) {
      showMessage('Please input a valid number');
      return null;
    }

    int defaultValue = 0;
    int currentComplementaryStock =
        int.tryParse(_textFieldController.text) ?? defaultValue;

    int currentClosingStock =
        int.tryParse(nonStandardProducts[i]["closing_stock"]) ?? defaultValue;

    int currentProductStock =
        int.tryParse(nonStandardProducts[i]["current_stock"]) ?? defaultValue;

    int currentDamagedStock =
        int.tryParse(nonStandardProducts[i]["damaged_stock"]) ?? defaultValue;

    int totalSales = currentClosingStock;

    if (currentComplementaryStock > currentProductStock) {
      showMessage('Complementary exceeds current stock');
      return null;
    }

    if (totalSales < 0) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    int totalInputValue =
        totalSales + currentDamagedStock + currentComplementaryStock;
    if (totalInputValue > currentProductStock) {
      showMessage(
          'Closing stock + Damages + Complementary is exceeding current stock. Edit the input and try again');
      return null;
    }

    Navigator.of(context).pop();
    setState(() {
      nonStandardProducts[i]["complementary_stock"] = _textFieldController.text;
      var productID = nonStandardProducts[i]["product_id"];
      if (closedProducts[productID] == null) {
        closedProducts[productID] = {};
      }
      closedProducts[productID]["complementary"] = _textFieldController.text;
      closedProducts[productID]["price"] = nonStandardProducts[i]["price"];
      closedProducts[productID]["product_type"] =
          nonStandardProducts[i]["product_type"];
      closedProducts[productID]["current_stock"] =
          nonStandardProducts[i]["current_stock"];
    });

    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  _showAddStockDialog(BuildContext context, int position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add stock'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Add stock"),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Update stock'),
                onPressed: () {
                  setState(() {
                    selectedPositions.add(position);
                    selectedButtons.add("add" + "-" + position.toString());
                  });
                  updateAddedStock(context, position);
                },
              )
            ],
          );
        });
  }

  _showCloseStockDialog(BuildContext context, int position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Shots sold'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Quantity"),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Close stock'),
                onPressed: () {
                  setState(() {
                    selectedPositions.add(position);
                    selectedButtons.add("close" + "-" + position.toString());
                  });
                  updateClosedStock(context, position);
                  //_updateSettings();
                },
              )
            ],
          );
        });
  }

  _showDamagedStockDialog(BuildContext context, int position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update damages'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Damaged stock"),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Update'),
                onPressed: () {
                  setState(() {
                    selectedPositions.add(position);
                    selectedButtons.add("damage" + "-" + position.toString());
                  });
                  updateDamagedStock(context, position);
                  //_updateSettings();
                },
              )
            ],
          );
        });
  }

  _showComplementaryStockDialog(BuildContext context, int position) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Update complementary'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Complementary stock"),
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Update'),
                onPressed: () {
                  setState(() {
                    selectedPositions.add(position);
                    selectedButtons
                        .add("complementary" + "-" + position.toString());
                  });
                  updateComplementaryStock(context, position);
                  //_updateSettings();
                },
              )
            ],
          );
        });
  }

  Widget getRow(int i) {
    return new Padding(
        padding: new EdgeInsets.all(1.0),
        child: new Card(
          child: new Column(
            children: <Widget>[
              ListTile(
                  title: Text(
                nonStandardProducts[i]["product_name"],
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )),
              Container(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  dataRowHeight: 16,
                  headingRowHeight: 0,
                  columns: [
                    DataColumn(
                      label: Text(""),
                      numeric: false,
                      tooltip: "",
                    ),
                    DataColumn(
                      label: Text(''),
                      numeric: false,
                      tooltip: "",
                    ),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text("Opening stock")),
                      DataCell(Text(nonStandardProducts[i]["opening"]))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Added stock")),
                      DataCell(Text(nonStandardProducts[i]["add"],
                          style: (selectedPositions.contains(i) &&
                                  selectedButtons
                                      .contains("add" + "-" + i.toString()))
                              ? TextStyle(color: Colors.green)
                              : TextStyle(color: Colors.black)))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Current stock")),
                      DataCell(Text(nonStandardProducts[i]["current_stock"]))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Closing stock")),
                      DataCell(Text(
                        nonStandardProducts[i]["closing_stock"],
                        style: (selectedPositions.contains(i) &&
                                selectedButtons
                                    .contains("close" + "-" + i.toString()))
                            ? TextStyle(color: Colors.green)
                            : TextStyle(color: Colors.black),
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Damaged stock")),
                      DataCell(Text(
                        nonStandardProducts[i]["damaged_stock"],
                        style: (selectedPositions.contains(i) &&
                                selectedButtons
                                    .contains("damage" + "-" + i.toString()))
                            ? TextStyle(color: Colors.green)
                            : TextStyle(color: Colors.black),
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Complementary stock")),
                      DataCell(Text(
                        nonStandardProducts[i]["complementary_stock"],
                        style: (selectedPositions.contains(i) &&
                                selectedButtons.contains(
                                    "complementary" + "-" + i.toString()))
                            ? TextStyle(color: Colors.green)
                            : TextStyle(color: Colors.black),
                      ))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Price")),
                      DataCell(Text(nonStandardProducts[i]["product_price"]))
                    ]),
                    DataRow(cells: [
                      DataCell(Text("Total sales")),
                      DataCell(Text(nonStandardProducts[i]["total_sales"]))
                    ])
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: !stockCardAvailable ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: ButtonTheme.bar(
                  child: new ButtonBar(
                    children: <Widget>[
                      new FlatButton(
                        child: const Text('Add'),
                        onPressed: () {
                          _showAddStockDialog(context, i);
                        },
                      ),
                      new FlatButton(
                        child: const Text('Close'),
                        onPressed: () {
                          _showCloseStockDialog(context, i);
                        },
                      ),
                      new FlatButton(
                        child: const Text('Damages'),
                        onPressed: () {
                          _showDamagedStockDialog(context, i);
                        },
                      ),
                      new FlatButton(
                        child: const Text('Complementary'),
                        onPressed: () {
                          _showComplementaryStockDialog(context, i);
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      color: Colors.blueGrey[500],
      child: Container(
        child: new Stack(
          children: <Widget>[
            new Container(child: getListView()),
            AnimatedOpacity(
              opacity: (isLoading == true) ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//********************************************************************************************************************************
//********************************************************************************************************************************

//*******************************************************************************************************************************
List debtorsOnDate = [];

class DebtorsOnDatePage extends StatefulWidget {
  DebtorsOnDatePage({Key key}) : super(key: key);

  @override
  _DebtorsOnDatePageState createState() => _DebtorsOnDatePageState();
}

class _DebtorsOnDatePageState extends State<DebtorsOnDatePage>
    with AutomaticKeepAliveClientMixin<DebtorsOnDatePage> {
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _amountFieldController = TextEditingController();
  TextEditingController _phoneNumberFieldController = TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  bool isLoading = true;
  Debtor debtor = new Debtor();

  void _submitForm(BuildContext context) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      if (!_isPositiveNumber(debtor.amountOwed)) {
        showMessage('Please input a valid number on amount owed input');
        return null;
      }

      form.save(); //This invokes each onSaved event

      var debtorService = new DebtorService();
      debtor.stockDate = stockDate;
      debtorService.createDebtor(debtor).then((value) {
        if (value.errors != null && value.errors.length > 0) {
          showMessage('Errors:\n ${value.errors.join('\n')}', Colors.red);
        } else {
          showMessage('${value.name} was added to debtors list', Colors.blue);
          form.reset();
          Navigator.of(context).pop();
          setState(() {
            debtorsOnDate.add({
              "name": value.name,
              "amount_owed": value.amountOwed,
              "phone_number": value.phoneNumber,
              "amount_paid": "MK 0.00",
              "balance_due": value.amountOwed,
              "date": value.stockDate
            });
          });
          _nameFieldController.text = "";
          _amountFieldController.text = "";
          _phoneNumberFieldController.text = "";
        }
      });
    }
  }

  Future<String> getDebtorsOnDate() async {
    var response = await http.get(
        Uri.encodeFull(debtorsOnDateURL + "?stock_date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      debtorsOnDate = jsonResponse;
      isLoading = false;
    });
  }

  @override
  bool get wantKeepAlive => true;

  void initState() {
    this.getDebtorsOnDate();
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    Scaffold.of(context).showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  bool _isPositiveNumber(String str) {
    if (str == null) {
      return false;
    }

    double number = double.tryParse(str);
    if (number != null && number >= 0) {
      return true;
    } else {
      return false;
    }
  }

  _showAddDebtorsDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New debtor'),
            content: SingleChildScrollView(
              child: SafeArea(
                  minimum: const EdgeInsets.all(16.0),
                  bottom: false,
                  top: false,
                  child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            controller: _nameFieldController,
                            decoration:
                                InputDecoration(hintText: "Debtor's Name"),
                            validator: (val) =>
                                val.isEmpty ? 'Name is required' : null,
                            onSaved: (val) => debtor.name = val,
                          ),
                          TextFormField(
                              controller: _amountFieldController,
                              decoration: InputDecoration(hintText: "Amount"),
                              keyboardType: TextInputType.number,
                              validator: (val) =>
                                  val.isEmpty ? 'Amount is required' : null,
                              onSaved: (val) => debtor.amountOwed = val),
                          TextFormField(
                              controller: _phoneNumberFieldController,
                              decoration:
                                  InputDecoration(hintText: "Phone number"),
                              keyboardType: TextInputType.phone,
                              validator: (val) => val.isEmpty
                                  ? 'Phone number is required'
                                  : null,
                              onSaved: (val) => debtor.phoneNumber = val)
                        ],
                      ))),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('SUBMIT'),
                onPressed: () {
                  _submitForm(context);
                },
              )
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: Visibility(
        visible: !stockCardAvailable,
        child: FloatingActionButton(
          onPressed: () {
            _showAddDebtorsDialog(context);
          },
          tooltip: 'Add debtor',
          child: new Icon(Icons.add),
        ),
      ),
      body: Container(
          height: 500.0, // Change as per your requirement

          child: Column(
            children: <Widget>[
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: debtorsOnDate.length,
                  itemBuilder: (BuildContext context, i) {
                    return Card(
                      child: ListTile(
                        title: Text(debtorsOnDate[i]["name"]),
                        subtitle: Text(
                            'Amount owed: ${debtorsOnDate[i]["amount_owed"]} | Amount paid: ${debtorsOnDate[i]["amount_paid"]} | Balance: ${debtorsOnDate[i]["balance_due"]} | Phone #: ${debtorsOnDate[i]["phone_number"]} | Date: ${debtorsOnDate[i]["date"]}'),
                        isThreeLine: true,
                      ),
                    );
                  }),
              AnimatedOpacity(
                opacity: (debtorsOnDate.length == 0) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("No debtors"),
                ),
              ),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: CircularProgressIndicator(),
              )
            ],
          )),
    );
  }
}

//********************************************************************************************************************************

class StockSummaryPage extends StatefulWidget {
  @override
  _StockSummaryPageState createState() => _StockSummaryPageState();
}

Map summaryData = {};
double expectedCashUnformatted;
double shortages = 0;
double cashCollected = 0;

class _StockSummaryPageState extends State<StockSummaryPage> {
  TextEditingController _amountFieldController = TextEditingController();
  TextEditingController _usernameFieldController = TextEditingController();
  TextEditingController _passwordFieldController = TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _authenticationFormKey =
      new GlobalKey<FormState>();
  static final _headers = {'Content-Type': 'application/json'};
  bool _obscureText = false;

  Future<String> resetVariables() async {
    selectedPositions = [];
    selectedButtons = [];
    closedProducts = {};

    var standardItemsResponse = await http.get(
        Uri.encodeFull(standardProductsDataURL + "?date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      standardProducts = [];
      var standardItemJsonResponse = json.decode(standardItemsResponse.body);
      standardProducts = standardItemJsonResponse;
      stockCardAvailable = true;
    });

    var nonStandardItemsResponseResponse = await http.get(
        Uri.encodeFull(nonStandardProductsDataURL + "?date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      nonStandardProducts = [];
      var nonStandardItemsResponseResponseJsonResponse =
          json.decode(nonStandardItemsResponseResponse.body);
      nonStandardProducts = nonStandardItemsResponseResponseJsonResponse;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  Future<String> authenticateUser(BuildContext context) async {
    Map userData = {};
    userData["username"] = _usernameFieldController.text;
    userData["password"] = _passwordFieldController.text;
    String json = jsonEncode(userData);

    final response =
        await http.post(authenticateUserURL, headers: _headers, body: json);
    var jsonResponse = jsonDecode(response.body);

    if (jsonResponse["status"] == "success") {
      submitForm(context);
    } else {
      showMessage('Wrong username/password combination');
    }
  }

  Future<String> submitForm(BuildContext context) async {
    Map stock = {};
    stock["stock_date"] = stockDate;
    stock["actual_cash"] = cashCollected;
    stock["stock_date"] = stockDate;
    stock["user_id"] = "1";
    stock["stock_details"] = {};

    closedProducts.forEach((productID, values) {
      var closedStock = values["stock"];
      var damagedStock = values["damage"];
      var complementaryStock = values["complementary"];
      var shotsSold = values["shots"];

      if (closedStock == null) {
        closedStock = "";
      }

      if (damagedStock == null) {
        damagedStock = "";
      }

      if (complementaryStock == null) {
        complementaryStock = "";
      }

      if (shotsSold == null) {
        shotsSold = "";
      }

      stock["stock_details"][productID.toString()] = {
        'stock': closedStock,
        'damage': damagedStock,
        'complementary': complementaryStock,
        'shots': shotsSold
      };
    });

    final response = await http.post(createStockURL,
        headers: _headers, body: json.encode(stock));

    var jsonResponse = jsonDecode(response.body);

    if (jsonResponse["status"] == "success") {
      _usernameFieldController.text = "";
      _passwordFieldController.text = "";
      setState(() {
        stockCardAvailable = true;
        showMessage('Success', Colors.blue);
      });
      Navigator.of(context).pop();
      resetVariables();
    } else {
      showMessage('Oops something went wrong');
    }
  }

  Future<String> getSummary() async {
    if (!stockCardAvailable) {
      var response = await http.get(
          Uri.encodeFull(debtorsOnDateURL + "?stock_date=" + stockDate),
          headers: {"Accept": "application/json"});

      var jsonResponse = json.decode(response.body);
      double debtorsTotal = 0;
      for (var i = 0; i <= jsonResponse.length - 1; i++) {
        String amountOwedString = jsonResponse[i]["amount_owed"];
        double amountOwed;
        try {
          amountOwed = double.parse(amountOwedString);
        } catch (e) {
          amountOwed = 0;
        }
        debtorsTotal += amountOwed;
      }

      double totalSales = 0;
      double complementaryTotal = 0;
      double damagesTotal = 0;

      final formatCurrency = NumberFormat("#,##0.00", "en_US");

      closedProducts.forEach((productID, values) {
        int defaultValue = 0;
        double defaultPrice = 0;
        int currentStock = 0;

        int closingStock;
        int damagedStock;
        int complementaryStock;
        double price;

        try {
          closingStock = int.parse(values["stock"]);
        } catch (e) {
          closingStock = defaultValue;
        }

        try {
          damagedStock = int.parse(values["damage"]);
        } catch (e) {
          damagedStock = defaultValue;
        }

        try {
          complementaryStock = int.parse(values["complementary"]);
        } catch (e) {
          complementaryStock = defaultValue;
        }

        try {
          currentStock = int.parse(values["current_stock"]);
        } catch (e) {
          currentStock = defaultValue;
        }

        try {
          price = double.parse(values["price"]);
        } catch (e) {
          price = defaultPrice;
        }

        var productType = values["product_type"];

        if (productType == "Non Standard") {
          totalSales += price * closingStock;
        } else {
          var difference = currentStock - closingStock;
          totalSales +=
              price * (difference - damagedStock - complementaryStock);
        }

        complementaryTotal += price * complementaryStock;
        damagesTotal += price * damagedStock;
      });

      var expectedCash = totalSales - debtorsTotal;

      setState(() {
        expectedCashUnformatted = expectedCash;
        summaryData["total_sales"] = "MWK ${formatCurrency.format(totalSales)}";
        summaryData["complementary_total"] =
            "MWK ${formatCurrency.format(complementaryTotal)}";
        summaryData["damages_total"] =
            "MWK ${formatCurrency.format(damagesTotal)}";
        summaryData["expected_cash"] =
            "MWK ${formatCurrency.format(expectedCash)}";
        summaryData["collected_cash"] =
            "MWK ${formatCurrency.format(cashCollected)}";
        summaryData["shortages"] = "MWK ${formatCurrency.format(shortages)}";

        summaryData["debtors"] = "MWK ${formatCurrency.format(debtorsTotal)}";
      });
    } else {
      var response = await http.get(
          Uri.encodeFull(reportsUrl + "?date=" + stockDate),
          headers: {"Accept": "application/json"});

      setState(() {
        var jsonResponse = json.decode(response.body);
        summaryData = jsonResponse;
      });
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    Scaffold.of(context).showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  @override
  void initState() {
    this.getSummary();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  _showCashierAuthenticationDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Authentication'),
            content: SingleChildScrollView(
              child: SafeArea(
                  minimum: const EdgeInsets.all(16.0),
                  bottom: false,
                  top: false,
                  child: Form(
                      key: _authenticationFormKey,
                      autovalidate: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            controller: _usernameFieldController,
                            decoration: InputDecoration(hintText: "Username"),
                            validator: (val) =>
                                val.isEmpty ? 'Username is required' : null,
                          ),
                          TextFormField(
                            controller: _passwordFieldController,
                            decoration: InputDecoration(
                                hintText: "Password",
                                suffixIcon: IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      _obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                    onPressed: () {
                                      // Update the state i.e. toogle the state of passwordVisible variable
                                      _toggle();
                                    })),
                            obscureText: _obscureText,
                            validator: (val) =>
                                val.isEmpty ? 'Password is required' : null,
                          )
                        ],
                      ))),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Authenticate'),
                onPressed: () {
                  authenticateUser(context);
                },
              )
            ],
          );
        });
  }

  _showCashierClosureConfirmDialog(BuildContext context) async {
    int keys = closedProducts.keys.length;
    if (keys < productsCount) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Cashier closure'),
              content: SingleChildScrollView(
                child: SafeArea(
                    minimum: const EdgeInsets.all(1.0),
                    bottom: false,
                    top: false,
                    child: Text(
                        "You have not selected all items. Are you sure you want to continue?")),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('YES AM SURE'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showCashierAuthenticationDialog(context);
                  },
                )
              ],
            );
          });
    } else {
      _showCashierAuthenticationDialog(context);
    }
  }

  bool _isPositiveNumber(String str) {
    if (str == null) {
      return false;
    }

    double number = double.tryParse(str);
    if (number != null && number >= 0) {
      return true;
    } else {
      return false;
    }
  }

  _showCashCollectedDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Cash collected'),
            content: SingleChildScrollView(
              child: SafeArea(
                  minimum: const EdgeInsets.all(16.0),
                  bottom: false,
                  top: false,
                  child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            controller: _amountFieldController,
                            decoration:
                                InputDecoration(hintText: "Cash collected"),
                            keyboardType: TextInputType.number,
                            validator: (val) => val.isEmpty
                                ? 'Cash collected is required'
                                : null,
                          ),
                        ],
                      ))),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('OKAY'),
                onPressed: () {
                  final formatCurrency = NumberFormat("#,##0.00", "en_US");
                  final FormState form = _formKey.currentState;
                  if (!form.validate()) {
                    showMessage('Input not valid!  Please review and correct.');
                  } else {
                    if (!_isPositiveNumber(_amountFieldController.text)) {
                      showMessage('Please input a valid number');
                      return null;
                    }

                    setState(() {
                      try {
                        cashCollected =
                            double.parse(_amountFieldController.text);
                      } catch (e) {
                        cashCollected = 0;
                      }

                      shortages = expectedCashUnformatted - cashCollected;
                      summaryData["collected_cash"] =
                          "MWK ${formatCurrency.format(cashCollected)}";
                      summaryData["shortages"] =
                          "MWK ${formatCurrency.format(shortages)}";
                    });
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: new EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DataTable(columns: [
              DataColumn(
                label: Text("Date"),
                numeric: false,
                tooltip: "Date",
              ),
              DataColumn(
                label: Text(stockDate),
                numeric: false,
                tooltip: "Date",
              ),
            ], rows: [
              DataRow(cells: [
                DataCell(Text("Complementary")),
                DataCell(Text(summaryData["complementary_total"] ?? ""))
              ]),
              DataRow(cells: [
                DataCell(Text("Damages")),
                DataCell(Text(summaryData["damages_total"] ?? ""))
              ]),
              DataRow(cells: [
                DataCell(Text("Total sales")),
                DataCell(Text(summaryData["total_sales"] ?? ""))
              ]),
              DataRow(cells: [
                DataCell(Text("Debtors")),
                DataCell(Text(summaryData["debtors"] ?? ""))
              ]),
              DataRow(cells: [
                DataCell(Text("Expected cash")),
                DataCell(Text(summaryData["expected_cash"] ?? ""))
              ]),
              DataRow(cells: [
                DataCell(Text("Collected cash")),
                DataCell(Text(summaryData["collected_cash"] ?? ""))
              ]),
              DataRow(cells: [
                DataCell(Text("Shortages")),
                DataCell(Text(summaryData["shortages"] ?? ""))
              ])
            ]),
            AnimatedOpacity(
              opacity: !stockCardAvailable ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: ButtonTheme.bar(
                child: new ButtonBar(
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('Cashier closure'),
                      onPressed: () {
                        if (cashCollected == 0) {
                          return showMessage(
                              'Update cash collected first to continue');
                        }

                        _showCashierClosureConfirmDialog(context);
                      },
                    ),
                    new FlatButton(
                      child: const Text('Update cash collected'),
                      onPressed: () {
                        _showCashCollectedDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//*********************************************************

class NewPricePage extends StatefulWidget {
  final String productID;
  final String productName;

  const NewPricePage({Key key, this.productID, this.productName})
      : super(key: key);

  @override
  _NewPricePageState createState() => _NewPricePageState();
}

class _NewPricePageState extends State<NewPricePage> {
  void _submitForm() {
    final FormState form = _formKey.currentState;
    selectedProductID = widget.productID;
    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save(); //This invokes each onSaved event

      var priceHistoryService = new PriceHistoryService();
      priceHistoryService.createPriceHistory(newPriceHistory).then((value) {
        if (value.errors != null && value.errors.length > 0) {
          showMessage('Errors:\n ${value.errors.join('\n')}', Colors.red);
        } else {
          showMessage('${value.price} was successfully created', Colors.blue);
          form.reset();
          _controller.text = '';
        }
      });
    }
  }

  @override
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PriceHistory newPriceHistory = new PriceHistory();

  final TextEditingController _controller = new TextEditingController();

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var lastDate = now.add(new Duration(days: 30));

    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: lastDate);

    if (result == null) return;

    setState(() {
      _controller.text = new DateFormat.yMd().format(result);
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('New price of ' + widget.productName),
      ),
      body: SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: <Widget>[
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.arrow_forward_ios),
                          hintText: 'Price',
                          labelText: 'Price',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'Price is required' : null,
                        onSaved: (val) => newPriceHistory.price = val),
                    new Row(children: <Widget>[
                      new Expanded(
                          child: new TextFormField(
                        decoration: new InputDecoration(
                          icon: const Icon(Icons.calendar_today),
                          hintText: 'Start date',
                          labelText: 'Start date',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'Start date is required' : null,
                        controller: _controller,
                        onSaved: (val) => newPriceHistory.start_date = val,
                        keyboardType: TextInputType.datetime,
                      )),
                      new IconButton(
                        icon: new Icon(Icons.more_horiz),
                        tooltip: 'Choose date',
                        onPressed: (() {
                          _chooseDate(context, _controller.text);
                        }),
                      )
                    ]),
                    new Container(
                        padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                        child: new RaisedButton(
                          child: const Text('Create Price'),
                          onPressed: () {
                            _submitForm();
                          },
                        ))
                  ]))),
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
  bool isLoading = true;

  Future<String> getPriceHistory() async {
    var response = await http.get(
        Uri.encodeFull('${priceHistoryUrl}?product_id=${widget.productID}'),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      isLoading = false;
      data = jsonResponse;
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
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              ListView.builder(
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (BuildContext context, i) {
                    return Card(
                      child: ListTile(
                        title: Text(data[i]["start_date"] +
                            ' - ' +
                            data[i]["end_date"]),
                        subtitle: Text('Price: ${data[i]["price"]}'),
                        isThreeLine: true,
                      ),
                    );
                  }),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Debtor {
  String name;
  String amountOwed;
  String stockDate;
  String phoneNumber;
  String description;
  var errors = [];
}

class DebtorService {
  static final _headers = {'Content-Type': 'application/json'};

  Future<Debtor> createDebtor(Debtor debtor) async {
    String json = _toJson(debtor);
    final response =
        await http.post(addDebtorsURL, headers: _headers, body: json);
    var serverResponse = _fromJson(response.body);

    return serverResponse;
  }

  Debtor _fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    var debtor = new Debtor();
    if (map['errors'] != null && map["errors"].length > 0) {
      debtor.errors = map['errors'];
    } else {
      debtor.name = map['name'];
      debtor.amountOwed = map['amount_owed'];
      debtor.stockDate = map['date'];
      debtor.phoneNumber = map['phone_number'];
      debtor.description = map['description'];
    }
    return debtor;
  }

  String _toJson(Debtor debtor) {
    var mapData = new Map();
    mapData["name"] = debtor.name;
    mapData["amount"] = debtor.amountOwed;
    mapData["phone_number"] = debtor.phoneNumber;
    mapData["date"] = debtor.stockDate;
    mapData["description"] = debtor.description;

    String json = jsonEncode(mapData);
    return json;
  }
}

class Setting {
  String value;
  var errors = [];
}

class SettingService {
  static final _headers = {'Content-Type': 'application/json'};

  Future<Setting> createSetting(Setting setting) async {
    String json = _toJson(setting);
    final response = await http.post(
        updateSettingsURL + '?property=debt.payment.period',
        headers: _headers,
        body: json);
    var serverResponse = _fromJson(response.body);

    return serverResponse;
  }

  Setting _fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    var setting = new Setting();
    if (map['errors'] != null && map["errors"].length > 0) {
      setting.errors = map['errors'];
    } else {
      setting.value = map['value'];
    }
    return setting;
  }

  String _toJson(Setting setting) {
    var mapData = new Map();
    mapData["value"] = setting.value;
    String json = jsonEncode(mapData);
    return json;
  }
}

class ProductAddition {
  String quantity;
  String productID;
  String stockDate;
  String currentStock;
  var errors = [];
}

class ProductAdditionService {
  static final _headers = {'Content-Type': 'application/json'};

  Future<ProductAddition> createProductAddition(
      ProductAddition productAddition) async {
    String json = _toJson(productAddition);
    final response =
        await http.post(addStockURL, headers: _headers, body: json);
    var serverResponse = _fromJson(response.body);

    return serverResponse;
  }

  ProductAddition _fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    var productAddition = new ProductAddition();
    if (map['errors'] != null && map["errors"].length > 0) {
      productAddition.errors = map['errors'];
    } else {
      productAddition.quantity = map['added_stock'];
      productAddition.productID = map['product_id'];
      productAddition.stockDate = map['stock_date'];
      productAddition.currentStock = map['current_stock'];
    }
    return productAddition;
  }

  String _toJson(ProductAddition productAddition) {
    var mapData = new Map();
    mapData["quantity"] = productAddition.quantity;
    mapData["product_id"] = productAddition.productID;
    mapData["stock_date"] = productAddition.stockDate;

    String json = jsonEncode(mapData);
    return json;
  }
}

class PriceHistory {
  String price_history_id;
  String price = '';
  String start_date = '';
  String end_date;
  var errors = [];
}

var selectedProductID;

class PriceHistoryService {
  static final _headers = {'Content-Type': 'application/json'};

  Future<PriceHistory> createPriceHistory(PriceHistory priceHistory) async {
    String json = _toJson(priceHistory);
    final response = await http.post(
        createPriceUrl + '?product_id=' + selectedProductID,
        headers: _headers,
        body: json);
    var serverResponse = _fromJson(response.body);

    return serverResponse;
  }

  PriceHistory _fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    var priceHistory = new PriceHistory();
    if (map['errors'] != null && map["errors"].length > 0) {
      priceHistory.errors = map['errors'];
    } else {
      priceHistory.price = map['price'];
      priceHistory.start_date = map['start_date'];
      priceHistory.end_date = map['end_date'];
    }
    return priceHistory;
  }

  String _toJson(PriceHistory priceHistory) {
    var mapData = new Map();
    mapData["price"] = priceHistory.price;
    mapData["start_date"] = priceHistory.start_date;
    mapData["end_date"] = priceHistory.end_date;

    String json = jsonEncode(mapData);
    return json;
  }
}

class UserAccount {
  String username = '';
  String firstName = '';
  String lastName = '';
  String phoneNumber;
  String email = '';
  String password = '';
  String role = '';
  var errors = [];
}

class UserAccountService {
  static final _headers = {'Content-Type': 'application/json'};

  Future<UserAccount> createUserAccount(UserAccount user) async {
    String json = _toJson(user);
    final response = await http.post(newUserURL, headers: _headers, body: json);
    var serverResponse = _fromJson(response.body);

    return serverResponse;
  }

  UserAccount _fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    var user = new UserAccount();
    if (map['errors'] != null && map["errors"].length > 0) {
      user.errors = map['errors'];
    } else {
      user.username = map['username'];
      user.firstName = map['first_name'];
      user.lastName = map['last_name'];
      user.phoneNumber = map['phone_number'];
      user.email = map['email'];
      user.role = map['role'];
    }
    return user;
  }

  String _toJson(UserAccount user) {
    var mapData = new Map();
    mapData["username"] = user.username;
    mapData["first_name"] = user.firstName;
    mapData["last_name"] = user.lastName;
    mapData["phone_number"] = user.phoneNumber;
    mapData["email"] = user.email;
    mapData["role"] = user.role;
    mapData["password"] = user.password;
    String json = jsonEncode(mapData);
    return json;
  }
}

class Product {
  String name;
  var category = '';
  String part_number = '';
  String label = '';
  String starting_inventory;
  String minimum_required = '';
  var errors = [];
}

class ProductService {
  static final _headers = {'Content-Type': 'application/json'};

  Future<Product> createProduct(Product product) async {
    String json = _toJson(product);
    final response =
        await http.post(createProductUrl, headers: _headers, body: json);
    var serverResponse = _fromJson(response.body);

    return serverResponse;
  }

  Product _fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    var product = new Product();
    if (map['errors'] != null && map["errors"].length > 0) {
      product.errors = map['errors'];
    } else {
      product.name = map['name'];
      product.category = map['category'];
      product.part_number = map['part_number'];
      product.label = map['label'];
      product.starting_inventory = map['starting_inventory'];
      product.minimum_required = map['minimum_required'];
    }
    return product;
  }

  String _toJson(Product product) {
    var mapData = new Map();
    mapData["name"] = product.name;
    mapData["category"] = product.category;
    mapData["part_number"] = product.part_number;
    mapData["label"] = product.label;
    mapData["starting_inventory"] = product.starting_inventory;
    mapData["minimum_required"] = product.minimum_required;
    String json = jsonEncode(mapData);
    return json;
  }
}

class NewProductPage extends StatefulWidget {
  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  void _submitForm() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save(); //This invokes each onSaved event

      var productService = new ProductService();
      productService.createProduct(newProduct).then((value) {
        if (value.errors != null && value.errors.length > 0) {
          showMessage('Errors:\n ${value.errors.join('\n')}', Colors.red);
        } else {
          showMessage('${value.name} was successfully created', Colors.blue);
          form.reset();
        }
      });
    }
  }

  @override
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> _productCategories = <String>['', 'Standard', 'Non standard'];
  String _productCategory = '';
  Product newProduct = new Product();

  final TextEditingController _controller = new TextEditingController();

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now());

    if (result == null) return;

    setState(() {
      _controller.text = new DateFormat.yMd().format(result);
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('New product'),
      ),
      body: SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: <Widget>[
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.arrow_forward_ios),
                          hintText: 'Product name',
                          labelText: 'Name',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'Name is required' : null,
                        onSaved: (val) => newProduct.name = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.arrow_forward_ios),
                          hintText: 'Part number',
                          labelText: 'Part number',
                        ),
                        onSaved: (val) => newProduct.part_number = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.arrow_forward_ios),
                          hintText: 'Product label',
                          labelText: 'Product label',
                        ),
                        onSaved: (val) => newProduct.label = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.arrow_forward_ios),
                          hintText: 'Starting stock',
                          labelText: 'Starting stock',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'Starting stock is required' : null,
                        onSaved: (val) => newProduct.starting_inventory = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.arrow_forward_ios),
                          hintText: 'Minimum required',
                          labelText: 'Minimum required',
                        ),
                        onSaved: (val) => newProduct.minimum_required = val),
                    new FormField(builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.arrow_forward_ios),
                          labelText: 'Select product category',
                        ),
                        isEmpty: _productCategory == '',
                        child: new DropdownButtonHideUnderline(
                          child: new DropdownButton(
                            value: _productCategory,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                newProduct.category = newValue;
                                _productCategory = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _productCategories.map((String value) {
                              return new DropdownMenuItem(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }, validator: (val) {
                      return val != '' ? null : 'Please select category';
                    }),
                    new Container(
                        padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                        child: new RaisedButton(
                          child: const Text('Create Product'),
                          onPressed: () {
                            _submitForm();
                          },
                        ))
                  ]))),
    );
  }
}

class NewUserAccountPage extends StatefulWidget {
  @override
  _NewUserAccountPageState createState() => _NewUserAccountPageState();
}

class _NewUserAccountPageState extends State<NewUserAccountPage> {
  @override
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final passwordFieldController = new TextEditingController();
  final passwordConfirmFieldControllerController = new TextEditingController();
  List<String> _roles = <String>['', 'Admin', 'Staff'];
  String _role = '';
  UserAccount user = new UserAccount();

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void _submitForm() {
    if (_role.length == 0) {
      showMessage('Form is not valid!  Please review and correct.');
      return null;
    }

    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save(); //This invokes each onSaved event
      bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(user.email);

      if (!emailValid) {
        showMessage('The email entered is not valid', Colors.orange);
        return null;
      }

      if (user.password != passwordConfirmFieldControllerController.text) {
        showMessage('Confirm password is not equal to password', Colors.orange);
        return null;
      }

      var userAccountService = new UserAccountService();
      userAccountService.createUserAccount(user).then((value) {
        if (value.errors != null && value.errors.length > 0) {
          showMessage('Errors:\n ${value.errors.join('\n')}', Colors.red);
        } else {
          showMessage(
              '${value.username} was successfully created', Colors.blue);
          form.reset();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('New user account'),
      ),
      body: SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: <Widget>[
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.info),
                          hintText: 'Username',
                          labelText: 'Username',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'Username is required' : null,
                        onSaved: (val) => user.username = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.info),
                          hintText: 'Email',
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) =>
                            val.isEmpty ? 'Email is required' : null,
                        onSaved: (val) => user.email = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.info),
                          hintText: 'First name',
                          labelText: 'First name',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'First name is required' : null,
                        onSaved: (val) => user.firstName = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.info),
                          hintText: 'Last name',
                          labelText: 'Last name',
                        ),
                        onSaved: (val) => user.lastName = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.info),
                          hintText: 'Phone #',
                          labelText: 'Phone #',
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (val) => user.phoneNumber = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.info),
                          hintText: 'Password',
                          labelText: 'Password',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'Password is required' : null,
                        onSaved: (val) => user.password = val),
                    new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.info),
                          hintText: 'Confirm password',
                          labelText: 'Confirm password',
                        ),
                        controller: passwordConfirmFieldControllerController,
                        validator: (val) => val.isEmpty
                            ? 'Confirm password is required'
                            : null),
                    new FormField(builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.info),
                          labelText: 'Select role',
                        ),
                        isEmpty: _role == '',
                        child: new DropdownButtonHideUnderline(
                          child: new DropdownButton(
                            value: _role,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                user.role = newValue;
                                _role = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _roles.map((String value) {
                              return new DropdownMenuItem(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }, validator: (val) {
                      return val != '' ? null : 'Please select role';
                    }),
                    new Container(
                        padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                        child: new RaisedButton(
                          child: const Text('Submit'),
                          onPressed: () {
                            _submitForm();
                          },
                        ))
                  ]))),
    );
  }
}

class PricingMainPage extends StatefulWidget {
  @override
  _PricingMainPageState createState() => _PricingMainPageState();
}

class _PricingMainPageState extends State<PricingMainPage> {
  GlobalKey key = new GlobalKey();
  bool isLoading = true;

  List data;

  Future<String> getPricesList() async {
    var response = await http.get(Uri.encodeFull(productsPricesUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
      isLoading = false;
    });
  }

  @override
  void initState() {
    this.getPricesList();
  }

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
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              ListView.builder(
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
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductsMainPage extends StatefulWidget {
  @override
  _ProductsMainPageState createState() => _ProductsMainPageState();
}

class _ProductsMainPageState extends State<ProductsMainPage> {
  List data;
  bool isLoading = true;

  Future<String> getProductsList() async {
    var response = await http.get(Uri.encodeFull(productsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      isLoading = false;
      data = jsonResponse;
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
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              ListView.builder(
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (BuildContext context, i) {
                    return Card(
                      child: ListTile(
                        title: Text(data[i]["product_name"]),
                        subtitle: Text(
                            'Minimum required: ${data[i]["minimum_required"]} | Current stock: ${data[i]["current_stock"]}'),
                        isThreeLine: true,
                      ),
                    );
                  }),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
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
  final TextEditingController _controller = new TextEditingController();

  //var date = "2019-07-09"; //9 july 2019
  String date =
      DateTime.now().subtract(new Duration(days: 1)).toIso8601String();
  String datePickerFormat;

  Map data = {};

  Future<String> getReports() async {
    try {
      date = DateFormat("yyyy-MM-dd").format(DateTime.parse(date));
    } catch (e) {}

    var response = await http.get(Uri.encodeFull(reportsUrl + "?date=" + date),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now());

    if (result == null) return;

    setState(() {
      date = new DateFormat("yyyy-MM-dd").format(result);
      try {
        datePickerFormat =
            DateFormat("MM/dd/yyyy").format(DateTime.parse(date));
      } catch (e) {}
      resetVariables();
      getReports();
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  void resetVariables() {
    data["complementary_total"] = "Please wait";
    data["damages_total"] = "Please wait";
    data["total_sales"] = "Please wait";
    data["debtors"] = "Please wait";
    data["expected_cash"] = "Please wait";
    data["collected_cash"] = "Please wait";
    data["shortages"] = "Please wait";
  }

  @override
  void initState() {
    resetVariables();
    try {
      datePickerFormat = DateFormat("MM/dd/yyyy").format(DateTime.parse(date));
    } catch (e) {}
    this.getReports();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Reports'),
        ),
        body: SizedBox.expand(
            child: DataTable(columns: [
          DataColumn(
            label: Text("Date"),
            numeric: false,
            tooltip: "Date",
          ),
          DataColumn(
            label: Text(date),
            numeric: false,
            tooltip: "Date",
          ),
        ], rows: [
          DataRow(cells: [
            DataCell(Text("Complementary")),
            DataCell(Text(data["complementary_total"]))
          ]),
          DataRow(cells: [
            DataCell(Text("Damages")),
            DataCell(Text(data["damages_total"]))
          ]),
          DataRow(cells: [
            DataCell(Text("Total sales")),
            DataCell(Text(data["total_sales"]))
          ]),
          DataRow(cells: [
            DataCell(Text("Debtors")),
            DataCell(Text(data["debtors"]))
          ]),
          DataRow(cells: [
            DataCell(Text("Expected cash")),
            DataCell(Text(data["expected_cash"]))
          ]),
          DataRow(cells: [
            DataCell(Text("Collected cash")),
            DataCell(Text(data["collected_cash"]))
          ]),
          DataRow(cells: [
            DataCell(Text("Shortages")),
            DataCell(Text(data["shortages"]))
          ])
        ])),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
            _chooseDate(context, datePickerFormat);
          },
          child: Icon(Icons.calendar_today),
          backgroundColor: Colors.blue,
        ));
  }
}

class SettingsMainPage extends StatefulWidget {
  @override
  _SettingsMainPageState createState() => _SettingsMainPageState();
}

class _SettingsMainPageState extends State<SettingsMainPage> {
  Map data = {};
  TextEditingController _textFieldController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<String> getDebtPaymentPeriod() async {
    var response = await http.get(Uri.encodeFull(debtPaymentPropertyURL),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void _updateSettings() {
    var setting = Setting();
    setting.value = _textFieldController.text;
    if (_textFieldController.text.length == 0) {
      Navigator.of(context).pop();
      showMessage('Input value to continue', Colors.red);
      return;
    }

    var settingsService = new SettingService();

    settingsService.createSetting(setting).then((value) {
      if (value.errors != null && value.errors.length > 0) {
      } else {
        setState(() {
          data["days"] = value.value;
          _textFieldController.text = "";
          Navigator.of(context).pop();
          showMessage('Settings updated', Colors.blue);
        });
      }
    });
  }

  @override
  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Debt payment period'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Days"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Update'),
                onPressed: () {
                  _updateSettings();
                },
              )
            ],
          );
        });
  }

  void initState() {
    data["days"] = "?";
    this.getDebtPaymentPeriod();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 10.0),
          //color: Colors.blueGrey[500],
          child: SizedBox.expand(
              child: DataTable(columns: [
            DataColumn(
              label: Text("Property"),
              numeric: false,
              tooltip: "Property",
            ),
            DataColumn(
              label: Text("value"),
              numeric: false,
              tooltip: "Value",
            ),
          ], rows: [
            DataRow(cells: [
              DataCell(Text("Debt payment period")),
              DataCell(Text(data["days"] + " days"))
            ]),
          ])),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here!
            _displayDialog(context);
          },
          child: Icon(Icons.edit),
          backgroundColor: Colors.blue,
        ));
  }
}

class DebtorsPaymentPage extends StatefulWidget {
  @override
  _DebtorsPaymentPageState createState() => _DebtorsPaymentPageState();
}

class _DebtorsPaymentPageState extends State<DebtorsPaymentPage> {
  List data;
  bool isLoading = true;

  Future<String> getDebtorsPaymentList() async {
    var response = await http.get(Uri.encodeFull(debtorPaymentsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      isLoading = false;
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  Future<String> searchDebtorsPayment() async {
    var response = await http.get(
        Uri.encodeFull(searchDebtorPaymentsUrl + "?name=" + _filter.text),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Debtors payment');
  final TextEditingController _filter = new TextEditingController();

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          autofocus: true,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search debtors...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Debtors payment');
        _filter.clear();
      }
    });
  }

  @override
  void initState() {
    this.getDebtorsPaymentList();
    _filter.addListener(searchDebtorsPayment);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: () {
              _searchPressed();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              new Container(
                  child: ListView.builder(
                      itemCount: data == null ? 0 : data.length,
                      itemBuilder: (BuildContext context, i) {
                        return Card(
                          child: ListTile(
                            title: Text(data[i]["amount_paid"]),
                            subtitle: Text(
                                'Debtor: ${data[i]["debtor"]} | Amount owed: ${data[i]["amount_owed"]} | Date paid: ${data[i]["date_paid"]} | Date owed: ${data[i]["date_owed"]}'),
                            isThreeLine: true,
                          ),
                        );
                      })),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverdueDebtorsPage extends StatefulWidget {
  @override
  _OverdueDebtorsPageState createState() => _OverdueDebtorsPageState();
}

class _OverdueDebtorsPageState extends State<OverdueDebtorsPage> {
  List data;
  bool isLoading = true;

  Future<String> getOverdueDebtorsList() async {
    var response = await http.get(Uri.encodeFull(overdueDebtorsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      isLoading = false;
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  Future<String> searchOverdueDebtors() async {
    var response = await http.get(
        Uri.encodeFull(searchOverdueDebtorsUrl + "?name=" + _filter.text),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Overdue debtors');
  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    this.getOverdueDebtorsList();
    _filter.addListener(searchOverdueDebtors);
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          autofocus: true,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search debtors...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Overdue debtors');
        _filter.clear();
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: () {
              _searchPressed();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              new Container(
                  child: ListView.builder(
                      itemCount: data == null ? 0 : data.length,
                      itemBuilder: (BuildContext context, i) {
                        return Card(
                          child: ListTile(
                            title: Text(data[i]["name"]),
                            subtitle: Text(
                                'Amount owed: ${data[i]["amount_owed"]} | Date: ${data[i]["date"]} | Amount paid: ${data[i]["amount_paid"]} | Balance: ${data[i]["balance_due"]} | Phone #: ${data[i]["phone_number"]} | Days gone #: ${data[i]["days_gone"]}'),
                            isThreeLine: true,
                          ),
                        );
                      })),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DebtorsPage extends StatefulWidget {
  @override
  _DebtorsPageState createState() => _DebtorsPageState();
}

class _DebtorsPageState extends State<DebtorsPage> {
  List data;
  bool isLoading = true;

  Future<String> getDebtorsList() async {
    var response = await http.get(Uri.encodeFull(debtorsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      isLoading = false;
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  Future<String> searchDebtors() async {
    var response = await http.get(
        Uri.encodeFull(searchDebtorsUrl + "?name=" + _filter.text),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      data = jsonResponse;
    });
  }

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Debtors');
  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    this.getDebtorsList();
    _filter.addListener(searchDebtors);
  }

  void showMenuSelection(String value) {
    if (value.contains('debtor_payment')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DebtorsPaymentPage()),
      );
    }

    if (value.contains('overdue_debtors')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OverdueDebtorsPage()),
      );
    }
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _filter,
          autofocus: true,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search debtors...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Debtors');
        _filter.clear();
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: () {
              _searchPressed();
            },
          ),
          PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              onSelected: showMenuSelection,
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                      value: 'debtor_payment',
                      child: const Text('Debtor payments'),
                    ),
                    PopupMenuItem<String>(
                      value: 'overdue_debtors',
                      child: const Text('Overdue debtors'),
                    )
                  ])
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              new Container(
                  child: ListView.builder(
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
                      })),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DamagesPage extends StatefulWidget {
  @override
  _DamagesPageState createState() => _DamagesPageState();
}

class _DamagesPageState extends State<DamagesPage> {
  List data;
  bool isLoading = true;

  Future<String> getDamagesList() async {
    var response = await http.get(Uri.encodeFull(damagesUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      isLoading = false;
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
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              new Container(
                  child: ListView.builder(
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
                      })),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComplementaryPage extends StatefulWidget {
  @override
  _ComplementaryPageState createState() => _ComplementaryPageState();
}

class _ComplementaryPageState extends State<ComplementaryPage> {
  List data;
  bool isLoading = true;

  Future<String> getComplementaryList() async {
    var response = await http.get(Uri.encodeFull(complementaryUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      isLoading = false;
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
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              new Container(
                  child: ListView.builder(
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
                      })),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserAccountsPage extends StatefulWidget {
  @override
  _UserAccountsPageState createState() => _UserAccountsPageState();
}

class _UserAccountsPageState extends State<UserAccountsPage> {
  List data;
  bool isLoading = true;

  Future<String> getUserAccountList() async {
    var response = await http.get(Uri.encodeFull(userAccountsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      isLoading = false;
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewUserAccountPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              ListView.builder(
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (BuildContext context, i) {
                    return Card(
                      child: ListTile(
                        title: Text(
                            '${data[i]["first_name"]} ${data[i]["last_name"]}'),
                        subtitle: Text(
                            'Username: ${data[i]["username"]} | E-mail: ${data[i]["email"]} | Role: ${data[i]["role"]} | Phone # : ${data[i]["phone_number"]}'),
                        isThreeLine: true,
                      ),
                    );
                  }),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
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
  List data;
  bool isLoading = true;

  Future<String> getProductsRunningOutOfStockList() async {
    var response = await http.get(Uri.encodeFull(productsRunningOutOfStockUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      isLoading = false;
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
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              new Container(
                  child: ListView.builder(
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
                      })),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductsOutOfStockPage extends StatefulWidget {
  @override
  _ProductsOutOfStockPageState createState() => _ProductsOutOfStockPageState();
}

class _ProductsOutOfStockPageState extends State<ProductsOutOfStockPage> {
  List data;
  bool isLoading = true;

  Future<String> getProductsOutOfStockList() async {
    var response = await http.get(Uri.encodeFull(productsOutOfStockUrl),
        headers: {"Accept": "application/json"});

    setState(() {
      isLoading = false;
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
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.blueGrey[500],
        child: Container(
          child: new Stack(
            children: <Widget>[
              new Container(
                  child: ListView.builder(
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
                      })),
              AnimatedOpacity(
                opacity: (isLoading == true) ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Map currentUser;

String firstName;
String lastName;
String email;

var notificationID = 1;

class _MyHomePageState extends State<MyHomePage> {
  static const methodChannel = const MethodChannel('com.webtechmw');
  final prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List debtorsList = [];
  List damagesList = [];
  List complementaryList = [];
  List userAccountsList = [];
  List productsRunningOutOfStockList = [];
  List productsOutOfStockList = [];

  bool isDebtorsLoading = true;
  bool isDamagesLoading = true;
  bool isComplementaryLoading = true;
  bool isUserAccountsLoading = true;
  bool isProductsRunningOutOfStockLoading = true;
  bool isProductsOutOfStockLoading = true;

  _MyHomePageState() {
    methodChannel.setMethodCallHandler((call) {
      _showNotificationWithDefaultSound();
    });
  }

  Future<String> checkIfUserIsAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('user') ?? null;
    if (user != null) {
      setState(() {
        currentUser = jsonDecode(user);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<String> getDebtors() async {
    var response = await http.get(Uri.encodeFull(debtorsUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    setState(() {
      isDebtorsLoading = false;
      debtorsList = jsonResponse;
    });
  }

  Future<String> getDamages() async {
    var response = await http.get(Uri.encodeFull(damagesUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    setState(() {
      isDamagesLoading = false;
      damagesList = jsonResponse;
    });
  }

  Future<String> getComplementary() async {
    var response = await http.get(Uri.encodeFull(complementaryUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    setState(() {
      isComplementaryLoading = false;
      complementaryList = jsonResponse;
    });
  }

  Future<dynamic> getUserAccounts() async {
    var response = await http.get(Uri.encodeFull(userAccountsUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    setState(() {
      isUserAccountsLoading = false;
      userAccountsList = jsonResponse;
    });
  }

  Future<dynamic> getProductsRunningOutOfStock() async {
    var response = await http.get(Uri.encodeFull(productsRunningOutOfStockUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    setState(() {
      isProductsRunningOutOfStockLoading = false;
      productsRunningOutOfStockList = jsonResponse;
    });
  }

  Future<dynamic> getProductsOutOfStock() async {
    var response = await http.get(Uri.encodeFull(productsOutOfStockUrl),
        headers: {"Accept": "application/json"});
    var jsonResponse = json.decode(response.body);
    setState(() {
      isProductsOutOfStockLoading = false;
      productsOutOfStockList = jsonResponse;
    });
  }

  Future<String> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void initState() {
    this.checkIfUserIsAuthenticated();
    try {
      firstName = currentUser['first_name'];
      lastName = currentUser['last_name'];
      email = currentUser['email'];
    } catch (e) {}

    this.getDebtors();
    this.getDamages();
    this.getComplementary();
    this.getUserAccounts();
    this.getProductsRunningOutOfStock();
    this.getProductsOutOfStock();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String position) async {
    int pos = int.parse(position);
    String today = DateFormat("yyyy-MM-dd")
        .format(DateTime.parse(DateTime.now().toIso8601String()));

    final prefs = await SharedPreferences.getInstance();
    final payments = prefs.getString('payments') ?? null;
    var debtorPaymentID = debtorPaymentsOnDateData[pos]["debtor_payment_id"];
    if (payments == null) {
      Map seenPayments = {};
      seenPayments[today] = [];
      seenPayments[today].add(debtorPaymentID);
      String seenPaymentsString = json.encode(seenPayments);
      prefs.setString("payments", seenPaymentsString);
    } else {
      var seenPayments = jsonDecode(payments);
      if (seenPayments[today] == null) {
        seenPayments[today] = [];
        seenPayments[today].add(debtorPaymentID);
      } else {
        seenPayments[today].add(debtorPaymentID);
      }
      String seenPaymentsString = json.encode(seenPayments);
      prefs.setString("payments", seenPaymentsString);
    }

    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("Details"),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text("Debtor : " + debtorPaymentsOnDateData[pos]["debtor"]),
                Text("Amount paid : " +
                    debtorPaymentsOnDateData[pos]["amount_paid"]),
                Text("Balance due : " +
                    debtorPaymentsOnDateData[pos]["balance_due"]),
                Text("Amount owed : " +
                    debtorPaymentsOnDateData[pos]["amount_owed"]),
                Text("Date owed : " +
                    debtorPaymentsOnDateData[pos]["date_owed"]),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> debtorPaymentNotification(List debtorPayments) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    final prefs = await SharedPreferences.getInstance();
    final payments = prefs.getString('payments') ?? null;
    String today = DateFormat("yyyy-MM-dd")
        .format(DateTime.parse(DateTime.now().toIso8601String()));

    if (debtorPayments.length > 0) {
      int position = debtorPayments.length - 1;
      var payment = debtorPayments.removeLast();
      var debtorPaymentID = payment["debtor_payment_id"];
      var debtor = payment["debtor"];
      var balanceDue = payment["balance_due"];
      var amountPaid = payment["amount_paid"];
      var amountOwed = payment["amount_owed"];
      var datePaid = payment["date_paid"];
      var dateOwed = payment["date_owed"];
      bool isSeen = false;

      if (payments != null) {
        var seenPayments = jsonDecode(payments);
        if (seenPayments[today] != null) {
          if (seenPayments[today].contains(debtorPaymentID)) {
            isSeen = true;
          }
        }
      }

      if (!isSeen) {
        await flutterLocalNotificationsPlugin.show(
          debtorPaymentID,
          "Debt payment",
          "$debtor has paid $amountPaid Balance due: $balanceDue Amount owed: $amountOwed Date owed: $dateOwed",
          platformChannelSpecifics,
          payload: position.toString(),
        );
      }

      debtorPaymentNotification(debtorPayments);
    }
  }

  List debtorPaymentsOnDateData;

  Future _showNotificationWithDefaultSound() async {
    var response = await http.get(
        Uri.encodeFull(
            debtorPaymentsOnDateURL + "?date=" + new DateTime.now().toString()),
        headers: {"Accept": "application/json"});

    debtorPaymentsOnDateData = json.decode(response.body);
    var debtorPaymentsOnDate = json.decode(response.body);
    debtorPaymentNotification(debtorPaymentsOnDate);
  }

  void refreshPage() {
    showMessage("Refreshing.....", Colors.orange);
    setState(() {
      isDebtorsLoading = true;
      isDamagesLoading = true;
      isComplementaryLoading = true;
      isUserAccountsLoading = true;
      isProductsRunningOutOfStockLoading = true;
      isProductsOutOfStockLoading = true;
    });

    getDebtors();
    getDamages();
    getComplementary();
    getUserAccounts();
    getProductsRunningOutOfStock();
    getProductsOutOfStock();
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  void showMenuSelection(String value) {
    if (value == 'graph') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SalesGraph()),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Mahara Wipha Bar"),
        actions: <Widget>[
          PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              onSelected: showMenuSelection,
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                      value: 'graph',
                      child: const Text('Sales graph'),
                    ),
                  ])
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          refreshPage();
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue,
      ),
      body: WillPopScope(
          child: GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(16.0),
            childAspectRatio: 8.0 / 9.0,
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
                              AnimatedOpacity(
                                opacity:
                                    (isDebtorsLoading == false) ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 100),
                                child: Text("${debtorsList.length}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              AnimatedOpacity(
                                opacity: (isDebtorsLoading == true) ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 100),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
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
                                AnimatedOpacity(
                                  opacity:
                                      (isDamagesLoading == false) ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Text("${damagesList.length}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                AnimatedOpacity(
                                  opacity:
                                      (isDamagesLoading == true) ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Center(
                                      child: CircularProgressIndicator()),
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
                              builder: (context) => DamagesPage()),
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
                                AnimatedOpacity(
                                  opacity: (isComplementaryLoading == false)
                                      ? 1.0
                                      : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Text("${complementaryList.length}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                AnimatedOpacity(
                                  opacity: (isComplementaryLoading == true)
                                      ? 1.0
                                      : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Center(
                                      child: CircularProgressIndicator()),
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
                                AnimatedOpacity(
                                  opacity: (isUserAccountsLoading == false)
                                      ? 1.0
                                      : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Text("${userAccountsList.length}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                AnimatedOpacity(
                                  opacity: (isUserAccountsLoading == true)
                                      ? 1.0
                                      : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Center(
                                      child: CircularProgressIndicator()),
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
                                AnimatedOpacity(
                                  opacity:
                                      (isProductsRunningOutOfStockLoading ==
                                              false)
                                          ? 1.0
                                          : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Text(
                                      "${productsRunningOutOfStockList.length}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                AnimatedOpacity(
                                  opacity:
                                      (isProductsRunningOutOfStockLoading ==
                                              true)
                                          ? 1.0
                                          : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Center(
                                      child: CircularProgressIndicator()),
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
                                AnimatedOpacity(
                                  opacity:
                                      (isProductsOutOfStockLoading == false)
                                          ? 1.0
                                          : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Text(
                                      "${productsOutOfStockList.length}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                AnimatedOpacity(
                                  opacity: (isProductsOutOfStockLoading == true)
                                      ? 1.0
                                      : 0.0,
                                  duration: Duration(milliseconds: 100),
                                  child: Center(
                                      child: CircularProgressIndicator()),
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
          onWillPop: () async {
            Future.value(
                false); //return a `Future` with false value so this route cant be popped or closed.
          }),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text("$firstName $lastName <$email>"),
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
                  MaterialPageRoute(builder: (context) => UserAccountsPage()),
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
                logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// LOGIN STUFF

class LoginPage extends StatefulWidget {
  createState() => LoginState();
}

class LoginState extends State<LoginPage> {
  static final _headers = {'Content-Type': 'application/json'};
  TextEditingController _emailFieldController = TextEditingController();
  TextEditingController _usernameFieldController = TextEditingController();
  TextEditingController _passwordFieldController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;

  Future<String> passwordReminder(BuildContext context) async {
    Map email = {};
    email["email"] = _emailFieldController.text;

    String json = jsonEncode(email);
    bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_emailFieldController.text);

    if (!emailValid) {
      showMessage('Input a valid email to proceed', Colors.orange);
      return null;
    }

    final response =
        await http.post(passwordReminderURL, headers: _headers, body: json);
    _emailFieldController.text = "";
    Navigator.of(context).pop();
    showMessage('Check your email for the new password', Colors.blue);
  }

  Future<String> authenticateUser() async {
    Map userData = {};
    userData["username"] = _usernameFieldController.text;
    userData["password"] = _passwordFieldController.text;
    String json = jsonEncode(userData);
    final prefs = await SharedPreferences.getInstance();

    if (_usernameFieldController.text.length == 0 ||
        _passwordFieldController.text.length == 0) {
      showMessage('Fill all inputs to proceed', Colors.orange);
      return null;
    }

    setState(() {
      isLoading = true;
    });

    final response =
        await http.post(authenticateUserURL, headers: _headers, body: json);
    var jsonResponse = jsonDecode(response.body);
    setState(() {
      isLoading = false;
    });

    if (jsonResponse["status"] == "success") {
      prefs.setString("user", jsonEncode(jsonResponse["user"]));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
      showMessage('Wrong username/password combination');
    }
  }

  _showResetPasswordDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Password reminder'),
            content: TextField(
              controller: _emailFieldController,
              decoration: InputDecoration(hintText: "E-mail"),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('Reset password'),
                onPressed: () {
                  passwordReminder(context);
                },
              )
            ],
          );
        });
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Icon(
          Icons.lock,
          color: Colors.blue,
          size: 50.0,
        ),
      ),
    );

    final email = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: _usernameFieldController,
      decoration: InputDecoration(
        hintText: 'Username',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      controller: _passwordFieldController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          authenticateUser();
        },
        padding: EdgeInsets.all(12),
        color: Colors.blue,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: WillPopScope(
          child: Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 25.0, bottom: 50.0),
                  child: Center(
                    child: new Column(
                      children: <Widget>[
                        Container(
                          height: 128.0,
                          width: 100.0,
                          child: new CircleAvatar(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.blue,
                            radius: 100.0,
                            child: logo,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue,
                              width: 1.0,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: new Text(
                            "Mahara Wipha Bar",
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.0),
                email,
                SizedBox(height: 8.0),
                password,
                SizedBox(height: 24.0),

                Stack(
                  children: <Widget>[
                    AnimatedOpacity(
                      opacity: (isLoading == false) ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[loginButton],
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: (isLoading == true) ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 100),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
                //loginButton,

                new Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                      const EdgeInsets.only(left: 40.0, right: 40.0, top: 10.0),
                  alignment: Alignment.center,
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new FlatButton(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 20.0),
                          color: Colors.transparent,
                          onPressed: () {
                            _showResetPasswordDialog(context);
                          },
                          child: Text(
                            "Forgot your password?",
                            style:
                                TextStyle(color: Colors.blue.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onWillPop: () async {
            Future.value(
                false); //return a `Future` with false value so this route cant be popped or closed.
          }),
    );
  }
}

//charts

class SalesGraph extends StatefulWidget {
  @override
  _SalesGraphState createState() => _SalesGraphState();
}

class _SalesGraphState extends State<SalesGraph> {
  final mockedData = [
    new TimeSeriesSales(new DateTime(2017, 9, 1), 5),
    new TimeSeriesSales(new DateTime(2017, 9, 2), 25),
    new TimeSeriesSales(new DateTime(2017, 9, 3), 100),
    new TimeSeriesSales(new DateTime(2017, 9, 4), 75),
    new TimeSeriesSales(new DateTime(2017, 9, 5), 200),
    new TimeSeriesSales(new DateTime(2017, 9, 6), 208),
    new TimeSeriesSales(new DateTime(2017, 9, 7), 80),
    new TimeSeriesSales(new DateTime(2017, 9, 8), 89),
    new TimeSeriesSales(new DateTime(2017, 9, 9), 75),
    new TimeSeriesSales(new DateTime(2017, 9, 10), 76),
    new TimeSeriesSales(new DateTime(2017, 9, 11), 43),
    new TimeSeriesSales(new DateTime(2017, 9, 12), 32),
    new TimeSeriesSales(new DateTime(2017, 9, 13), 89),
    new TimeSeriesSales(new DateTime(2017, 9, 14), 98),
    new TimeSeriesSales(new DateTime(2017, 9, 15), 93),
  ];

  /*
  List<TimeSeriesPrice> data = [];
// populate data with a list of dates and prices from the json
for (Map m in dataJSON) {
  data.add(TimeSeriesPrice(m['date'], m['price']);
}
  * */

  /// Create one series with pass in data.
  List<charts.Series<TimeSeriesSales, DateTime>> mapChartData(
      List<TimeSeriesSales> data) {
    return [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.indigo.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  Future showMonthAndYearPicker(BuildContext context) async {
    var now = new DateTime.now();
    var result = await showMonthPicker(context: context, initialDate: now);
    if (result == null) return;
    var date = DateFormat("yyyy-MM-dd")
        .format(DateTime.parse(result.toIso8601String()));
    print(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly sales"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              //_chooseDate(context, _controller.text);
              showMonthAndYearPicker(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SimpleBarChart(mapChartData(mockedData)),
      ),
    );
  }
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate = true});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(seriesList,
        animate: animate, dateTimeFactory: const charts.LocalDateTimeFactory());
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
