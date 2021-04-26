import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pizza_factory/chef_interface.dart';
import 'package:pizza_factory/order.dart';
import 'package:pizza_factory/toggle_status.dart';

class ChefThread extends StatefulWidget {
  final ChefInterface chef;
  final String chefAvatar;
  final StreamController<Order> streamController;
  final Function(bool isPaused) isPauseCallback;

  const ChefThread({
    Key key,
    this.chefAvatar,
    this.chef,
    this.streamController,
    this.isPauseCallback,
  }) : super(key: key);

  @override
  _ChefThreadState createState() => _ChefThreadState();
}

class _ChefThreadState extends State<ChefThread> {
  @override
  void initState() {
    super.initState();

    widget.streamController.stream.listen((event) {
      print("Chef ${widget.chef.name} received order.");

      if (event is Order) {
        widget.chef.addOrder(event);
      } else if (event is ToggleStatus) {
        widget.chef.toggleStatus();
        widget.isPauseCallback(widget.chef.isPaused);
      }
    });

    Timer.periodic(Duration(seconds: widget.chef.speed), (timer) {
      if (widget.chef.isPaused == false) {
        widget.chef.eliminateOrder();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      width: (MediaQuery.of(context).size.width - 40) / 6,
      child: Column(
        children: [
          Image.asset(
            widget.chefAvatar,
            width: (MediaQuery.of(context).size.width - 80) / 7,
            height: (MediaQuery.of(context).size.width - 80) / 7,
            fit: BoxFit.cover,
          ),
          SizedBox(
            height: 10.0,
          ),
          Switch(
            value: !widget.chef.isPaused,
            onChanged: (value) {
              widget.chef.toggleStatus();

              if (widget.isPauseCallback != null) {
                widget.isPauseCallback(!value);
              }
            },
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.chef.name,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  "Remaining Pizza: ${widget.chef.getOrders().length}",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  "Speed: ${widget.chef.speed} second per pizza",
                  style: TextStyle(
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          widget.chef.orders.length > 0
              ? _orderList(context)
              : Center(
                  child: Text("No Orders."),
                ),
        ],
      ),
    );
  }

  void _delegateOrder(Order order) async {
    await http.post('http://localhost/api/delegate-order',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': order.id,
        }));

    widget.chef.removeOrder(order);
  }

  Widget _orderList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.chef.orders.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Order order = widget.chef.getOrderByIndex(index);

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Text(order.name),
                InkWell(
                  child: Text("Delegate"),
                  onTap: () => _delegateOrder(order),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
