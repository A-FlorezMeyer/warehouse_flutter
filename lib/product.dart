import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String productName;
  final String brand;
  final String itemCode;
  final String reference;
  final String description;
  final double length;
  final double width;
  final double height;
  final double weight;

  Product({
    required this.id,
    required this.productName,
    required this.brand,
    required this.itemCode,
    required this.reference,
    required this.description,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['ID']),
      productName: json['ProductName'],
      brand: json['Brand'],
      itemCode: json['ItemCode'],
      reference: json['Reference'],
      description: json['Description'],
      length: double.parse(json['Length']),
      width: double.parse(json['Width']),
      height: double.parse(json['Height']),
      weight: double.parse(json['Weight']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ProductName': productName,
      'Brand': brand,
      'ItemCode': itemCode,
      'Reference': reference,
      'Description': description,
      'Length': length,
      'Width': width,
      'Height': height,
      'Weight': weight,
    };
  }
}
Future<List<Map<String, dynamic>>> fetchProductInfo(Map<String, dynamic> products) async {
  List<Map<String, dynamic>> productList = [];

  // Realiza solicitudes HTTP para cada producto
  List<Future> fetchFutures = products.entries.map((MapEntry<String, dynamic> entry) async {
    String itemCode = entry.key;
    dynamic value = entry.value;

    // Realiza la llamada HTTP y decodifica la respuesta aquí
    // Supongamos que obtenemos un JSON de producto como respuesta
    Product product = await fetchProduct(itemCode);
    Map<String, dynamic> productJson = product.toJson();
    // Agrega la clave 'quantity' al JSON del producto
    productJson['quantity'] = value;
    // Agrega el objeto JSON del producto a la lista de productos
    productList.add(productJson);
  }).toList();

  await Future.wait(fetchFutures);
  return productList;
}

Future<Product> fetchProduct(itemCode)  async {
  final response = await http
      .get(Uri.parse('http://52.4.150.68/api/getProduct?ProductID=$itemCode'));
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body);
      return Product.fromJson(jsonResponse[0]);
  } else if (response.statusCode == 500) {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print('Internal Server Error');
    throw Exception('Internal Server Error');
  } else {
    print('Method not allowed');
    throw Exception('Method not allowed');
  }
}