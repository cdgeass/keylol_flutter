import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keylol_flutter/common/keylol_client.dart';
import 'package:keylol_flutter/components/throwable_future_builder.dart';
import 'package:keylol_flutter/models/sec_code.dart';

class CellphoneInput extends StatelessWidget {
  const CellphoneInput({Key? key, required this.cellphoneController})
      : super(key: key);

  final TextEditingController cellphoneController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      controller: cellphoneController,
      autofillHints: [AutofillHints.telephoneNumber],
      decoration: InputDecoration(labelText: '手机号'),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        LengthLimitingTextInputFormatter(11)
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '手机号不能为空';
        }
        return null;
      },
    );
  }
}

class SmsInput extends StatefulWidget {
  final TextEditingController smsController;
  final Future<int> Function() sendSms;

  const SmsInput({Key? key, required this.smsController, required this.sendSms})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SmsInputState();
}

class _SmsInputState extends State<SmsInput> {
  final StreamController<int> _streamController = StreamController();
  int _second = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _streamController.sink.add(0);
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
    _streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
            child: TextFormField(
          controller: widget.smsController,
          decoration: InputDecoration(labelText: '短信验证码'),
          inputFormatters: [LengthLimitingTextInputFormatter(4)],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '短信验证码不能为空';
            }
            return null;
          },
        )),
        StreamBuilder(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            final second = snapshot.data ?? 0;
            if (second == 0) {
              return ElevatedButton(
                  child: Text('获取短信验证码'),
                  style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all(Size(133.0, 48.0))),
                  onPressed: () {
                    final sendSmsFuture = widget.sendSms.call();

                    sendSmsFuture.then((value) {
                      if (value == 1) {
                        _second = 60;
                        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                          _second--;
                          _streamController.sink.add(_second);
                          if (_second == 0) {
                            timer.cancel();
                          }
                        });
                      }
                    });
                  });
            } else {
              return ElevatedButton(
                  child: Text('重新获取(${second}s)'),
                  style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all(Size(133.0, 48.0))),
                  onPressed: null);
            }
          },
        )
      ],
    );
  }
}

class UsernameInput extends StatelessWidget {
  const UsernameInput({Key? key, required this.usernameController})
      : super(key: key);

  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      controller: usernameController,
      autofillHints: [AutofillHints.username],
      decoration: InputDecoration(labelText: '用户名'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '用户名不能为空';
        }
        return null;
      },
    );
  }
}

class PasswordInput extends StatefulWidget {
  const PasswordInput({Key? key, required this.passwordController})
      : super(key: key);

  final TextEditingController passwordController;

  @override
  State<StatefulWidget> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = true;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.passwordController,
      autofillHints: [AutofillHints.password],
      decoration: InputDecoration(
          labelText: '密码',
          suffix: IconButton(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            iconSize: 16.0,
            constraints: BoxConstraints(maxHeight: 16.0),
            icon: _obscure
                ? Icon(Icons.remove_red_eye)
                : Icon(Icons.remove_red_eye_outlined),
            onPressed: () {
              setState(() {
                _obscure = !_obscure;
              });
            },
          )),
      obscureText: _obscure,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '密码不能为空';
        }
        return null;
      },
    );
  }
}

class SecCodeInput extends StatefulWidget {
  final SecCode secCode;
  final TextEditingController secCodeController;

  const SecCodeInput(
      {Key? key, required this.secCode, required this.secCodeController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SecCodeInputState();
}

class _SecCodeInputState extends State<SecCodeInput> {
  late String update;
  String? idHash;

  @override
  void initState() {
    super.initState();

    update = widget.secCode.update;
    idHash = widget.secCode.getIdHash();
  }

  @override
  Widget build(BuildContext context) {
    final future = KeylolClient().fetchSecCode(update, idHash!);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
            child: TextFormField(
          controller: widget.secCodeController,
          decoration: InputDecoration(labelText: '验证码'),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]|[0-9]')),
            LengthLimitingTextInputFormatter(4)
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '验证码不能为空';
            }
            return null;
          },
        )),
        InkWell(
          child: ThrowableFutureBuilder(
              future: future,
              builder: (context, Uint8List data) {
                return Image.memory(
                  data,
                  height: 40.0,
                );
              }),
          onTap: () {
            setState(() {
              idHash = widget.secCode.getIdHash();
            });
          },
        )
      ],
    );
  }
}