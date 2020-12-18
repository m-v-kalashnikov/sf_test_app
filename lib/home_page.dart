import 'package:flutter/material.dart';
import 'package:sf_test_app/login_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Color primaryColor = Color(0xff333333);
  final Color logoGreen = Color(0xff12b423);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/sf_shield.png',
              height: 250,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Вітаємо в Сучасному Факторингу!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            SizedBox(height: 20),
            Text(
              'Ми допомагаємо кожному, кому відмовили банки.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(
              height: 30,
            ),
            MaterialButton(
              elevation: 0,
              height: 50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => LoginPage()));
              },
              color: logoGreen,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Продовжити',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              textColor: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}