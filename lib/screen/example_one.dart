import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpms/provider/example_one_provider.dart';

class ExampleOneScreen extends StatefulWidget {
  const ExampleOneScreen({Key? key}) : super(key: key);

  @override
  State<ExampleOneScreen> createState() => _ExampleOneScreenState();
}

class _ExampleOneScreenState extends State<ExampleOneScreen> {

  @override
  Widget build(BuildContext context) {
    print('in build context');
    //final provider = Provider.of<ExampleOneProvider>(context, listen: false);
    //final provider = Provider.of<ExampleOneProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Subscribe"),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer<ExampleOneProvider>(builder: (context, element, child){
            return Slider(min: 0, max: 1, value: element.value, onChanged: (val){
              element.setValue(val);
            });
          }),
          Consumer<ExampleOneProvider>(builder: (context, element, child){
            return Row(
              children: [
                Expanded(
                  child:  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(element.value)
                    ),
                    child: const Center(
                      child: Text("Container 1"),
                    ),
                  ),
                ),
                Expanded(
                  child:  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(element.value)
                    ),
                    child: const Center(
                      child: Text("Container 1"),
                    ),
                  ),
                ),
              ],
            );
          })
        ],
      )
    );
  }
}
