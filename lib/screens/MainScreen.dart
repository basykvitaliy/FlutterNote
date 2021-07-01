import 'package:flutter/material.dart';
import 'package:flutter_note/db/DatabaseRepository.dart';
import 'package:flutter_note/model/NoteModel.dart';
import 'package:flutter_note/screens/AddNoteScreen.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<List<Note>> _listNote;
  final DateFormat _dateFormat = DateFormat("MMM dd, yyyy");

  @override
  void initState() {
    _updateNoteList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _listNote,
        builder: (context, snapshot) {
          final int countNotes = snapshot.data.where((Note note) => note.status == 1).toList().length;
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    "$countNotes of ${snapshot.data.length}",
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount:snapshot.data.length,
                        itemBuilder: (context, index) {
                          return _buildNote(snapshot.data[index]);
                        })),
              ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddNoteScreen(updateListNote: _updateNoteList,))),
      ),
    );
  }

  Widget _buildNote(Note note) {
    return Column(
      children: [
        ListTile(
          title: Text(note.title, style: TextStyle(decoration: note.status == 0 ? TextDecoration.none : TextDecoration.lineThrough),),
          subtitle: Text("${_dateFormat.format(note.date)} + ${note.priority}", style: TextStyle(decoration: note.status == 0 ? TextDecoration.none : TextDecoration.lineThrough),),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddNoteScreen(updateListNote: _updateNoteList, note: note,))),
          trailing: Checkbox(
            onChanged: (value){
              note.status = value ? 1 : 0;
              DatabaseRepository.instance.update(note);
              _updateNoteList();
            },
            activeColor: Colors.deepPurple,
            value: note.status == 1 ? true  : false,
          ),
        ),
        Divider(),
      ],
    );
  }

  void _updateNoteList() {
    setState(() {
      _listNote = DatabaseRepository.instance.getNoteList();
    });
  }
}
