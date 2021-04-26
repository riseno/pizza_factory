import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pizza_factory/chef_interface.dart';
import 'package:pizza_factory/order.dart';

class Chef extends Equatable with ChangeNotifier implements ChefInterface {
  void toggleStatus() {
    isPaused = !isPaused;

    notifyListeners();
  }

  void addOrder(Order order) {
    orders.add(order);

    notifyListeners();
  }

  List<Order> getOrders() {
    return orders;
  }

  Order getOrderByIndex(int index) {
    return orders[index];
  }

  void removeOrder(Order order) {
    orders.remove(order);

    notifyListeners();
  }

  void eliminateOrder() {
    if (orders.length > 0) {
      orders.removeAt(0);
      notifyListeners();
    }
  }

  @override
  List<Object> get props => [
        name,
        speed,
        isPaused,
        orders,
      ];

  @override
  bool isPaused = false;

  @override
  List<Order> orders = [];

  @override
  String get name => "Chef 1";

  @override
  int get speed => 1;
}
