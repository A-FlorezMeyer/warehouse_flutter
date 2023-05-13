import 'package:flutter/material.dart';
import 'color_schemes.g.dart';
import 'order_Info.dart';
import 'product.dart';

void main() => runApp(WMSApp());

class WMSApp extends StatelessWidget {
  const WMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "App para facilitar ingreso de pedidos",
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        home: Navigation());
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('WMS LogixPro'),
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 2,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.input),
            label: 'Ingreso',
          ),
          NavigationDestination(
            icon: Icon(Icons.output),
            label: 'Despacho',
          ),
        ],
      ),
      body: <Widget>[
        InOrder(),
        OutOrder(),
      ][currentPageIndex],
    );
  }
}

class OutOrder extends StatelessWidget {
  const OutOrder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Text("Hola"),
          SizedBox(height: 10),
          Text("Hola"),
          SizedBox(height: 10),
          Text("Hola"),
        ],
      ),
    );
  }
}

class InOrder extends StatefulWidget {
  const InOrder({
    super.key,
  });

  @override
  _InOrderState createState() => _InOrderState();
}

class _InOrderState extends State<InOrder> {
  late Future<OrderInfo> _futureOrder;
  late Future<List<Map<String, dynamic>>> _futureProducts;
  late int _totalQuantity;
  @override
  void initState() {
    super.initState();
    _futureOrder = fetchOrderInfo().then((OrderInfo order) {
      _totalQuantity = order.products.values.reduce((a, b) => a + b);
      _futureProducts = fetchProductInfo(order.products);
      return order;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OrderInfo>(
      future: _futureOrder,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder(
            future: _futureProducts,
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> productsSnapshot) {
              if (productsSnapshot.hasData) {
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 10,
                        child: OrderWidget(orderInfo: snapshot.data!,totalQuantity: _totalQuantity),
                      ),
                      Expanded(
                          child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                Map<String, dynamic> product = productsSnapshot.data![index];
                                return Card(
                                    child: ProductWidget(productInfo: product)
                                );
                              },
                              separatorBuilder: (BuildContext context, int index) => const Divider(),
                              itemCount: productsSnapshot.data!.length)
                      ),
                      // TODO: agregar row para botones de escanear y confirmar o idear otra manera para crear el qrScanner.
                    ],
                  ),
                );
              } else if (productsSnapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 100,
                        child: OrderWidget(orderInfo: snapshot.data!,totalQuantity: _totalQuantity),
                      ),
                      // TODO: Agregar en vez de un listView, un widget que informe que no se adquirio bien la informacion
                    ],
                  ),
                );
              } else {
                return  Center(child:CircularProgressIndicator());
              }
            },
          );

        } else if (snapshot.hasError) {
          // TODO: Agregar un widget que o muestre que no se cargo la info bien o un widget para reintentar 
          return Center(child: Text('Error al cargar la información'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ProductWidget extends StatelessWidget {
  final Map<String, dynamic> productInfo;

  const ProductWidget({
    required this.productInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(productInfo['ProductName']),
      subtitle: Text('${productInfo['ItemCode']}, cantidad: ${productInfo['quantity']}'),
    );
  }
}

class OrderWidget extends StatelessWidget {
  final OrderInfo orderInfo;
  final int totalQuantity;

  const OrderWidget({
    required this.orderInfo,
    required this.totalQuantity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.warehouse),
      title: Text('Orden de Ingreso: ${orderInfo.orderID}'),
      subtitle: Text('Total productos: $totalQuantity, Estado: ${orderInfo.status}'),
      isThreeLine: false,
      trailing: Icon(Icons.expand_more),
    );
  }
}


/*
void main() => runApp(
    MaterialApp(home: MyHome(),
  theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  ),));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('qrView'),
        ),
      ),
    );
  }
}
*/