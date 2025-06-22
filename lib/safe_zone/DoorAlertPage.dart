import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SmartDoorBraceletPage extends StatefulWidget {
  @override
  _SmartDoorBraceletPageState createState() => _SmartDoorBraceletPageState();
}

class _SmartDoorBraceletPageState extends State<SmartDoorBraceletPage>
    with SingleTickerProviderStateMixin {
  bool _isDoorOpen = false;
  bool _isWearingBracelet = true;
  late DatabaseReference _databaseRef;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _databaseRef = FirebaseDatabase.instance.ref('bracelet_sensors/braclet_01');
    _setupRealTimeUpdates();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );

    _controller.forward();
  }

  void _setupRealTimeUpdates() {
    _databaseRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        if (mounted) {
          setState(() {
            _isDoorOpen = data['status-port'] == "Porte ouverte";
            _isWearingBracelet = data['is_wearing'] == true;
          });
          _controller.reset();
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _databaseRef.onValue.drain();
    super.dispose();
  }

  Widget _buildSmartDoor() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Door Frame
            Container(
              width: 180,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.brown[800],
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Door Panel
            Transform(
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_isDoorOpen ? -_animation.value * 0.5 : 0),
              alignment: Alignment.centerLeft,
              child: Container(
                width: 160,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.brown[600],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: _isDoorOpen ? _buildDoorInternalComponents() : null,
              ),
            ),

            // Door Handle
            Positioned(
              right: 30,
              child: Transform(
                transform:
                    Matrix4.identity()..translate(_isDoorOpen ? -20.0 : 0.0),
                child: Container(
                  width: 10,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.brown[900],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDoorInternalComponents() {
    return Column(
      children: [
        SizedBox(height: 20),
        // Smart Lock Mechanism
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Icon(Icons.lock_open, color: Colors.white, size: 20),
          ),
        ),
        SizedBox(height: 10),
        // Sensor Array
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSensorDot(Colors.red),
            _buildSensorDot(Colors.green),
            _buildSensorDot(Colors.blue),
          ],
        ),
        SizedBox(height: 10),
        // Wiring
        Container(width: 120, height: 4, color: Colors.grey[400]),
        SizedBox(height: 5),
        // Control Board
        Container(
          width: 100,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              'IoT v2.1',
              style: TextStyle(color: Colors.green, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorDot(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.8), blurRadius: 8)],
      ),
    );
  }

  Widget _buildSmartBracelet() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _isWearingBracelet = !_isWearingBracelet;
              _controller.reset();
              _controller.forward();
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Bracelet Body
              Transform(
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(_animation.value * 0.2)
                      ..rotateZ(_animation.value * 0.1),
                child: Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isWearingBracelet ? Colors.blue[800] : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child:
                      _isWearingBracelet
                          ? null
                          : _buildBraceletInternalComponents(),
                ),
              ),

              // Wear Status Indicator
              if (_isWearingBracelet)
                Icon(Icons.medical_services, size: 40, color: Colors.white),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBraceletInternalComponents() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Heart Rate Sensor
        Container(
          width: 50,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.red[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(Icons.favorite, color: Colors.white, size: 12),
          ),
        ),
        SizedBox(height: 5),
        // Circuit Board
        Container(
          width: 80,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              'HR v3.4',
              style: TextStyle(color: Colors.green, fontSize: 10),
            ),
          ),
        ),
        SizedBox(height: 5),
        // Battery
        Container(
          width: 30,
          height: 15,
          decoration: BoxDecoration(
            color: Colors.green[800],
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Smart Door & Bracelet'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                _buildSmartDoor(),
                SizedBox(height: 20),
                Text(
                  _isDoorOpen ? 'PORTE OUVERTE' : 'PORTE FERMÉE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isDoorOpen ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                _buildSmartBracelet(),
                SizedBox(height: 20),
                Text(
                  _isWearingBracelet ? 'BRACELET PORTÉ' : 'BRACELET ENLEVÉ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isWearingBracelet ? Colors.green : Colors.red,
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
