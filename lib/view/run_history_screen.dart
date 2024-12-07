import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:i_love_my_girlfriend/view/header.dart';
import 'package:i_love_my_girlfriend/modelservices/services/auth_service.dart';

class RunHistoryScreen extends StatefulWidget {
  @override
  _RunHistoryScreenState createState() => _RunHistoryScreenState();
}

class _RunHistoryScreenState extends State<RunHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  late TooltipBehavior _tooltipBehavior;
  final ScrollController _scrollController = ScrollController();
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  void _onDateRangeChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _startDate = args.value.startDate;
      _endDate = args.value.endDate;
    });
  }

  bool _dateInRange(DateTime dataCorrida) {
    if (_startDate == null || _endDate == null) return true;
    return dataCorrida.isAfter(_startDate!) && dataCorrida.isBefore(_endDate!);
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  void _showRunDetails(BuildContext context, Map<String, dynamic> run, int index, List<Map<String, dynamic>> runs) {
    final dateTime = run['date'] as DateTime;
    final data = run['data'] as Map<String, dynamic>;
    final durationParts = data['duration'].split(':');
    final duration = Duration(
      hours: int.parse(durationParts[0]),
      minutes: int.parse(durationParts[1]),
      seconds: int.parse(durationParts[2].split('.')[0]),
    );
    final distance = data['distance'].toDouble();
    final pace = duration.inMinutes / distance;
    final speed = (distance * 1000) / duration.inSeconds * 3.6;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes da Corrida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${dateTime.toLocal().toString().split(' ')[0]}'),
            Text('Distância: ${distance} km'),
            Text('Tempo: ${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s'),
            Text('Pace: ${pace.toStringAsFixed(2)} min/km'),
            Text('Velocidade: ${speed.toStringAsFixed(2)} km/h'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/editRun',
                arguments: {
                  'runId': run['id'],
                  'runData': data,
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await context.read<AuthService>().deleteRun(run['id']);
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () {
              Navigator.pop(context);
              _scrollToIndex(index);
            },
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _scrollToIndex(int index) {
    setState(() {
      _expandedIndex = index;
    });
    _scrollController.animateTo(
      index * 150.0, // Estimativa da altura do item na lista
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'RUNGUARD'), // Usar CustomAppBar
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Versão 1.0',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () async {
                await context.read<AuthService>().signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suas corridas',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Container(
                                width: 300,
                                height: 400,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SingleChildScrollView(
                                      child: SfDateRangePicker(
                                        onSelectionChanged: _onDateRangeChanged,
                                        selectionMode: DateRangePickerSelectionMode.range,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _startDate = null;
                                              _endDate = null;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Resetar Filtro'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: _resetFilters,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text('Limpar Filtro', style: TextStyle(fontSize: 16.0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: context.read<AuthService>().getRuns(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final runs = snapshot.data!.docs
                    .map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final dateTime = DateTime.parse(data['time']);
                      return {
                        'date': dateTime,
                        'distance': data['distance'].toDouble(),
                        'duration': data['duration'],
                        'data': data,
                        'id': doc.id,
                      };
                    })
                    .where((run) => _dateInRange(run['date']))
                    .toList();

                runs.sort((a, b) => a['date'].compareTo(b['date']));

                final totalActivities = runs.length;
                final totalDistance = runs.fold(0.0, (sum, run) => sum + run['distance']);
                final totalDuration = runs.fold(Duration.zero, (sum, run) {
                  final parts = run['duration'].split(':');
                  final duration = Duration(
                    hours: int.parse(parts[0]),
                    minutes: int.parse(parts[1]),
                    seconds: int.parse(parts[2].split('.')[0]),
                  );
                  return sum + duration;
                });

                String formatDuration(Duration duration) {
                  String twoDigits(int n) => n.toString().padLeft(2, '0');
                  String hours = twoDigits(duration.inHours);
                  String minutes = twoDigits(duration.inMinutes.remainder(60));
                  String seconds = twoDigits(duration.inSeconds.remainder(60));
                  return "$hours:$minutes:$seconds";
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 300, 
                        child: SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            title: AxisTitle(text: 'Data'),
                            minimum: _startDate, 
                            maximum: _endDate, 
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: 'Distância (km)'), 
                          ),
                          tooltipBehavior: _tooltipBehavior,
                          series: <CartesianSeries>[
                            LineSeries<Map<String, dynamic>, DateTime>(
                              dataSource: runs,
                              xValueMapper: (Map<String, dynamic> run, _) => run['date'],
                              yValueMapper: (Map<String, dynamic> run, _) => run['distance'],
                              enableTooltip: true,
                              width: 2, 
                              color: Colors.blue,
                            ),
                            ScatterSeries<Map<String, dynamic>, DateTime>(
                              dataSource: runs,
                              xValueMapper: (Map<String, dynamic> run, _) => run['date'],
                              yValueMapper: (Map<String, dynamic> run, _) => run['distance'],
                              markerSettings: MarkerSettings(
                                isVisible: true, 
                                color: Colors.blue,
                                height: 6, 
                                width: 6,
                              ),
                              onPointTap: (ChartPointDetails details) {
                                _showRunDetails(context, runs[details.pointIndex!], details.pointIndex!, runs);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.blue, width: 1),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumo das Corridas',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.directions_run, size: 40, color: Colors.blue),
                                    SizedBox(height: 8.0),
                                    Text('$totalActivities'),
                                    Text('Atividades'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(Icons.map, size: 40, color: Colors.blue),
                                    SizedBox(height: 8.0),
                                    Text('${totalDistance.toStringAsFixed(2)} km'),
                                    Text('Distância'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(Icons.access_time, size: 40, color: Colors.blue),
                                    SizedBox(height: 8.0),
                                    Text('${formatDuration(totalDuration)}'),
                                    Text('Tempo'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: runs.length,
                        itemBuilder: (context, index) {
                          final run = runs[index];
                          final data = run['data'] as Map<String, dynamic>;
                          final dateTime = run['date'] as DateTime;
                          final durationParts = data['duration'].split(':');
                          final duration = Duration(
                            hours: int.parse(durationParts[0]),
                            minutes: int.parse(durationParts[1]),
                            seconds: int.parse(durationParts[2].split('.')[0]),
                          );
                          final distance = data['distance'].toDouble();
                          final pace = duration.inMinutes / distance;
                          final speed = (distance * 1000) / duration.inSeconds * 3.6;

                          final mediaVelocidade = totalDistance == 0
                              ? 0
                              : (totalDistance * 1000) / totalDuration.inSeconds * 3.6;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(color: Colors.grey, width: 1),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ExpansionTile(
                              initiallyExpanded: _expandedIndex == index,
                              title: Text(
                                'Data: ${dateTime.toLocal().toString().split(' ')[0]} - Distância: ${distance} km',
                              ),
                              children: [
                                ListTile(
                                  title: Text(
                                      'Hora: ${dateTime.toLocal().hour}:${dateTime.toLocal().minute} - Duração: ${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s'),
                                  subtitle: Text(
                                      'Pace: ${pace.toStringAsFixed(2)} min/km - Velocidade: ${speed.toStringAsFixed(2)} km/h'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/editRun',
                                            arguments: {
                                              'runId': run['id'],
                                              'runData': data,
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          await context.read<AuthService>().deleteRun(run['id']);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SfCartesianChart(
                                    primaryXAxis: CategoryAxis(
                                      title: AxisTitle(text: 'Categoria Velocidade'),
                                    ),
                                    primaryYAxis: NumericAxis(
                                      title: AxisTitle(text: 'Velocidade (km/h)'),
                                    ),
                                    legend: Legend(
                                      isVisible: true,
                                      position: LegendPosition.bottom,
                                      alignment: ChartAlignment.center,
                                      // Customização da legenda
                                      iconHeight: 10,
                                      iconWidth: 10,
                                      textStyle: TextStyle(fontSize: 12),
                                    ),
                                    series: <CartesianSeries>[
                                      ColumnSeries<ChartData, String>(
                                        dataSource: [
                                          ChartData('Corrida', speed, Colors.orange),
                                          ChartData('Média', mediaVelocidade.toDouble(), Colors.green),
                                        ],
                                        xValueMapper: (ChartData data, _) => data.category,
                                        yValueMapper: (ChartData data, _) => data.value,
                                        pointColorMapper: (ChartData data, _) => data.color,
                                        name: 'Velocidade',
                                        dataLabelSettings: DataLabelSettings(isVisible: true),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addRun');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Change icon color to black
      ),
    );
  }
}

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}
