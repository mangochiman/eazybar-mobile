import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; //it allows us to convert our json to a list
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String URL = "http://192.168.43.102:2000";
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

class _StockCardMainPageState extends State<StockCardMainPage> {
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
        child: Scaffold(
          appBar: AppBar(
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
              Text('Summary')
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

class StandardItemsPage extends StatefulWidget {
  StandardItemsPage({Key key}) : super(key: key);

  @override
  _StandardItemsPageState createState() => _StandardItemsPageState();
}

class _StandardItemsPageState extends State<StandardItemsPage>
    with AutomaticKeepAliveClientMixin<StandardItemsPage> {
  TextEditingController _textFieldController = TextEditingController();

  Future<String> getStandardItems() async {
    var response = await http.get(
        Uri.encodeFull(standardProductsDataURL + "?date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      standardProducts = jsonResponse;
      if (standardProducts.length > 0) {
        stockCardAvailable = standardProducts[0]["stock_card_available"];
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  void initState() {
    this.getStandardItems();
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
    });
    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  void updateDamagedStock(BuildContext context, int i) {
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
    });

    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  void updateComplementaryStock(BuildContext context, int i) {
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
                  columns: [
                    DataColumn(
                      label: Text("Key"),
                      numeric: false,
                      tooltip: "",
                    ),
                    DataColumn(
                      label: Text('Value'),
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
                          print(standardProducts[i]);
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
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(child: getListView()),
        ],
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
  List selectedPositions = [];
  List selectedButtons = [];

  Future<String> getNonStandardItems() async {
    var response = await http.get(
        Uri.encodeFull(nonStandardProductsDataURL + "?date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      nonStandardProducts = jsonResponse;
      if (nonStandardProducts.length > 0) {
        stockCardAvailable = nonStandardProducts[0]["stock_card_available"];
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  void initState() {
    this.getNonStandardItems();
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
    });
    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  void updateDamagedStock(BuildContext context, int i) {
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
    });

    _textFieldController.text = "";
    updateDifferenceAndTotalSales(i);
  }

  void updateComplementaryStock(BuildContext context, int i) {
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
                nonStandardProducts[i]["product_name"],
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )),
              Container(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  dataRowHeight: 16,
                  columns: [
                    DataColumn(
                      label: Text("Key"),
                      numeric: false,
                      tooltip: "",
                    ),
                    DataColumn(
                      label: Text('Value'),
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
                          print(nonStandardProducts[i]);
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
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(child: getListView()),
        ],
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
  Debtor debtor = new Debtor();

  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showMessage('Form is not valid!  Please review and correct.');
    } else {
      form.save(); //This invokes each onSaved event

      var debtorService = new DebtorService();
      debtorService.createDebtor(debtor).then((value) {
        if (value.errors != null && value.errors.length > 0) {
          showMessage('Errors:\n ${value.errors.join('\n')}', Colors.red);
        } else {
          showMessage('${value.name} was successfully created', Colors.blue);
          form.reset();
          //_controller.text = '';
        }
      });
    }
  }

  Future<String> getDebtorsOnDate() async {
    print(stockDate);
    var response = await http.get(
        Uri.encodeFull(debtorsOnDateURL + "?stock_date=" + stockDate),
        headers: {"Accept": "application/json"});

    setState(() {
      var jsonResponse = json.decode(response.body);
      debtorsOnDate = jsonResponse;
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
                              validator: (val) =>
                              val.isEmpty ? 'Phone number is required' : null,
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
                  _submitForm();
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

          child: ListView.builder(
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
              })),
    );
  }
}

//********************************************************************************************************************************

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
        await http.post(addStockURL, headers: _headers, body: json);
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
      debtor.stockDate = map['stock_date'];
      debtor.description = map['description'];
    }
    return debtor;
  }

  String _toJson(Debtor debtor) {
    var mapData = new Map();
    mapData["name"] = debtor.name;
    mapData["amountOwed"] = debtor.amountOwed;
    mapData["stockDate"] = debtor.stockDate;
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
    var response = await http.get(Uri.encodeFull(productsUrl),
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
                title: Text(data[i]["product_name"]),
                subtitle: Text(
                    'Minimum required: ${data[i]["minimum_required"]} | Current stock: ${data[i]["current_stock"]}'),
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
  final TextEditingController _controller = new TextEditingController();

  //var date = "2019-07-09"; //9 july 2019
  String date =
      DateTime.now().subtract(new Duration(days: 1)).toIso8601String();
  String datePickerFormat;

  Map data = {};

  Future<String> getReports() async {
    try {
      date = DateFormat("yyyy-MM-dd").format(DateTime.parse(date));
      print(date);
    } catch (e) {
      print(e);
    }

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
      } catch (e) {
        print(e);
      }
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
    } catch (e) {
      print(e);
    }
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
        body: SizedBox.expand(
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

  Future<String> getDebtorsPaymentList() async {
    var response = await http.get(Uri.encodeFull(debtorPaymentsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
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
      body: ListView.builder(
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
          }),
    );
  }
}

class OverdueDebtorsPage extends StatefulWidget {
  @override
  _OverdueDebtorsPageState createState() => _OverdueDebtorsPageState();
}

class _OverdueDebtorsPageState extends State<OverdueDebtorsPage> {
  List data;

  Future<String> getOverdueDebtorsList() async {
    var response = await http.get(Uri.encodeFull(overdueDebtorsUrl),
        headers: {"Accept": "application/json"});

    setState(() {
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
      body: ListView.builder(
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
          }),
    );
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
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
