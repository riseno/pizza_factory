import 'package:flutter/material.dart';
import 'package:pizza_factory/blocs/order_bloc.dart';
import 'package:pizza_factory/models/chef1.dart';
import 'package:pizza_factory/models/chef2.dart';
import 'package:pizza_factory/models/chef3.dart';
import 'package:pizza_factory/models/chef4.dart';
import 'package:pizza_factory/models/chef5.dart';
import 'package:pizza_factory/models/chef6.dart';
import 'package:pizza_factory/ui/widgets/chef_thread.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderBloc orderBloc = OrderBloc();

  @override
  void initState() {
    super.initState();

    orderBloc.initPusher();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Chef1()),
          ChangeNotifierProvider(create: (_) => Chef2()),
          ChangeNotifierProvider(create: (_) => Chef3()),
          ChangeNotifierProvider(create: (_) => Chef4()),
          ChangeNotifierProvider(create: (_) => Chef5()),
          ChangeNotifierProvider(create: (_) => Chef6()),
        ],
        child: Consumer6<Chef1, Chef2, Chef3, Chef4, Chef5, Chef6>(
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
                          streamController: orderBloc.orderStreams[0],
                          isPauseCallback: (isPause) =>
                              orderBloc.chefStatuses[0] = isPause,
                        ),
                        ChefThread(
                          chef: chef2,
                          chefAvatar: "assets/2.jpeg",
                          streamController: orderBloc.orderStreams[1],
                          isPauseCallback: (isPause) =>
                              orderBloc.chefStatuses[1] = isPause,
                        ),
                        ChefThread(
                          chef: chef3,
                          chefAvatar: "assets/3.jpeg",
                          streamController: orderBloc.orderStreams[2],
                          isPauseCallback: (isPause) =>
                              orderBloc.chefStatuses[2] = isPause,
                        ),
                        ChefThread(
                          chef: chef4,
                          chefAvatar: "assets/4.jpeg",
                          streamController: orderBloc.orderStreams[3],
                          isPauseCallback: (isPause) =>
                              orderBloc.chefStatuses[3] = isPause,
                        ),
                        ChefThread(
                          chef: chef5,
                          chefAvatar: "assets/5.jpeg",
                          streamController: orderBloc.orderStreams[4],
                          isPauseCallback: (isPause) =>
                              orderBloc.chefStatuses[4] = isPause,
                        ),
                        ChefThread(
                          chef: chef6,
                          chefAvatar: "assets/6.jpeg",
                          streamController: orderBloc.orderStreams[5],
                          isPauseCallback: (isPause) =>
                              orderBloc.chefStatuses[5] = isPause,
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
                          orderBloc.dispatchOrders(10);
                        },
                      ),
                      RaisedButton(
                        child: Text("+100 Pizzas."),
                        onPressed: () {
                          orderBloc.dispatchOrders(100);
                        },
                      ),
                      Switch(
                        value: !orderBloc.globalPause,
                        onChanged: (value) {
                          setState(() {
                            orderBloc.setGlobalPause(!value);
                          });
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

  @override
  void dispose() {
    orderBloc.dispose();

    super.dispose();
  }
}
