import 'package:equatable/equatable.dart';

class Order extends Equatable {
  String id;
  String name;
  String size;
  List<String> toppings = [];

  Order({
    this.id,
    this.name,
    this.size,
    this.toppings,
  });

  @override
  List<Object> get props => [
        size,
        toppings,
      ];

  factory Order.fromJson(Map<String, dynamic> json) {
    print(json);

    return Order(
      id: json['id'].toString(),
      name: json['name'],
      size: json['size'],
      toppings: List<String>.from(json['toppings']),
    );
  }

  @override
  String toString() =>
      "Order{id: $id, name: $name, size: $size, toppings: $toppings}";
}
