import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorPage(title: 'Calculator page'),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

enum Operator { add, deduct, quo, mul }

// TODO prefer hashmap
extension OperatorExtension on Operator {
  String? get processable {
    return {
      Operator.add: '+',
      Operator.deduct: '-',
      Operator.quo: '/',
      Operator.mul: '*'
    }[this];
  }

  StatelessWidget get icon {
    return {
          Operator.add: const Icon(Icons.add),
          Operator.deduct: const Text("-"),
          Operator.quo: const Text("/"),
          Operator.mul: const Icon(Icons.close)
        }[this] ??
        const Text("");
  }
}

class _CalculatorPageState extends State<CalculatorPage> {
  String? _operator;
  String _expression = "";
  num _result = 0;

  VoidCallback _changeOperator(Operator toggledOperator) {
    return () => setState(() {
          _operator = toggledOperator.processable;
        });
  }

  VoidCallback _addNbToExpr(int nb) {
    return () => setState(() {
          if (nb.toString() != "") {
            _expression += _operator ?? "";
          }

          _expression += nb.toString();
          if (_operator != null) {
            _operator = null;
          }
        });
  }

  VoidCallback _enclose(String parenthesis) {
    return () => setState(() {
          // TODO check id opening parenthesis or closing (regex)
          _expression += _operator ?? "";
          _expression += parenthesis;
          if (_operator != null) {
            _operator = null;
          }
        });
  }

  VoidCallback _finalize(String type) {
    return () => setState(() {
          if (type == "C") {
            _expression = "";
            _result = 0;
          }

          if (type == "=") {
            _result = _expression.interpret();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 6;
    final double itemWidth = size.width / 2;

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(children: <Widget>[
                      const Text(
                        'Expression : ',
                      ),
                      Text(
                        _expression.toString(),
                        style: Theme.of(context).textTheme.headline4,
                      )
                    ]),
                    Row(children: <Widget>[
                      const Text(
                        'Result : ',
                      ),
                      Text(
                        _result.toString(),
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ])
                  ]),
              Expanded(
                  child: GridView.count(
                      // Create a grid with 2 columns. If you change the scrollDirection to
                      // horizontal, this produces 2 rows.
                      crossAxisCount: 3,
                      childAspectRatio: (itemWidth / itemHeight),
                      children: [
                    ...List.generate(9, (index) {
                      return Center(
                        child: TextButton(
                            onPressed: _addNbToExpr(index),
                            child: Text(
                              '$index',
                              style: Theme.of(context).textTheme.headline5,
                            )),
                      );
                    }),
                    ...["(", ")"].map((e) => Center(
                        child: TextButton(
                            onPressed: _enclose(e),
                            child: Text(e,
                                style:
                                    Theme.of(context).textTheme.headline5)))),
                  ])),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      verticalDirection: VerticalDirection.up,
                      children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ...Operator.values.map((e) => TextButton(
                                onPressed: _changeOperator(e),
                                child: e.icon,
                              ))
                        ]),
                    Padding(
                        padding: const EdgeInsets.all(30),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ...["C", "="].map((e) => Center(
                                  child: TextButton(
                                      onPressed: _finalize(e),
                                      child: Text(e,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5))))
                            ]))
                  ])),
            ]),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
