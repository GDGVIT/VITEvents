import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
//import 'package:http/http.dart' as http;
import 'package:add_2_calendar/add_2_calendar.dart' as prefix;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/shared.dart';
import '../models/user.dart';
import '../models/event.dart';

class OngoingEventsPage extends StatefulWidget {
  final String mode;

  const OngoingEventsPage({Key key, @required this.mode}) : super(key: key);

  _OngoingEventsPageState createState() => _OngoingEventsPageState();
}

class _OngoingEventsPageState extends State<OngoingEventsPage> {
  User user;
  List<bool> checkList = [], searchedCheckList = [];
  List<dynamic> events = [], eventsList = [], searchedEvents = [];
  DeviceCalendarPlugin _deviceCalendarPlugin = new DeviceCalendarPlugin();
  List<Calendar> _calendars;
  Calendar _calendar;
  String calendarId = '', timeZone = '', webAPIKey = '';

  TextEditingController _searchController = new TextEditingController();
  bool search = false, allSelected = false, _loading = false;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() async {
    webAPIKey = DotEnv().env['WEB_API_KEY'];
    //user = await Shared.getUser();
    //if(widget.mode != "online") {
    //  user = await Shared.getUser();
    //}
    eventsList = await Shared.getEvents();
    for (int i = 0; i < eventsList.length; i++) {
      events.add(Event1.fromMap(eventsList[i]));
    }
    setState(() {});
  }

  _showDialog(String content) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              content,
              style: TextStyle(fontSize: 18.0),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<bool> _addToCalendar(
      List<dynamic> eventslist, List<bool> checklist) async {
    setState(() {
      _loading = true;
    });
    bool flag = false, isError = false;
    if (eventslist.length == 0) {
      _showDialog('No events to be added');
      setState(() {
        _loading = false;
      });
      return false;
    }

    //if (_calendar == null) {
    //  _showDialog('No calendar detected');
    //  setState(() {
    //    _loading = false;
    //  });
    //  return false;
    //}

    for (int i = 0; i < eventslist.length; i++) {
      if (checklist[i]) {
        flag = true;
        List<String> dateList = eventslist[i].date.split('-');
        if (widget.mode == "online") {
          if (eventslist[i].time == "Not mentioned") {
            _showDialog('Time not provided!');
            continue;
          }
        }
        try {
          //final DateTime parsedTime = DateTime.parse(dateList[2] +
          //    '-' +
          //    dateList[1] +
          //    '-' +
          //    dateList[0] +
          //    ' ' +
          //    eventslist[i]['time'] +
          //    ':00');
          String startTime = dateList[2] +
              '-' +
              dateList[1] +
              '-' +
              dateList[0] +
              'T' +
              eventslist[i].time +
              ':00';
          String endTime = dateList[2] +
              '-' +
              dateList[1] +
              '-' +
              (int.parse(dateList[0])).toString() +
              'T' +
              eventslist[i].time +
              ':00';
          print(startTime);
          print(endTime);
          //final _event = Event(
          //  _calendar.id,
          //  title: eventslist[i]['name'],
          //  allDay: true,
          //  start: DateTime.parse(startTime),
          //  end: DateTime.parse(endTime),
          //);
          //print(_event);
          //var createEventResult =
          //    await _deviceCalendarPlugin.createOrUpdateEvent(_event);
          //if (!createEventResult.isSuccess) {
          //  _showDialog('Unable to add event(s)');
          //  break;
          //}

          print(eventslist[i]);
          final prefix.Event event = prefix.Event(
            title: eventslist[i].name,
            description: '',
            location: eventslist[i].venue,
            startDate: DateTime.parse(startTime),
            endDate: DateTime.parse(endTime),
          );

          final success = await prefix.Add2Calendar.addEvent2Cal(event);
          if (!success) {
            isError = true;
            _showDialog('Unable to add event(s)');
            break;
          } else {
            print("Done");
          }
        } catch (err) {
          print(err);
          _showDialog('Unable to add event(s)');
        }

        //Uri uri = Uri.parse(
        //    'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events?key=$webAPIKey');
        //http.Response response1 = await http.post(uri,
        //    headers: {
        //      'Content-type': 'application/json',
        //      "Authorization": "Bearer" + " " + user.token,
        //    },
        //    body: json.encode({
        //      "end": {"dateTime": endTime, "timeZone": timeZone},
        //      "start": {"dateTime": startTime, "timeZone": timeZone},
        //      "summary": eventslist[i]['name']
        //    }));
        //if (response1.statusCode == 200) {
        //  _showDialog('Event/s successfully added to the calendar');
        //  setState(() {
        //    _loading = false;
        //  });
        //  return Future.value(true);
        //} else {
        //  _showDialog('Save Failed');
        //  setState(() {
        //    _loading = false;
        //  });
        //  return Future.value(false);
        //}
      }
    }
    //if (eventslist.length == 0) {
    //  _showDialog('Event/s successfully added to the calendar');
    //
    if (!isError) {
      for (int i = 0; i < checkList.length; i++) {
        checkList[i] = false;
      }
      for (int i = 0; i < searchedCheckList.length; i++) {
        searchedCheckList[i] = false;
      }
      setState(() {});
      _showDialog('Event/s successfully directed to the calendar');
    }
    if (!flag) {
      _showDialog('No events selected');
    }
    setState(() {
      _loading = false;
    });
  }

  void _retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      setState(() {
        _calendars = calendarsResult?.data;
      });
      for (int i = 0; i < _calendars.length; i++) {
        if (_calendars[i].accountType == 'LOCAL') {
          _calendar = _calendars[i];
          print(_calendars[i].name);
        }
      }

      //http.Response response = await http.get(
      //    'https://www.googleapis.com/calendar/v3/users/me/calendarList?key=$webAPIKey',
      //    headers: {
      //      "Authorization": "Bearer" + " " + user.token,
      //    });
      //dynamic resp = jsonDecode(response.body)['items'];
      //for (int i = 0; i < resp.length; i++) {
      //  if (resp[i]['accessRole'] == 'owner') {
      //    calendarId = resp[i]['id'];
      //    timeZone = resp[i]['timeZone'];
      //    break;
      //  }
      //}
      search
          ? _addToCalendar(searchedEvents, searchedCheckList)
          : _addToCalendar(events, checkList);
    } catch (err) {
      print(err);
    }
  }

  Widget _eventCard(List<dynamic> eventsList, List<bool> checklist, int i) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 10.0, horizontal: MediaQuery.of(context).size.width * 0.1),
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'Name:',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff1ABC9C),
                            fontSize: 15.0),
                      ),
                    ),
                    Container(
                      child: Text(
                        eventsList[i].name,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'Date:',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff1ABC9C),
                            fontSize: 15.0),
                      ),
                    ),
                    Text(
                      eventsList[i].date,
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ],
                ),
                Wrap(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'Time',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff1ABC9C),
                            fontSize: 15.0),
                      ),
                    ),
                    Text(
                      eventsList[i].time,
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ],
                ),
                Wrap(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'Venue',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff1ABC9C),
                            fontSize: 15.0),
                      ),
                    ),
                    Text(
                      eventsList[i].venue,
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Theme(
                data: ThemeData(unselectedWidgetColor: Color(0xff1ABC9C)),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Checkbox(
                    value: checklist[i],
                    onChanged: (value) {
                      setState(() {
                        checklist[i] = !checklist[i];
                      });
                    },
                    checkColor: Color(0xff1ABC9C),
                    activeColor: Colors.white,
                    focusColor: Color(0xff1ABC9C),
                    hoverColor: Color(0xff1ABC9C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCards(int i) {
    if (events.length == i) {
      return SizedBox(
        height: 150,
      );
    }
    if (!(checkList.length == 0)) {
    } else {
      for (int j = 0; j < events.length; j++) {
        checkList.add(false);
      }
    }
    return _eventCard(events, checkList, i);
  }

  Widget _buildSearchCards(int i) {
    if (searchedEvents.length == i) {
      return SizedBox(height: 150);
    }
    return _eventCard(searchedEvents, searchedCheckList, i);
  }

  void _onSearchChange(String searchKey) {
    if (searchKey == '') {
      setState(() {
        search = false;
      });
      return;
    }
    searchedEvents = [];
    searchedCheckList = [];
    for (int i = 0; i < events.length; i++) {
      if (((events[i].name + events[i].time + events[i].date + events[i].venue)
              .toLowerCase())
          .contains(searchKey.toLowerCase())) {
        searchedEvents.add(events[i]);
        searchedCheckList.add(false);
      }
    }
    setState(() {
      search = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Theme(
                      data: Theme.of(context).copyWith(
                          accentColor: Color(0xff1ABC9C),
                          hintColor: Color(0xff1ABC9C)),
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChange,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: events.isEmpty
                          ? Container(
                              child: Center(
                                child: Text('No events to be shown!'),
                              ),
                            )
                          : ListView.builder(
                              itemCount: search
                                  ? searchedEvents.length + 1
                                  : events.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (!search) {
                                  return _buildCards(index);
                                } else {
                                  return _buildSearchCards(index);
                                }
                              },
                            ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width * 0.8,
                          child: FlatButton(
                            color: Color(0xff1ABC9C),
                            onPressed: () {
                              List<bool> checklist =
                                  search ? searchedCheckList : checkList;
                              for (int j = 0; j < checklist.length; j++) {
                                checklist[j] = true;
                              }
                              setState(() {});
                            },
                            child: Text(
                              //allSelected
                              //?
                              'Select All'
                              //:
                              //'Unselect All'
                              ,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        ButtonTheme(
                          minWidth: MediaQuery.of(context).size.width * 0.8,
                          child: FlatButton(
                            color: Color(0xff1ABC9C),
                            onPressed: () {
                              _retrieveCalendars();
                            },
                            child: Text(
                              'Add to Calendar',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
