// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database.dart';

FlutterTts flutterTts = FlutterTts();

Future _speak() async {
  await flutterTts.speak('The Contact has been saved successfully ');
}

Future _speak1() async {
  await flutterTts.speak('The Contact has been deleted successfully');
}

Future _speak2() async {
  await flutterTts
      .speak('You can now edit the user name or the contact number ');
}

Future _speak3() async {
  await flutterTts.speak('Calling ');
}

Future _speak4() async {
  await flutterTts.speak(
      'Now you can add a contact to your list... Please type the user name,mobile number and click the save contact button');
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(

        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        home: ContactPage());
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Text(
                "Add Contact",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      hintText: 'Name',
                      hintStyle: const TextStyle(color: Colors.blue),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Raleway",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                      // ignore: prefer_const_constructors
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.blue,
                      ),
                      hintText: 'Contact Number',
                      hintStyle: const TextStyle(color: Colors.blue),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    autofocus: true,
                    // ignore: prefer_const_constructors
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Raleway",
                    ),
                  ),
                  Padding(
                    // ignore: prefer_const_constructors
                    padding: EdgeInsets.only(
                      top: 10.0,
                    ),
                    child: Container(
                      height: 60,
                      width: 348,
                      // ignore: prefer_const_constructors
                      margin: EdgeInsets.only(
                          top: 20.0, left: 0.0, right: 0.0, bottom: 20.0),
                      child: ElevatedButton(
                        child: Text(
                          (id == null ? 'Save Contact' : 'Save Changes'),
                          style: const TextStyle(fontSize: 24.0),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF014268)),
                          shape: MaterialStateProperty
                              // ignore: prefer_const_constructors
                              .all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                  // borderRadius: BorderRadius.circular(25.0),
                                  )),
                        ),
                        onPressed: () async {
                          // Save new journal
                          if (id == null) {
                            await _addItem();
                          }

                          if (id != null) {
                            await _updateItem(id);
                          }

                          // Clear the text fields
                          _titleController.text = '';
                          _descriptionController.text = '';

                          // Close the bottom sheet
                          Navigator.of(context).pop();
                          _speak();
                        },

                        // ignore: prefer_const_constructors
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

// Insert a new contact to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Update an existing contact
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Contact!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEDCD2),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Card(
                  color: const Color(0xFFFFFFFF),
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: const Text("Police"),
                    subtitle: const Text("119"),
                    trailing: SizedBox(
                      width: 145,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFFFFFFFF),
                              ),
                              onPressed: () {}),
                          IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xFFFFFFFF),
                              ),
                              onPressed: () {}),
                          IconButton(
                              icon: const Icon(
                                Icons.call,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                launch("tel:119");
                                _speak3();
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  color: const Color(0xFFFFFFFF),
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: const Text("Ambulance Service"),
                    subtitle: const Text("1990"),
                    trailing: SizedBox(
                      width: 145,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFFFFFFFF),
                              ),
                              onPressed: () {}),
                          IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xFFFFFFFF),
                              ),
                              onPressed: () {}),
                          IconButton(
                              icon: const Icon(
                                Icons.call,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                launch("tel:1990");
                                _speak3();
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  color: const Color(0xFFFFFFFF),
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                    title: const Text("Sri Lanka Council for the Blind"),
                    subtitle: const Text("0112329564"),
                    trailing: SizedBox(
                      width: 145,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFFFFFFFF),
                              ),
                              onPressed: () {}),
                          IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xFFFFFFFF),
                              ),
                              onPressed: () {}),
                          IconButton(
                              icon: const Icon(
                                Icons.call,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                launch("tel:0112329564");
                                _speak3();
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _journals.length,
                  itemBuilder: (context, index) => Card(
                    color: const Color(0xFFFFFFFF),
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(_journals[index]['title'].toUpperCase()),
                      subtitle: Text(_journals[index]['description']),
                      trailing: SizedBox(
                        width: 145,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  _showForm(_journals[index]['id']);
                                  _speak2();
                                }),
                            IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _deleteItem(_journals[index]['id']);

                                  _speak1();
                                }),
                            IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  launch(
                                      ('tel:${_journals[index]['description']}'));
                                  _speak3();
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF014268),
          child: const Icon(Icons.add),
          onPressed: () {
            _showForm(null);
            _speak4();
          }),
    );
  }
}
