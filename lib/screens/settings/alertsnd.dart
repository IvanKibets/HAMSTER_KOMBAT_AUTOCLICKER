import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Alertsnd extends StatefulWidget {
  @override
  State<Alertsnd> createState() => _AlertsndState();
}

class _AlertsndState extends State<Alertsnd> {
  String? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alert all'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Select Your City",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 300,
              child: DropdownButton<String>(
                icon: Padding(
                  padding: const EdgeInsets.only(left: 80.0),
                  child: Icon(Icons.arrow_drop_down),
                ),
                value: selectedCity,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCity = newValue;
                  });
                },
                items: <String>[
                  'Alappuzha',
                  'Ernakulam',
                  'Idukki',
                  'Kannur',
                  'Kasaragod',
                  'Kollam',
                  'Kottayam',
                  'Kozhikode',
                  'Malappuram',
                  'Palakkad',
                  'Pathanamthitta',
                  'Thiruvananthapuram',
                  'Thrissur',
                  'Wayanad',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                sendPushMessageToGroup(
                    'Be Vigilant ⚠', 'be vigilant you are gonna die', context);
              },
              child: Text('Send Notification to All'),
            ),
          ],
        ),
      ),
    );
  }
}

void sendPushMessageToGroup(
    String title, String body, BuildContext context) async {
  try {
    QuerySnapshot<Map<String, dynamic>> tokenSnapshot =
        await FirebaseFirestore.instance.collection('tokens').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> tokenDoc
        in tokenSnapshot.docs) {
      String token = tokenDoc.data()['token'];
      sendPushMessage(token, title, body);
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert Sent"),
          content: Text("Alert sent successfully to all "),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    print('Push messages sent successfully to all tokens');
  } catch (e) {
    print('Error sending push messages: $e');
  }
}

void sendPushMessage(String token, String body, String title) async {
  try {
    final response =
        await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: <String, String>{
              'Content-type': 'application/json',
              'Authorization':
                  'key=AAAA3AyJCqs:APA91bEQ5TNWxC0l7k0RklOvCaz67mbIZdJi-XawcW4eUODY-MLstynVN8CkrLDXbGSMABzhjI6mLKF5BLGCb03jJLScdc5z023qlLKhDvsxB5urB4du-RB0brp1_9xjjJa6vFu1BkVE',
            },
            body: jsonEncode(<String, dynamic>{
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'body': body,
                'title': title,
              },
              "notification": <String, dynamic>{
                "title": title,
                "body": body,
              },
              "to": token
            }));
    if (response.statusCode == 200) {
      print("Message sent");
    } else {
      print("Error sending push notification: ${response.statusCode}");
      print(response.body);
    }
  } catch (e) {
    print("Error in push notification: $e");
  }
}
