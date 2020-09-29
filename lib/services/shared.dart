import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/event.dart';

SharedPreferences prefs;

class Shared {

  static Future<SharedPreferences> initShared() async {
    prefs=await SharedPreferences.getInstance();
    print('Shared Preferences initialized!');
    return Future.value(prefs);
  }

  static void storeUser(User user) {
    prefs.setString('user', json.encode(user.toMap()));
    print('User Set!');
  }

  static Future<User> getUser() {
    return Future.value(User.fromJson(json.decode(prefs.getString('user'))));
  }

  static Future<List<dynamic>> getEvents() {
    print('Events fetched!');
    String events=prefs.getString('events');
    if(events==null) {
      return Future.value([]);
    }
    return Future.value(json.decode(events));
  }

  static Future<void> setEvents(List<dynamic> events) {
    print('Events set!');
    List<Map<String, String>> eventsMap=[];
    for(int i=0;i<events.length;i++) {
      eventsMap.add(events[i].toMap());
    }
    return Future.value(prefs.setString('events', json.encode(eventsMap)));
  }

  static void setLastSaved(String date) {
    prefs.setString('lastSaved', date);
  }
  
  static Future<String> getLastSaved() {
    return Future.value(prefs.getString('lastSaved'));
  }
}
