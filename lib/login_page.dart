import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_code_fields/pin_code_fields.dart';




class _PhoneMask {
  final TextEditingController textController = TextEditingController();
  final MaskTextInputFormatter formatter;
  final FormFieldValidator<String> validator;
  final String hint;
  _PhoneMask({ @required this.formatter, this.validator, @required this.hint });
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Timer _timer;

  int _start = 60;

  bool _posting = false;
  bool _showOTPForm = false;
  bool hasError = false;
  bool canRequest = true;

  String currentText = '';
  String errorText = '';
  String validText = '';


  TextEditingController textEditingController = TextEditingController();

  StreamController<ErrorAnimationType> errorController;

  final formKey = GlobalKey<FormState>();
  final formKeyOTP = GlobalKey<FormState>();

  final Color primaryColor = Color(0xff333333);
  final Color secondaryColor = Color(0xff444444);
  final Color logoGreen = Color(0xff12b423);
  final Color footerColor = Color(0xfff1f3ff);
  final Color errorColor = Color(0xffb43d12);

  final logoGreenBorder = Color(0xff12b423);
  final errorBorder = Color(0xffb43d12);

  final phoneMask = _PhoneMask(
    formatter: MaskTextInputFormatter(
        mask: '+38 (###) ### ## ##'
    ),
    hint: '+38 (***) *** ** **',
  );

  Function phoneValidation = (String value) {
    if (value.isEmpty) {
      return 'Будь ласка, введіть номер телефону';
    } else if (value.length < 19) {
      return 'Будь ласка, введіть поний номер телефону';
    }
    return null;
  };

  Future<void> send(String phone) async {

    setState(() {
      _posting = true;
      hasError = false;
      errorText = '';
    });

    final response = await http.post(
      // 'https://silver.sfactor.com.ua/api/auth/post',
      'https://flutter-apier.herokuapp.com/hello/phone-post-success/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone': phone,
        // TODO: remove for production and change fo valid url
        'await': '0',
      }),
    );

    if (response != null) {

      setState(() {
        _posting = false;
      });

      if (jsonDecode(response.body)['errors'] == null &&
          response.statusCode >= 200 &&
          response.statusCode < 300) {
        setState(() {
          _showOTPForm = true;
        });
      }
    }
  }

  Future<void> otpSend(String otp) async {

    setState(() {
      _posting = true;
    });

    final response = await http.post(
      // 'https://silver.sfactor.com.ua/api/auth/post',
      'https://flutter-apier.herokuapp.com/hello/phone-post-success/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'otp': otp,
        // 'phone': 'phone',
        // TODO: remove for production and change fo valid url
        'await': '0',
      }),
    );

    if (response != null) {

      setState(() {
        _posting = false;
      });

      // if (jsonDecode(response.body)['errors'] == null &&
      //     response.statusCode >= 200 &&
      //     response.statusCode < 300) {
      //   setState(() {
      //     _showOTPForm = true;
      //   });
      // } else
        if (response.statusCode < 500) {
        setState(() {
          hasError = true;
          errorText = 'Не вірний код';
          errorController.add(ErrorAnimationType.shake);
        }
        );
      } else {
        setState(() {
          hasError = true;
          errorText = 'Щось пішло не так... Спробуйте пізніше...';
          errorController.add(ErrorAnimationType.shake);
        }
        );
      }
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    setState(() {
      canRequest = false;
    });
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            setState(() {
              _start = 60;
              canRequest = true;
            });
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void unfocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  customValidator(otp) {
    if (otp.length == 4) {
      return true;
    } else if (otp.length < 4) {
      setState(() {
        errorText = 'Код трішки кородкуватий';
      });
      return false;
    }
    return true;
  }

  void otpValidateAndSend() {
    String otp = textEditingController.text;
    unfocus();
    if (customValidator(otp) == true) {
      otpSend(otp);
    } else {
      errorController.add(ErrorAnimationType.shake);
      setState(() {
        hasError = true;
      });
    }
  }

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    void validateAndSend(String phone) {
      final form = formKey.currentState;
      if (form.validate()) {
        send(phone);

      } else {
        print('form invalid');
      }
    }

    Widget _buildForm() {
      if (_showOTPForm == true) {
        String phone = phoneMask.formatter.getMaskedText();
        return Column(
          children: [
            Text(
              'Введіть код надісланий на номер:',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 24
              ),
            ),
            Text(
              '$phone',
              style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 24
              ),
            ),
            SizedBox(
              height: 55,
            ),
            Form(
              key: formKeyOTP,
              child: PinCodeTextField(
                length: 4,
                appContext: context,
                obscureText: false,
                showCursor: false,
                enableActiveFill: true,
                animationType: AnimationType.fade,
                backgroundColor: Colors.transparent,
                keyboardType: TextInputType.number,
                controller: textEditingController,
                errorAnimationController: errorController,
                animationDuration: Duration(milliseconds: 300),
                onCompleted: (v) {
                  otpValidateAndSend();
                },
                onSubmitted: (v) {
                  otpValidateAndSend();
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                pastedTextStyle: TextStyle(
                  color: logoGreen,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (String value) {
                  setState(() {
                    currentText = value;
                  });
                },
                onTap: () {
                  setState(() {
                    hasError = false;
                    errorText = '';
                  });
                },
                textStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
                dialogConfig: DialogConfig(
                  affirmativeText: 'Так',
                  dialogContent: 'Ви дійсно хочете вставити наступний код ',
                  dialogTitle: 'Вставити код',
                  negativeText: 'Ні',
                ),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.circle,
                  activeColor: hasError == true ? errorColor : logoGreen,
                  activeFillColor: hasError == true ? errorColor : logoGreen,
                  selectedColor: logoGreen,
                  selectedFillColor: primaryColor,
                  inactiveFillColor: primaryColor,
                  inactiveColor: hasError == true ? errorColor : Colors.white,
                  fieldHeight: 45,
                  fieldWidth: 45,
                ),
                beforeTextPaste: (text) {
                  if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
                    setState(() {
                      hasError = true;
                      errorText = 'Ви намагаєтесь вставити точно не код';
                      errorController.add(ErrorAnimationType.shake);
                    });
                    return false;
                  } else if (text.length > 4) {
                    setState(() {
                      hasError = true;
                      errorText = 'Ви намагаєтесь вставити надто довгий код';
                      errorController.add(ErrorAnimationType.shake);
                    });
                    return false;
                  } else if (text.length < 4) {
                    setState(() {
                      hasError = true;
                      errorText = 'Ви намагаєтесь вставити надто кородкий код';
                      errorController.add(ErrorAnimationType.shake);
                    });
                    return false;
                  }
                  return true;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Text(
                hasError == true ? "$errorText" : "",
                style: TextStyle(
                    color: errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            MaterialButton(
                elevation: 0,
                minWidth: double.maxFinite,
                height: 50,
                color: logoGreen,
                textColor: Colors.white,
                onPressed: () {
                  otpValidateAndSend();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)
                ),
                child: Text('Далі',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                    )
                )
            ),
            SizedBox(
              height: 10,
            ),
            FlatButton(
              child: Text(
                'Не надійшов код?',
                style: TextStyle(
                  color: canRequest == true ? Colors.white : Colors.grey,
                ),
              ),
              onPressed: () {
                unfocus();
                if (canRequest == true) {
                  send(phone);
                  startTimer();
                  textEditingController.text = '';
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  canRequest == false ? "$_start" : "",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ],
            )
          ],
        );
      }
      return Column(
          children: [
            Text(
              'Зареєструйтесь та продовжуйте',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 28
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Введіть номер телефону і натиснінь Продовжити щоб ми вам надіслали пароль.',
              textAlign: TextAlign.center,
              style:
              GoogleFonts.openSans(color: Colors.white, fontSize: 14),
            ),
            SizedBox(height: 50),
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    validator: phoneValidation,
                    inputFormatters: [
                      phoneMask.formatter,
                    ],
                    style: TextStyle(
                      letterSpacing: 5,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: phoneMask.hint,
                      hintStyle: TextStyle(
                          letterSpacing: 5,
                          color: Colors.grey
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(
                            color: logoGreenBorder,
                            width: 3),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(
                            color: logoGreenBorder,
                            width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(
                            color: errorBorder,
                            width: 4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(
                            color: logoGreenBorder,
                            width: 3),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  MaterialButton(
                      elevation: 0,
                      minWidth: double.maxFinite,
                      height: 50,
                      color: logoGreen,
                      textColor: Colors.white,
                      onPressed: () {
                        validateAndSend(phoneMask.formatter.getMaskedText());
                        unfocus();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      ),
                      child: Text('Продовжити',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18
                          )
                      )
                  )
                ],
              ),
            ),
          ],
        );
    }

    Widget _buildWidget() {
      return Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: _buildForm()
          ),
          bottomNavigationBar: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: footerColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30)
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38,
                    spreadRadius: 0,
                    blurRadius: 10
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: Image.asset(
                'assets/footer_logo.png',
                height: 40,
              ),
            ),
          )
      );
    }

    return GestureDetector(
      onTap: () {
        unfocus();
      },
      child: ModalProgressHUD(
        child: _buildWidget(),
        inAsyncCall: _posting,
        opacity: 0.8,
        color: primaryColor,
        progressIndicator: Image.asset(
          'assets/loading.gif',
          height: 250,
        ),
        dismissible: false,
      ),
    );
  }
}