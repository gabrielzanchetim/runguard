import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:i_love_my_girlfriend/modelservices/services/auth_service.dart';
import 'package:i_love_my_girlfriend/view/header.dart';

class AddRunScreen extends StatefulWidget {
  @override
  _AddRunScreenState createState() => _AddRunScreenState();
}

class _AddRunScreenState extends State<AddRunScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Duration _selectedDuration = Duration(hours: 0, minutes: 0, seconds: 0);
  int _selectedKm = 0;
  int _selectedDecimal = 0;
  bool _showDatePicker = false;
  bool _showDurationPicker = false;
  bool _showDistancePicker = false;

  void _selectTime(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: _selectedTime,
    ).then((picked) {
      if (picked != null && picked != _selectedTime) {
        setState(() {
          _selectedTime = picked;
        });
      }
    });
  }

  void _toggleDatePicker() {
    setState(() {
      _showDatePicker = !_showDatePicker;
      _showDurationPicker = false;
      _showDistancePicker = false;
    });
  }

  void _toggleDurationPicker() {
    setState(() {
      _showDurationPicker = !_showDurationPicker;
      _showDatePicker = false;
      _showDistancePicker = false;
    });
  }

  void _toggleDistancePicker() {
    setState(() {
      _showDistancePicker = !_showDistancePicker;
      _showDatePicker = false;
      _showDurationPicker = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'RUNGUARD'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300, 
                  child: OutlinedButton(
                    onPressed: _toggleDatePicker,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      side: BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      'Selecionar Data: ${_formatDate(_selectedDate)}',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                ),
                if (_showDatePicker)
                  SfDateRangePicker(
                    initialSelectedDate: _selectedDate,
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      setState(() {
                        _selectedDate = args.value;
                      });
                    },
                  ),
                SizedBox(height: 10.0),
                SizedBox(
                  width: 300,
                  child: OutlinedButton(
                    onPressed: () => _selectTime(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      side: BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      'Selecionar Hora: ${_selectedTime.format(context)}',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                SizedBox(
                  width: 300,
                  child: OutlinedButton(
                    onPressed: _toggleDurationPicker,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      side: BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      'Selecionar Duração: ${_selectedDuration.inHours}h ${_selectedDuration.inMinutes % 60}m ${_selectedDuration.inSeconds % 60}s',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                ),
                if (_showDurationPicker)
                  CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hms,
                    initialTimerDuration: _selectedDuration,
                    onTimerDurationChanged: (Duration newDuration) {
                      setState(() {
                        _selectedDuration = newDuration;
                      });
                    },
                  ),
                SizedBox(height: 10.0),
                SizedBox(
                  width: 300,
                  child: OutlinedButton(
                    onPressed: _toggleDistancePicker,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      side: BorderSide(color: Colors.black),
                    ),
                    child: Text(
                      'Selecionar Distância: $_selectedKm.${_selectedDecimal} km',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                ),
                if (_showDistancePicker)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 150,
                        child: CupertinoPicker(
                          itemExtent: 32.0,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              _selectedKm = index;
                            });
                          },
                          children: List<Widget>.generate(100, (int index) {
                            return Center(
                              child: Text(index.toString()),
                            );
                          }),
                        ),
                      ),
                      Text('.'),
                      Container(
                        width: 80,
                        height: 150,
                        child: CupertinoPicker(
                          itemExtent: 32.0,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              _selectedDecimal = index;
                            });
                          },
                          children: List<Widget>.generate(10, (int index) {
                            return Center(
                              child: Text(index.toString()),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      final distance = _selectedKm + _selectedDecimal / 10.0;
                      final dateTime = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );

                      context.read<AuthService>().addRun(dateTime, distance, _selectedDuration);
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
                      'Adicionar Corrida',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
