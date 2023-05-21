import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/favourite_provider.dart';

class MyFavouriteItemScreen extends StatefulWidget {
  const MyFavouriteItemScreen({Key? key}) : super(key: key);

  @override
  State<MyFavouriteItemScreen> createState() => _MyFavouriteItemScreenState();
}

class _MyFavouriteItemScreenState extends State<MyFavouriteItemScreen> {
  @override
  Widget build(BuildContext context) {
    final favouriteProvider = Provider.of<FavouriteItemProvider>(context);
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
                  itemCount: favouriteProvider.selectedItem.length,
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
