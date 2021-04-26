import 'package:pizza_factory/order.dart';

abstract class ChefInterface {
  final String name;
  final int speed;

  bool isPaused = false;
  List<Order> orders = [];

  ChefInterface({
    this.name,
    this.speed = 0,
  });

  void toggleStatus();

  void addOrder(Order order);

  List<Order> getOrders();

  Order getOrderByIndex(int index);

  void removeOrder(Order order);

  void eliminateOrder();
}
