// ignore_for_file: camel_case_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpit_demo_api/model/User.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ListEmployeePage extends StatelessWidget {
  List<User> employees;

  ListEmployeePage({super.key, required this.employees});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách nhân viên'),
      ),
      body: listView(employees: employees),
      floatingActionButton: AddUser(employees: employees),
    );
  }
}

class AddUser extends StatefulWidget {
  const AddUser({super.key, required this.employees});

  final List<User> employees;

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  List<User> listEmployees = [];

  void updateList() {
    widget.employees.forEach((element) {
      setState(() {
        listEmployees.add(element);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateList();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController positionController = TextEditingController();

  Future showPopUpAdd(BuildContext context, User employees) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm nhân viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Vị trí'),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Xử lý sự kiện khi nhấn nút "add"
                var db = await getConnection();
                await db.transaction((txn) async {
                  await txn.rawInsert(
                      'INSERT INTO user(userName, groupName) VALUES("${nameController.text}", "${positionController.text}")');
                });
                await db.close();
                setState(() {
                  listEmployees
                      .firstWhere((item) => item.id == employees.id,
                          orElse: () => User())
                      .userName = nameController.text;
                  listEmployees
                      .firstWhere((item) => item.id == employees.id,
                          orElse: () => User())
                      .groupName = positionController.text;
                  nameController.text = "";
                  positionController.text = "";
                });
                Navigator.pop(context); // Đóng pop-up
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showPopUpAdd(context, listEmployees.first);
      },
      child: const Icon(Icons.add),
    );
  }
}

Future<Database> getConnection() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'fpit.db');
  Database database = await openDatabase(path, version: 1);

  return database;
}

class listView extends StatefulWidget {
  const listView({
    super.key,
    required this.employees,
  });

  final List<User> employees;

  @override
  State<listView> createState() => _listViewState();
}

class _listViewState extends State<listView> {
  List<User> listEmployees = [];

  void updateList() {
    widget.employees.forEach((element) {
      setState(() {
        listEmployees.add(element);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateList();
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController positionController = TextEditingController();

  Future showPopUpEdit(BuildContext context, User employees) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
              ),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(labelText: 'Vị trí'),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Xử lý sự kiện khi nhấn nút "edit"
                var db = await getConnection();
                await db.rawUpdate(
                    'UPDATE user SET userName = ?, groupName = ? WHERE id = ?',
                    [
                      '${nameController.text}',
                      '${positionController.text}',
                      employees.id
                    ]);
                await db.close();
                setState(() {
                  listEmployees
                      .firstWhere((item) => item.id == employees.id,
                          orElse: () => User())
                      .userName = nameController.text;
                  listEmployees
                      .firstWhere((item) => item.id == employees.id,
                          orElse: () => User())
                      .groupName = positionController.text;
                  nameController.text = "";
                  positionController.text = "";
                });
                Navigator.pop(context); // Đóng pop-up
              },
            ),
          ],
        );
      },
    );
  }

  Future showPopUp2(
      BuildContext context, User employees, String uName, String gName) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông tin nhân viên'),
          content: Text(
              'Tên: ${employees.userName}\nVị trí: ${employees.groupName}'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                await showPopUpEdit(context, employees);
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                // Xử lý sự kiện khi nhấn nút "delete"
                var db = await getConnection();
                print("id: ${employees.id}");
                await db
                    .rawDelete('DELETE FROM user WHERE id = ?', [employees.id]);
                await db.close();
                setState(() {
                  listEmployees
                      .removeWhere((element) => element.id == employees.id);
                });
                Navigator.pop(context); // Đóng pop-up
              },
            ),
          ],
        );
      },
    );
  }

  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listEmployees.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            "Name: ${listEmployees[index].userName}",
            style: TextStyle(
                color: selectedIndex == index
                    ? Colors.deepOrange.shade400
                    : Colors.black),
          ),
          subtitle: Text(
            "G.Name: ${listEmployees[index].groupName}",
            style: TextStyle(
                color: selectedIndex == index
                    ? Colors.deepOrange.shade400
                    : Colors.black),
          ),
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            showPopUp2(context, listEmployees[index], 'Cường', 'Dev C#');
          },
        );
      },
    );
  }
}
