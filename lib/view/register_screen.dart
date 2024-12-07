import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_love_my_girlfriend/bloc/user_bloc.dart';
import 'package:i_love_my_girlfriend/bloc/user_event.dart';
import 'package:i_love_my_girlfriend/view/header.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  int _selectedDay = 1;
  int _selectedMonth = 1;
  int _selectedYear = DateTime.now().year;

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CupertinoButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Text('Concluído'),
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime(_selectedYear, _selectedMonth, _selectedDay),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedDay = newDateTime.day;
                      _selectedMonth = newDateTime.month;
                      _selectedYear = newDateTime.year;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'RUNGUARD'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _confirmEmailController,
              decoration: InputDecoration(labelText: 'Confirmar Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmar Senha'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: _showDatePicker,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                side: BorderSide(color: Colors.black),
              ),
              child: Text(
                'Data de Nascimento: $_selectedDay/$_selectedMonth/$_selectedYear',
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  if (_emailController.text != _confirmEmailController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Emails não coincidem'),
                      ),
                    );
                    return;
                  }
                  if (_passwordController.text != _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Senhas não coincidem'),
                      ),
                    );
                    return;
                  }

                  BlocProvider.of<UserBloc>(context).add(
                    RegisterRequested(
                      _nameController.text,
                      '$_selectedYear-$_selectedMonth-$_selectedDay',
                      _emailController.text,
                      _passwordController.text,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Registrar',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
