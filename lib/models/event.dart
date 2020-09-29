import 'package:flutter/foundation.dart';

class Event1 {
  Event1({
    @required this.name,
    @required this.time,
    @required this.date,
    @required this.venue,
  });

  factory Event1.fromList(List<dynamic> list) {
    return Event1(
        name: list[0].toString(),
        time: list[1].toString(),
        date: list[2].toString(),
        venue: list[3].toString());
  }

  factory Event1.fromOnlineBackend(dynamic event) {
    List<String> dateTodayList = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).toString().substring(0, 10).split('-');
    final dateToday =
        dateTodayList[2] + '-' + dateTodayList[1] + '-' + dateTodayList[0];
    return Event1(
      name: event["EventName"],
      time: event["Time"] ?? "Not mentioned",
      date: dateToday,
      venue: "Online",
    );
  }

  factory Event1.fromMap(dynamic json) {
    return Event1(
        name: json['name'],
        time: json['time'],
        date: json['date'],
        venue: json['venue']);
  }

  Map<String, String> toMap() {
    return <String, String>{
      'name': name,
      'time': time,
      'date': date,
      'venue': venue
    };
  }

  String name;
  String time;
  String date;
  String venue;
}
