import 'dart:convert';
import 'dart:io' as IO;
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'onGoingEvents.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../services/shared.dart';
import '../widgets/loading.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    @required this.mode,
  });

  final String mode;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String webAPIKey = '', ocrAPIKey = '';
  final List<Tab> myTabs = <Tab>[
    Tab(
      child: Text(
        'Ongoing',
        style: TextStyle(),
      ),
    ),
    Tab(
      child: Text(
        'Past',
        style: TextStyle(),
      ),
    ),
  ];

  TabController _tabController;
  String url = "http://13.229.108.95";
  String url1 = "https://vitevents.herokuapp.com";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _initializePage();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  List<dynamic> messagesMeta, attachmentIds = [], attachments = [], events = [];
  User user;
  String fromString = 'director.sw@vit.ac.in';
  String progressText = '';
  String dateToday =
      (DateTime(DateTime.now().day, DateTime.now().month, DateTime.now().year))
          .toString()
          .substring(0, 10);
  bool pass = true;
  List<bool> progressList = [false, false, false, false];

  void _initializePage() async {
    webAPIKey = DotEnv().env['WEB_API_KEY'];
    ocrAPIKey = DotEnv().env['OCR_API_KEY'];
    String lastDate = await Shared.getLastSaved();
    List<String> dateTodayList = [];
    dateTodayList.add(dateToday[2]);
    dateTodayList.add(dateToday[1]);
    dateTodayList.add(dateToday[0]);
    List<dynamic> eventsList = [];
    eventsList = await Shared.getEvents();
    if (eventsList.length != 0) {
      if (lastDate != null) {
        List<String> lastDateList = lastDate.split('-');
        List<String> dateTodayList = dateToday.split('-');
        if ((int.parse(lastDateList[0]) == int.parse(dateTodayList[0]) &&
            int.parse(lastDateList[1]) == int.parse(dateTodayList[1]))) {
          print('Not fetching because fetched today only.');
          setState(() {
            pass = false;
          });
          return;
        }
      }
    }
    if (widget.mode == "online") {
      setState(() {
        progressList[0] = true;
      });
      getOnlineEvents();
      return;
    }
    user = await Shared.getUser();
    messagesMeta = await getMessageIds();
    await getMessageContents();
    await getAttachments();
    await sendToServer();
    Shared.setEvents(events);
    Shared.setLastSaved(dateToday);
    setState(() {
      pass = false;
    });
  }

  Future<void> getOnlineEvents() async {
    setState(() {
      progressList[1] = true;
    });
    List<String> dateTodayList = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).toString().substring(0, 10).split('-');
    setState(() {
      progressList[2] = true;
    });
    final dateToday =
        dateTodayList[2] + '-' + dateTodayList[1] + '-' + dateTodayList[0];
    print(dateToday);
    http.Response response1 = await http.get(
        'https://shielded-beyond-17845.herokuapp.com/event?date=' + dateToday);
    setState(() {
      progressList[3] = true;
    });
    print(response1.body);
    final eventsResp = response1.body;
    final eventsRespList = json.decode(eventsResp)["Events"];
    for (int i = 0; i < eventsRespList.length; i++) {
      events.add(Event1.fromOnlineBackend(eventsRespList[i]));
    }
    Shared.setEvents(events);
    Shared.setLastSaved(dateToday);
    setState(() {
      pass = false;
    });
  }

  Future<void> sendToServer() async {
    attachments = ['a'];
    for (int i = 0; i < attachments.length; i++) {
      print('Call 1');
      http.Response response1 =
          await http.post('$url1/cropb64', body: attachments[i]);

      print(response1.statusCode);

      if (json.decode(response1.body)['status'] == 'fail') {
        continue;
      }

      print('Call 1 Done');
      dynamic decodedBytes = base64Decode(json.decode(response1.body)['img']);
      final dir = await getApplicationDocumentsDirectory();
      dynamic path = dir.path;

      dynamic file = IO.File('$path/eventsApp$i.png');
      file.writeAsBytesSync(decodedBytes);
      print(file.path);

      print('Call 2');
      Map<String, String> headers = {'apikey': ocrAPIKey};
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://api.ocr.space/parse/image'))
        ..fields['language'] = 'eng'
        ..fields['isOverlayRequired'] = 'true'
        ..fields['isTable'] = 'false'
        ..fields['OCREngine'] = '1';

      var imgFile =
          await http.MultipartFile.fromPath('file', '$path/eventsApp$i.png');
      request.files.add(imgFile);
      request.headers.addAll(headers);
      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      print(response.statusCode);

      print('Call 2 Done');

      print('Call 3');
      http.Response response3 =
          await http.post('$url1/getTable', body: respStr);

      print(response3.statusCode);
      List<dynamic> eventsList = json.decode(response3.body)['events'];

      if (json.decode(response3.body)['status'] == 'fail') {
        continue;
      }

      print('Call 3 Done');

      List<String> dateTodayList1 = ((DateTime(DateTime.now().year,
                  DateTime.now().month, DateTime.now().day))
              .toString()
              .substring(0, 10))
          .split('-');
      List<String> dateTodayList = [];
      dateTodayList.add(dateTodayList1[2]);
      dateTodayList.add(dateTodayList1[1]);
      dateTodayList.add(dateTodayList1[0]);
      for (int j = 0; j < eventsList.length; j++) {
        List<String> dateList = (eventsList[j][2].toString()).split('-');
        if ((int.parse(dateList[2]) < int.parse(dateTodayList[2]))) {
          print('Year is less!');
        } else if ((int.parse(dateList[2]) > int.parse(dateTodayList[2]))) {
          print('${eventsList[j]} can be included.');
        } else {
          if (!((int.parse(dateList[0]) < int.parse(dateTodayList[0])) &&
              (int.parse(dateList[1]) <= int.parse(dateList[1])))) {
            print('${eventsList[j]} can be included.');
            events.add(Event1.fromList(eventsList[j]));
          } else {
            print('Event cannot be included!');
          }
        }
        events.add(Event1.fromList(eventsList[j]));
      }
    }
    setState(() {
      progressList[3] = true;
    });
    return Future.value();
  }

  Future<void> getAttachments() async {
    for (int i = 0; i < attachmentIds.length; i++) {
      print(attachmentIds[i]);
      http.Response response1 = await http.get(
          'https://www.googleapis.com/gmail/v1/users/' +
              user.userId +
              '/messages/${attachmentIds[i]['messageId']}/attachments/${attachmentIds[i]['attachmentId']}?key=$webAPIKey',
          headers: {
            "Authorization": "Bearer" + " " + user.token,
          });

      //print(response1.body);
      attachments.add(json
          .decode(response1.body)['data']
          .replaceAll('_', '/')
          .replaceAll('-', '+'));
      if (response1.statusCode == 200) {
        setState(() {
          progressText += 'Attachment $i\'s ID retrieved';
          progressText += response1.body;
        });
      }
    }

    setState(() {
      progressList[2] = true;
    });

    print('Attachments fetched!');
  }

  Future<List<dynamic>> getMessageContents() async {
    print('In getMessageContents');
    for (int i = 0; i < messagesMeta.length; i++) {
      print('i: $i');
      http.Response response = await http.get(
          'https://www.googleapis.com/gmail/v1/users/' +
              user.userId +
              '/messages/${messagesMeta[i]['id']}?key=$webAPIKey&q=from:daily\ events',
          headers: {
            "Authorization": "Bearer" + " " + user.token,
          });
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          progressText += 'Message contents fetched. ';
          progressText += response.body;
        });
      }

      dynamic parts = json.decode(response.body)['payload']['parts'];
      RegExp regExp = new RegExp('[0-9]{2}.[0-9]{2}.[0-9]{4}');
      for (int j = 0; j < parts.length; j++) {
        if (!(regExp.hasMatch(parts[j]['filename']) &&
            parts[j]['filename'].length <= 14)) {
          print('Not maching: ${parts[j]['filename']}');
          continue;
        }
        if (parts[j]['body']['attachmentId'] == null) {
          continue;
        }
        attachmentIds.add({
          'messageId': messagesMeta[i]['id'],
          'attachmentId': parts[j]['body']['attachmentId']
        });
      }
      if (i == 0) {
        break;
      }
    }
    print(attachmentIds.toSet().toList().length);
    print('Message contents fetched!');

    setState(() {
      progressList[1] = true;
    });

    return Future.value();
  }

  Future<List<dynamic>> getMessageIds() async {
    http.Response response = await http.get(
        'https://www.googleapis.com/gmail/v1/users/' +
            user.userId +
            '/messages?key=$webAPIKey&q=subject:daily\ events',
        headers: {
          "Authorization": "Bearer" + " " + user.token,
        });
    print(response.statusCode);
    setState(() {
      progressList[0] = true;
    });
    return Future.value(json.decode(response.body)['messages']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events',
          style: TextStyle(
            fontSize: 48.0,
            color: Color(0xff1abc9c),
          ),
        ),
        centerTitle: true,
        leading: Container(),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: (pass)
          ? Container(
              child: Center(
              child: LoadingWidget(progressList: progressList),
            ))
          : OngoingEventsPage(mode: "online"),
    );
  }
}
