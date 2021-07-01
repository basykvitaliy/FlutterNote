import 'package:flutter/material.dart';
import 'package:flutter_note/db/DatabaseRepository.dart';
import 'package:flutter_note/model/NoteModel.dart';
import 'package:intl/intl.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key key, this.note, this.updateListNote}) : super(key: key);

  final Note note;
  final Function updateListNote;

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {

  String _title = "";
  String _priority;
  final List<String> _priorities = ["Low", "Medium", "Hard"];
  final DateFormat _dateFormat = DateFormat("MMM dd, yyyy");
  final _keys = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if(widget.note != null){
      _title = widget.note.title;
      _date = widget.note.date;
      _priority = widget.note.priority;
    }
    _controller.text = _dateFormat.format(_date);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Note"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _keys,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Title"
                  ),
                  validator: (input) => input.trim().isEmpty ? "Enter title" : null,
                  initialValue: _title,
                  onSaved: (input) => _title = input,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: TextFormField(
                  readOnly: true,
                  controller: _controller,
                  onTap: _handleDatePicker,
                  decoration: InputDecoration(
                      labelText: "Date"
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: DropdownButtonFormField(
                  items: _priorities.map((e){
                    return DropdownMenuItem(child: Text(e), value: e,);
                  }).toList(),
                  decoration: InputDecoration(
                      labelText: "Priority"
                  ),
                  validator: (input) => _priority == null ? "Select priority" : null,
                  onSaved: (input) => _priority = input,
                  onChanged: (value){
                    setState(() {
                      _priority = value;
                    });
                  },
                  value: _priority,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 50, left: 16, right: 16),
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: FlatButton(
                  child: Text(
                   widget.note == null ? "ADD" : "UPDATE",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _submit,
                ),
              ),
              widget.note != null ? Container(
                margin: EdgeInsets.only(top: 50, left: 16, right: 16),
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: FlatButton(
                  child: Text(
                    "DELETE",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _delete,
                ),
              ) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDatePicker()async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if(date != null && date != _date){
      setState(() {
        _date = date;
      });
    }
    _controller.text = _dateFormat.format(date);
  }

  void _submit() {
    if(_keys.currentState.validate()){
      _keys.currentState.save();
      Note note= Note(title: _title, date: _date, priority: _priority);
      if(widget.note == null){
        note.status = 0;
        DatabaseRepository.instance.insert(note);
      }else{
        note.status = widget.note.status;
        note.id = widget.note.id;
        DatabaseRepository.instance.update(note);
      }
      widget.updateListNote();
      Navigator.pop(context);
    }
  }

  void _delete() {
    DatabaseRepository.instance.delete(widget.note.id);
    widget.updateListNote();
    Navigator.pop(context);
  }
}
