import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpms/provider/favourite_provider.dart';
import 'package:rpms/screen/favourite/myfavourite.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({Key? key}) : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  List<int> selectedItem = [];

  @override
  Widget build(BuildContext context) {
    print("Build");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello"),
        actions: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyFavouriteItemScreen( ) ));
            },
            child: Icon(Icons.favorite)
          ),
          SizedBox(width: 20)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: 10000,
                itemBuilder: (context, index){
                  return Consumer<FavouriteItemProvider>(builder: (context, element, child){
                    return ListTile(
                      onTap: (){
                        if(element.selectedItem.contains(index)){
                          element.removeItem(index);
                        }else{
                          element.addItem(index);
                        }
                      },
                      title: Text("item "+index.toString()),
                      trailing: Icon(
                          element.selectedItem.contains(index) ? Icons.favorite  :  Icons.favorite_border_outlined
                      ),
                    );
                  });
                }
            ),
          )
        ],
      )

    );
  }
}
