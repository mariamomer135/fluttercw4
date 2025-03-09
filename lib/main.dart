import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
// Mariam Omer Cw4
void main() {
  runApp(AdoptionTravelApp());
}

class AdoptionTravelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoption & Travel Plans',
      theme: ThemeData(
        primaryColor: Colors.pink[200],
        scaffoldBackgroundColor: Colors.green[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink[200],
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.pink[200],
        ),
      ),
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _createPlan(String name, String description, DateTime date) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date));
      plans.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  void _showCreatePlanDialog() {
    String name = '';
    String description = '';
    DateTime selectedDate = _selectedDay;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _createPlan(name, description, selectedDate);
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _toggleComplete(Plan plan) {
    setState(() {
      plan.isCompleted = !plan.isCompleted;
    });
  }

  void _editPlan(Plan plan) {
    String name = plan.name;
    String description = plan.description;
    DateTime selectedDate = plan.date;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: name),
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                controller: TextEditingController(text: description),
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  plan.name = name;
                  plan.description = description;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _deletePlan(Plan plan) {
    setState(() {
      plans.remove(plan);
    });
  }

  Color _getPlanColor(Plan plan) {
    final today = DateTime.now();
    final isOverdue = plan.date.isBefore(DateTime(today.year, today.month, today.day));
    
    if (plan.isCompleted) {
      return Colors.green[300]!;
    } else if (isOverdue) {
      return Colors.red[300]!;
    } else {
      return Colors.yellow[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adoption & Travel Plans'),
            Text(
              'Tap to complete, swipe to delete, long press to edit, double tap to delete',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.pink[200],
                shape: BoxShape.circle,
              ),
            ),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                
                return isSameDay(plan.date, _selectedDay)
                    ? Dismissible(
                        key: Key(plan.name),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) => _deletePlan(plan),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: GestureDetector(
                          onTap: () => _toggleComplete(plan),
                          onLongPress: () => _editPlan(plan),
                          onDoubleTap: () => _deletePlan(plan),
                          child: Card(
                            color: _getPlanColor(plan),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              title: Text(
                                plan.name,
                                style: TextStyle(decoration: plan.isCompleted ? TextDecoration.lineThrough : null),
                              ),
                              subtitle: Text(plan.description),
                            ),
                          ),
                        ),
                      )
                    : Container();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlanDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
