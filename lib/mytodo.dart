import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class MyTodo extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final textfieldController = useTextEditingController();
    final todos = useProvider(filteredListProvider).state;
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: [
        Center(
          child: Text(
            'Todos',
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w200,
              fontSize: 64.0,
            ),
          ),
        ),
        TextField(
          decoration: InputDecoration(labelText: 'what do you want to do....'),
          onSubmitted: (value) {
            var temp = context.read(todoListProvider).state;
            context.read(todoListProvider).state = [
              ...temp,
              Todo(id: uuid.v4(), desc: value),
            ];
            textfieldController.clear();
          },
          controller: textfieldController,
        ),
        const SizedBox(height: 16.0),
        FilterBar(),
        Divider(height: 0.0),
        for (var todo in todos) ...[
          SizedBox(height: 8.0),
          Material(
            elevation: 3.0,
            child: ListTile(
              leading: Checkbox(
                onChanged: (bool? value) {
                  var temps = context.read(todoListProvider).state;
                  var res = [
                    for (var temp in temps)
                      if (temp.id == todo.id)
                        Todo(
                          id: todo.id,
                          desc: todo.desc,
                          completed: !todo.completed,
                        )
                      else
                        temp
                  ];
                  context.read(todoListProvider).state = res;
                },
                value: todo.completed,
              ),
              title: Text(todo.desc),
            ),
          ),
        ]
      ],
    );
  }
}

enum Filter {
  all,
  active,
  completed,
}
final filterProvider = StateProvider((_) => Filter.all);

class FilterBar extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final filter = useProvider(filterProvider).state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {
            context.read(filterProvider).state = Filter.all;
          },
          child: Text('All'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
              filter == Filter.all ? Colors.redAccent : Colors.black38,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            context.read(filterProvider).state = Filter.active;
          },
          child: Text('Active'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
              filter == Filter.active ? Colors.redAccent : Colors.black38,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            context.read(filterProvider).state = Filter.completed;
          },
          child: Text('Completed'),
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(
              filter == Filter.completed ? Colors.redAccent : Colors.black38,
            ),
          ),
        ),
      ],
    );
  }
}

final todoListProvider = StateProvider((_) => []);

// ignore: top_level_function_literal_block
final filteredListProvider = StateProvider((ref) {
  var filter = ref.watch(filterProvider).state;
  var todoList = ref.watch(todoListProvider).state;
  debugPrint('filteredListProvider');
  switch (filter) {
    case Filter.all:
      return todoList;
    case Filter.active:
      return todoList.where((element) => element.completed == false);
    case Filter.completed:
      return todoList.where((element) => element.completed == true);
  }
});

class Todo {
  Todo({required this.id, required this.desc, this.completed = false});

  String id;
  String desc;
  bool completed;
}
