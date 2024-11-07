import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';
import './gallery_screen.dart'; 
import 'view_gallery_screen.dart'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Dashboard extends StatefulWidget {
  final VoidCallback toggleTheme;

  Dashboard({required this.toggleTheme});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Contact> _contacts = [];
  ConnectivityResult? _connectivityStatus;
  int? _batteryLevel;
  bool _isBluetoothAvailable = false;
  final Battery _battery = Battery();
  final FlutterBluePlus _flutterBlue = FlutterBluePlus();

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _initConnectivity();
    _initBatteryStatus();
    _checkBluetoothAvailability();
  }

  // Request permission to access contacts
  Future<void> _requestPermission() async {
    final permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      _fetchContacts();
    } else {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Permission to access contacts denied.'),
      ));
    }
  }

  // Fetch contacts from the phone
  Future<void> _fetchContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.toList();
    });
  }

  // Initialize connectivity status
  Future<void> _initConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityStatus = connectivity;
    });
  }

  // Initialize battery status
  Future<void> _initBatteryStatus() async {
    final batteryLevel = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  // Check Bluetooth availability
  Future<void> _checkBluetoothAvailability() async {
    final isAvailable = await FlutterBluePlus.isOn;
    setState(() {
      _isBluetoothAvailable = isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          IconButton(
            icon: Icon(Icons.wifi),
            onPressed: _initConnectivity,
          ),
          IconButton(
            icon: Icon(Icons.battery_full),
            onPressed: _initBatteryStatus,
          ),
          IconButton(
            icon: Icon(Icons.bluetooth),
            onPressed: _checkBluetoothAvailability,
          ),
          IconButton(
            icon: Icon(Icons.contacts),
            onPressed: () {
              // Show contacts list when contact icon is tapped
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Contacts'),
                    content: Container(
                      width: double.maxFinite,
                      height: 300,
                      child: ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          return ListTile(
                            title: Text(contact.displayName ?? 'No Name'),
                            subtitle: contact.phones?.isNotEmpty == true
                                ? Text(contact.phones!.first.value ?? 'No Phone')
                                : null,
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 20),

            // Display Connectivity, Battery, and Bluetooth Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.wifi,
                      color: _connectivityStatus == ConnectivityResult.none
                          ? Colors.red
                          : Colors.green,
                    ),
                    Text(_connectivityStatus == ConnectivityResult.none
                        ? 'No Connection'
                        : 'Connected'),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.battery_full,
                      color: _batteryLevel != null && _batteryLevel! > 20
                          ? Colors.green
                          : Colors.red,
                    ),
                    Text(_batteryLevel != null ? '$_batteryLevel%' : 'Loading...'),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.bluetooth,
                      color: _isBluetoothAvailable ? Colors.blue : Colors.grey,
                    ),
                    Text(_isBluetoothAvailable ? 'Available' : 'Unavailable'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Monthly Summary Chart
            Expanded(
              flex: 2,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Monthly Expenses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  FlSpot(1, 50),
                                  FlSpot(2, 100),
                                  FlSpot(3, 75),
                                  FlSpot(4, 200),
                                  FlSpot(5, 180),
                                  FlSpot(6, 250),
                                  FlSpot(7, 210),
                                ],
                                isCurved: true,
                                color: Colors.blueAccent,
                                barWidth: 4,
                                belowBarData: BarAreaData(show: false),
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Quick Action Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddExpenseScreen()),
                      );
                    },
                    child: Card(
                      color: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.add_circle, size: 50, color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              'Add Expense',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExpenseListScreen()),
                      );
                    },
                    child: Card(
                      color: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.list, size: 50, color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              'View Expenses',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Add Gallery and View Gallery Buttons
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ImageGalleryScreen()),
                      );
                    },
                    child: Card(
                      color: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              'Add Gallery',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewGalleryScreen()),
                      );
                    },
                    child: Card(
                      color: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library, size: 50, color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              'View Gallery',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
