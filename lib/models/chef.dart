import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pizza_factory/models/order.dart';

class Chef extends Equatable with ChangeNotifier {
  final String name;
  final int speed;

  bool isPaused = false;
  List<Order> _orders = [];

  Chef({
    this.name,
    this.speed = 0,
  });

  void setStatus(bool isPaused) {
    isPaused = isPaused;

    notifyListeners();
  }

  void toggleStatus() {
    isPaused = !isPaused;

    notifyListeners();
  }

  void addOrder(Order order) {
    _orders.add(order);

    notifyListeners();
  }

  List<Order> getOrders() {
    return _orders;
  }

  Order getOrderByIndex(int index) {
    return _orders[index];
  }

  void removeOrder(Order order) {
    _orders.remove(order);

    notifyListeners();
  }

  void eliminateOrder() {
    if (_orders.length > 0) {
      _orders.removeAt(0);
      notifyListeners();
    }
  }

  @override
  List<Object> get props => [
        name,
        speed,
        isPaused,
        _orders,
      ];
}
