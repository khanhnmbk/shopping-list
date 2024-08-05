import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class GroceryListItem extends StatelessWidget {
  final GroceryItem groceryItem;

  const GroceryListItem({super.key, required this.groceryItem});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        color: groceryItem.category.color,
        width: 20,
        height: 20,
      ),
      title: Text(groceryItem.name),
      trailing: Text(groceryItem.quantity.toString()),
    );
  }
}
