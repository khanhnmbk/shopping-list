import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final response = await http.get(Uri.https(
        'flutter-prep-ec1ad-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping_list.json'));

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'An error occurred: ${response.reasonPhrase}';
      });
    }

    List<GroceryItem> loadItems = [];
    if (response.statusCode == 200) {
      final decodedBody = json.decode(response.body);
      if (decodedBody == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      decodedBody.forEach((key, value) {
        loadItems.add(GroceryItem(
            id: key,
            name: value['name'],
            quantity: value['quantity'],
            category: categories.entries
                .firstWhere(
                    (catItem) => catItem.value.title == value['category'])
                .value));
      });

      setState(() {
        _groceryItems = loadItems;
        _isLoading = false;
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _onItemRemoved(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'flutter-prep-ec1ad-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping_list/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      const snackBar = SnackBar(
        content: Text('Failed to delete. Please try again'),
        backgroundColor: Colors.redAccent,
      );

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No items yet', style: TextStyle(fontSize: 30)),
          SizedBox(height: 10),
          Text('Tap the + button to add a new item'),
        ],
      ),
    );

    if (_isLoading) {
      bodyWidget = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      bodyWidget = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) {
            return Dismissible(
                key: ValueKey(_groceryItems[index]),
                onDismissed: (direction) {
                  _onItemRemoved(_groceryItems[index]);
                },
                child: GroceryListItem(groceryItem: _groceryItems[index]));
          });
    }

    if (_error != null) {
      bodyWidget = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groceries'),
        actions: [
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
        ],
      ),
      /*
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (final item in groceryItems)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    color: item.category.color,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(item.name),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(item.quantity.toString()),
                ],
              ),
            ),
        ]),
          ),
        */
      body: bodyWidget,
    );
  }
}
