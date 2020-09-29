import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in_all/google_sign_in_all.dart';

import '../services/shared.dart';
import '../models/user.dart';
import 'homePage.dart';

class LoginPage extends HookWidget {
  String id = '', name = '', token = '', webAPIKey = '';

  @override
  Widget build(BuildContext context) {

    webAPIKey = DotEnv().env['WEB_API_KEY'];

    final signIn = useMemoized(
      () => setupGoogleSignIn(scopes: [
        //'https://www.googleapis.com/auth/gmail.readonly',
        'https://www.googleapis.com/auth/calendar.events',
      ], webClientId: webAPIKey),
    );

    final accessToken = useState('');
    final username = useState('');
    final userid = useState('');

    final onSignIn = () async {
      //final credentials = await signIn.signIn();
      //final user = await signIn.getCurrentUser();

      //accessToken.value = credentials.accessToken;
      //username.value = user.displayName;
      //userid.value = user.id;

      //Shared.storeUser(User(
      //    userId: user.id,
      //    userName: user.displayName,
      //    token: credentials.accessToken));
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            mode: "online",
          ),
        ),
      );
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 0.0, bottom: 20.0),
                    child: Image.asset('assets/DSCLogo.png'),
                  ),
                  SizedBox(
                    height: 21.0,
                  ),
                  //const Text(
                  //  'EA',
                  //  style: TextStyle(
                  //    fontSize: 84,
                  //    color: Color(0xff1ABC9C),
                  //    //color: Colors.black
                  //    fontWeight: FontWeight.w600,
                  //  ),
                  //),
                  const Text(
                    'Events App',
                    style: TextStyle(
                      fontSize: 51,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1ABC9C),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 21.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.2),
              child: RaisedButton(
                onPressed: () {
                  onSignIn();
                },
                color: Color(0xff1ABC9C),
                textColor: Colors.white,
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 17.1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: Color(0xff1ABC9C),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
