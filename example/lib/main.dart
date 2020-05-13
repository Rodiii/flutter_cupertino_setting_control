import 'package:cupertino_setting_control/cupertino_setting_control.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => new _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  bool _chatResult = true;
  String _searchAreaResult = 'Germany';

  @override
  Widget build(BuildContext context) {
    final legalStuff = new Material(
      color: Colors.transparent,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
              child: const Text('Legal',
                  style: TextStyle(
                    color: CupertinoColors.systemBlue,
                    fontSize: 15.0,
                  ))),
          new SettingRow(
              rowData: SettingsURLConfig(
                  title: 'Privacy',
                  url: 'https://yourprivacystuff.notexistant')),
          new SettingRow(
              rowData: SettingsURLConfig(
                  title: 'AGB', url: 'https://yourprivacystuff.notexistant')),
          new SettingRow(
              rowData: SettingsButtonConfig(
                  title: 'Licenses',
                  tick: true,
                  functionToCall: () => showLicensePage(
                      context: context,
                      applicationName: 'example',
                      applicationVersion: 'v1.1',
                      useRootNavigator: true))),
        ],
      ),
    );

    final privacySettings = new Material(
      color: Colors.transparent,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
              child: const Text(
                'Privacy Settings',
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontSize: 15.0,
                ),
              )),
          new SettingRow(
            rowData: SettingsYesNoConfig(
                initialValue: _chatResult, title: 'Allow Chat'),
            onSettingDataRowChange: onChatSettingChange,
          ),
        ],
      ),
    );

    final searchAreaTile = new Material(
      color: Colors.transparent,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
              child: const Text(
                'Area',
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontSize: 15.0,
                ),
              )),
          new SettingRow(
            rowData: SettingsDropDownConfig(
                title: 'Search Area',
                initialKey: _searchAreaResult,
                choices: {
                  'Germany': 'Germany',
                  'Spain': 'Spain',
                  'France': 'France'
                }),
            onSettingDataRowChange: onSearchAreaChange,
            config: const SettingsRowConfiguration(
                showAsTextField: true,
                showTitleLeft: false,
                showAsSingleSetting: false),
          )
        ],
      ),
    );

    final deleteProfileButton = SettingsButton(
        textColor: CupertinoColors.darkBackgroundGray,
        buttonColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? CupertinoColors.systemGrey2.darkColor
                : CupertinoColors.extraLightBackgroundGray,
        buttonText: 'Delete Profile',
        callFunction: () {});

    final List<Widget> widgetList = [
      privacySettings,
      const SizedBox(height: 15.0),
      searchAreaTile,
      const SizedBox(height: 15.0),
      legalStuff,
      const SizedBox(height: 15.0),
      Row(children: [Expanded(child: deleteProfileButton)]),
    ];

    return new Scaffold(
      body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: Column(mainAxisSize: MainAxisSize.max, children: widgetList)),
    );
  }

  void onChatSettingChange({bool data}) {
    setState(() {
      _chatResult = data;
    });
  }

  void onSearchAreaChange(String data) {
    setState(() {
      _searchAreaResult = data;
    });
  }
}
