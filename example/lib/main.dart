import 'dart:async';

import 'package:flutter/material.dart';
import 'package:result_channel/result_channel.dart';

const javaClassName = 'dev.jonathanvegasp.result_channel_example.MainActivity';

void main() {
  ResultChannel.registerClass(javaClassName);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _currentTime;
  bool? _isAwesome;
  bool? _customDialog;

  static void openAlertDialogImmediate() {
    ResultChannel.callStaticVoid(javaClassName, 'openAlertDialogImmediate');
  }

  static void openAlertDialogImmediateWithArgs({
    required String title,
    required String message,
    String buttonTitle = 'Close',
  }) {
    ResultChannel.callStaticVoidWithArgs(
      javaClassName,
      'openAlertDialogImmediateWithArgs',
      ResultDart.ok([title, message, buttonTitle]),
    );
  }

  static String getPlatformVersion() {
    return ResultChannel.callStaticReturn(
          javaClassName,
          'getPlatformVersion',
        ).data
        as String;
  }

  static String getFormattedDate(String format) {
    return ResultChannel.callStaticReturnWithArgs(
          javaClassName,
          'getFormattedDate',
          ResultDart.ok(format),
        ).data
        as String;
  }

  static Future<bool> openAlertDialogAsync() async {
    final result = await ResultChannel.callStaticVoidAsync(
      javaClassName,
      'openAlertDialogAsync',
    );

    return result.data as bool;
  }

  static Future<bool> openAlertDialogAsyncWithArgs({
    required String title,
    required String message,
    required String positiveButtonTitle,
    required String negativeButtonTitle,
  }) async {
    final result = await ResultChannel.callStaticVoidAsyncWithArgs(
      javaClassName,
      'openAlertDialogAsyncWithArgs',
      ResultDart.ok([title, message, positiveButtonTitle, negativeButtonTitle]),
    );

    return result.data as bool;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Text('Platform version: ${getPlatformVersion()}'),
              const TextButton(
                onPressed: openAlertDialogImmediate,
                child: Text('Open an alert dialog immediate'),
              ),
              TextButton(
                onPressed: () => openAlertDialogImmediateWithArgs(
                  title: 'Alert Example',
                  message: 'This is an example, which uses a dialog',
                  buttonTitle: 'Close example',
                ),
                child: Text('Open an alert dialog immediate with custom args'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _currentTime = getFormattedDate('dd-MM-yyyy');
                }),
                child: Text('Show current date'),
              ),
              if (_currentTime != null) Text(_currentTime!),
              TextButton(
                onPressed: () async {
                  _isAwesome = await openAlertDialogAsync();
                  setState(() {});
                },
                child: Text('Open an alert dialog'),
              ),
              if (_isAwesome != null) Text('This is awesome? $_isAwesome'),
              TextButton(
                onPressed: () async {
                  _customDialog = await openAlertDialogAsyncWithArgs(
                    title: 'Eae Jhonny',
                    message: 'Would you use this plugin in your projects?',
                    positiveButtonTitle: 'Yes',
                    negativeButtonTitle: 'No',
                  );
                  setState(() {});
                },
                child: Text('Open an alert dialog'),
              ),
              if (_customDialog != null)
                Text(
                  'Would you use this plugin in your projects? $_customDialog',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
