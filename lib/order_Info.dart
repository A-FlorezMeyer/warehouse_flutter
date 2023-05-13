import 'dart:convert';
import 'package:http/http.dart' as http;
class OrderInfo {
  final int orderID;
  final String provider;
  final String city;
  final DateTime date;
  final Map<String, dynamic> products;
  final int status;

  const OrderInfo({
    required this.orderID,
    required this.provider,
    required this.city,
    required this.date,
    required this.products,
    required this.status
  });
  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      orderID: int.parse(json['OrderID']),
      provider: json['Provider'],
      city: json['City'],
      date: DateTime.parse(json['Date']),
      products: Map<String, dynamic>.from(json['Products']),
      status: int.parse(json['Status']),
    );
  }
  Map<String, dynamic> toJson() => {
    'OrderID': orderID,
    'Provider': provider,
    'City': city,
    'Date': date,
    'Products': products,
    'Status': status,
  };
}

Future<OrderInfo> fetchOrderInfo()  async {
  final response = await http
      .get(Uri.parse('http://52.4.150.68/api/getOrderIn'));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return OrderInfo.fromJson(jsonDecode(response.body));
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