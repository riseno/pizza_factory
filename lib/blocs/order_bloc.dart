import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pizza_factory/models/order.dart';
import 'package:pusher_client/pusher_client.dart';

class OrderBloc {
  List<StreamController<Order>> orderStreams = [
    StreamController<Order>(),
    StreamController<Order>(),
    StreamController<Order>(),
    StreamController<Order>(),
    StreamController<Order>(),
    StreamController<Order>(),
  ];

  Map<int, bool> chefStatuses = {
    0: false,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
  };

  PusherClient pusher;
  Channel channel;

  String get _channelName => "factory.${Platform.isIOS ? "1" : "2"}";
  String eventName = 'factory.order-dispatched';

  bool globalPause = false;

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

    channel = pusher.subscribe(_channelName);
    channel.bind(eventName, eventHandler);
  }

  void eventHandler(PusherEvent event) {
    final data = json.decode(event.data);
    final order = Order.fromJson(data['order']);

    if (!globalPause) {
      int streamId = lookUpAvailableChef();

      _orders.add(order);

      orderStreams[streamId].sink.add(order);
    }
  }

  int lookUpAvailableChef() {
    var availableChefs = Map.from(chefStatuses);

    availableChefs.removeWhere((key, value) => value == true);

    int defaultChef = _orders.length % availableChefs.length;

    return availableChefs.keys.toList()[defaultChef];
  }

  void dispatchOrders(int count) async {
    await http.post('http://localhost/api/dispatch-orders',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'count': count,
        }));
  }

  void setGlobalPause(bool isPaused) {
    this.globalPause = isPaused;
  }

  void dispose() {
    pusher.unsubscribe(_channelName);
    channel.unbind(eventName);
    orderStreams.forEach((stream) => stream.close());
  }
}
