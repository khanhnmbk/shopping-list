import 'package:flutter/material.dart';

class GroceryItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        color: _groceryItems[index].category.color,
        width: 20,
        height: 20,
      ),
      title: Text(_groceryItems[index].name),
      trailing: Text(_groceryItems[index].quantity.toString()),
    );
  }
}
