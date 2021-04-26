import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pizza_factory/chef.dart';
import 'package:pizza_factory/chef2.dart';
import 'package:pizza_factory/chef3.dart';
import 'package:pizza_factory/chef4.dart';
import 'package:pizza_factory/chef5.dart';
import 'package:pizza_factory/chef6.dart';
import 'package:pizza_factory/chef_thread.dart';
import 'package:pizza_factory/order.dart';
import 'package:provider/provider.dart';
import 'package:pusher_client/pusher_client.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // StreamController<Order> _eventData = StreamController<Order>.broadcast();
  // Sink get _inEventData => _eventData.sink;
  // Stream get eventStream => _eventData.stream;

  List<StreamController<Order>> orderStreams = [
    StreamController<Order>(),
    StreamController<Order>(),
    StreamController<Order>(),
    StreamController<Order>(),
    StreamController<Order>(),
    StreamController<Order>(),
  ];

  PusherClient pusher;
  Channel channel;

  String channelName = 'factory.1';
  String eventName = 'factory.order-dispatched';

  bool globalPause = false;

  Map<int, bool> _chefStatuses = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
  };

  int _lastStreamId = 0;

  List<Order> _orders = [];

  Future<void> initPusher() async {
    PusherOptions options = PusherOptions(cluster: 'ap1', encrypted: true);

    pusher = PusherClient(
      'f99567f4013b6ccbc5c4',
      options,
      autoConnect: true,
      enableLogging: true,
    );

    await pusher.connect();

    pusher.onConnectionStateChange((state) {
      print(
          "previousState: ${state.previousState}, currentState: ${state.currentState}");
    });

    pusher.onConnectionError((error) {
      print("error: ${error.message}");
    });

    String factoryId = Platform.isIOS ? "1" : "2";
    String channelName = "factory.$factoryId";

    channel = pusher.subscribe(channelName);
    channel.bind(eventName, eventHandler);
  }

  void eventHandler(PusherEvent event) {
    final data = json.decode(event.data);
    final order = Order.fromJson(data['order']);

    // dispatch to streams
    // final availableChefs = _chefStatuses.where((element) => element == false);
    // final availableChefs = _chefStatuses.print(availableChefs);
    int streamId = lookUpAvailableChef();

    print("available: {$streamId}");

    _orders.add(order);

    orderStreams[streamId].sink.add(order);
  }

  int lookUpAvailableChef() {
    var availableChefs = Map.from(_chefStatuses);

    availableChefs.removeWhere((key, value) => value == true);

    print(availableChefs.keys.toList());

    int defaultChef = _orders.length % availableChefs.length;

    return availableChefs.keys.toList()[defaultChef];
  }

  @override
  void initState() {
    super.initState();

    initPusher();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => Chef(),
          ),
          ChangeNotifierProvider(
            create: (_) => Chef2(),
          ),
          ChangeNotifierProvider(
            create: (_) => Chef3(),
          ),
          ChangeNotifierProvider(
            create: (_) => Chef4(),
          ),
          ChangeNotifierProvider(
            create: (_) => Chef5(),
          ),
          ChangeNotifierProvider(
            create: (_) => Chef6(),
          ),
        ],
        child: Consumer6<Chef, Chef2, Chef3, Chef4, Chef5, Chef6>(
          builder: (_, chef1, chef2, chef3, chef4, chef5, chef6, __) {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ChefThread(
                          chef: chef1,
                          chefAvatar: "assets/1.png",
                          streamController: orderStreams[0],
                          isPauseCallback: (isPause) =>
                              _chefStatuses[0] = isPause,
                        ),
                        ChefThread(
                          chef: chef2,
                          chefAvatar: "assets/2.jpeg",
                          streamController: orderStreams[1],
                          isPauseCallback: (isPause) =>
                              _chefStatuses[1] = isPause,
                        ),
                        ChefThread(
                          chef: chef3,
                          chefAvatar: "assets/3.jpeg",
                          streamController: orderStreams[2],
                          isPauseCallback: (isPause) =>
                              _chefStatuses[2] = isPause,
                        ),
                        ChefThread(
                          chef: chef4,
                          chefAvatar: "assets/4.jpeg",
                          streamController: orderStreams[3],
                          isPauseCallback: (isPause) =>
                              _chefStatuses[3] = isPause,
                        ),
                        ChefThread(
                          chef: chef5,
                          chefAvatar: "assets/5.jpeg",
                          streamController: orderStreams[4],
                          isPauseCallback: (isPause) =>
                              _chefStatuses[4] = isPause,
                        ),
                        ChefThread(
                          chef: chef6,
                          chefAvatar: "assets/6.jpeg",
                          streamController: orderStreams[5],
                          isPauseCallback: (isPause) =>
                              _chefStatuses[5] = isPause,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      RaisedButton(
                        child: Text("+10 Pizzas."),
                        onPressed: () {
                          _dispatchOrders(10);
                        },
                      ),
                      RaisedButton(
                        child: Text("+100 Pizzas."),
                        onPressed: () {
                          _dispatchOrders(100);
                        },
                      ),
                      Switch(
                        value: globalPause,
                        onChanged: (value) {
                          chef1.toggleStatus();
                          chef2.toggleStatus();
                          chef3.toggleStatus();
                          chef4.toggleStatus();
                          chef5.toggleStatus();
                          chef6.toggleStatus();

                          globalPause = value;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _dispatchOrders(int count) async {
    await http.post('http://localhost/api/dispatch-orders',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'count': count,
        }));
  }

  @override
  void dispose() {
    pusher.unsubscribe(channelName);
    channel.unbind(eventName);
    orderStreams.forEach((stream) => stream.close());

    super.dispose();
  }
}
