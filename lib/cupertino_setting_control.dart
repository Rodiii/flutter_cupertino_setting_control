library cupertino_setting_control;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:io';

import 'package:cupertino_range_slider/cupertino_range_slider.dart';
import 'package:url_launcher/url_launcher.dart';

enum SettingDataType {
  kWidgetSlider,
  kWidgetDropdown,
  kWidgetSliderFromTo,
  kWidgetYesNo,
  kWidgetNewScreen,
  kWidgetTextField,
  kWidgetUrlData,
  kWidgetButtonData,
}

class SettingRowConfig {
  const SettingRowConfig({this.title, this.type, this.unit = ''});

  final String title;
  final SettingDataType type;
  final String unit;
}

class SettingsSliderConfig extends SettingRowConfig {
  SettingsSliderConfig(
      {title,
      unit = '',
      this.from,
      this.to,
      this.initialValue,
      this.justIntValues = false})
      : super(type: SettingDataType.kWidgetSlider, title: title, unit: unit);

  final double from;
  final double to;

  final double initialValue;
  final bool justIntValues;
}

class SettingsNewScreenConfig extends SettingRowConfig {
  SettingsNewScreenConfig({title, unit = '', this.newScreen, this.initialValue})
      : super(type: SettingDataType.kWidgetNewScreen, title: title, unit: unit);

  final Widget newScreen;
  final String initialValue;
}

class SettingsURLConfig extends SettingRowConfig {
  SettingsURLConfig({title, unit = '', this.url})
      : super(type: SettingDataType.kWidgetUrlData, title: title, unit: unit);

  final String url;
}

class SettingsButtonConfig extends SettingRowConfig {
  SettingsButtonConfig(
      {title, unit = '', this.functionToCall, this.tick = false})
      : super(
            type: SettingDataType.kWidgetButtonData, title: title, unit: unit);

  final Function functionToCall;
  final bool tick;
}

class SettingsSliderFromToConfig extends SettingRowConfig {
  SettingsSliderFromToConfig(
      {title,
      unit = '',
      this.from,
      this.to,
      this.initialFrom,
      this.initialTo,
      this.justIntValues = false})
      : super(
            type: SettingDataType.kWidgetSliderFromTo,
            title: title,
            unit: unit);

  final bool justIntValues;

  final double from;
  final double to;

  final double initialFrom;
  final double initialTo;
}

class SettingsDropDownConfig extends SettingRowConfig {
  SettingsDropDownConfig(
      {title,
      unit = '',
      this.choices,
      this.redList = const [],
      this.initialKey,
      this.onDropdownFinished})
      : super(type: SettingDataType.kWidgetDropdown, title: title, unit: unit);

  final Map<String, String> choices;

  final List<dynamic> redList;

  final String initialKey;

  final Function onDropdownFinished;
}

class SettingsYesNoConfig extends SettingRowConfig {
  SettingsYesNoConfig({title, unit = '', this.initialValue})
      : super(type: SettingDataType.kWidgetYesNo, title: title, unit: unit);

  final bool initialValue;

  bool result;
}

class SettingsTextFieldConfig extends SettingRowConfig {
  SettingsTextFieldConfig(
      {title,
      unit = '',
      this.maxLength,
      this.maxLines = 1,
      this.textInputType = TextInputType.text,
      this.initialValue})
      : super(type: SettingDataType.kWidgetTextField, title: title, unit: unit);

  final String initialValue;
  final int maxLength;
  final int maxLines;
  final TextInputType textInputType;
}

class SettingsRowConfiguration {
  const SettingsRowConfiguration({
    this.showTopTitle = false,
    this.showAsTextField = false,
    this.showTitleLeft = true,
    this.showAsSingleSetting = false,
  });

  final bool showTopTitle;
  final bool showAsTextField;
  final bool showTitleLeft;
  final bool showAsSingleSetting;
}

class SettingsRowStyle {
  const SettingsRowStyle({
    this.noPadding = false,
    this.fontSize = 17.0,
    this.backgroundColor = CupertinoColors.systemBackground,
    this.textColor = CupertinoColors.label,
    this.activeColor = CupertinoColors.systemBlue,
    this.highlightColor = CupertinoColors.systemGrey6,
    this.contentPadding = 15.0,
  });

  final bool noPadding;
  final double fontSize;
  final Color backgroundColor;
  final Color activeColor;
  final Color textColor;
  final Color highlightColor;
  final double contentPadding;
}

class SettingRow extends StatefulWidget {
  const SettingRow(
      {this.rowData,
      this.onSettingDataRowChange,
      this.config = const SettingsRowConfiguration(),
      this.style = const SettingsRowStyle(),
      this.enabled = true});

  final SettingRowConfig rowData;
  final Function onSettingDataRowChange;
  final SettingsRowConfiguration config;
  final SettingsRowStyle style;
  final bool enabled;

  @override
  SettingRowState createState() => new SettingRowState();
}

/// The state of the currently displayed tasks widget
class SettingRowState extends State<SettingRow> {
  SettingRowConfig _stateRowData;
  final TextEditingController _textfieldController = new TextEditingController();

  dynamic _result;

  @override
  void initState() {
    super.initState();

    _stateRowData = widget.rowData;
    if (widget.rowData is SettingsDropDownConfig) {
      _result = (widget.rowData as SettingsDropDownConfig).initialKey;
      if (!(widget.rowData as SettingsDropDownConfig)
          .choices
          .keys
          .contains(_result)) {
        _result = (widget.rowData as SettingsDropDownConfig).choices.keys.first;
      }
    } else if (widget.rowData is SettingsNewScreenConfig) {
      _result = (widget.rowData as SettingsNewScreenConfig).initialValue ?? '';
    } else if (widget.rowData is SettingsSliderConfig) {
      _result = (widget.rowData as SettingsSliderConfig).initialValue ??
          (widget.rowData as SettingsSliderConfig).to;
    } else if (widget.rowData is SettingsSliderFromToConfig) {
      _result = [
        (widget.rowData as SettingsSliderFromToConfig).initialFrom ??
            (widget.rowData as SettingsSliderFromToConfig).from,
        (widget.rowData as SettingsSliderFromToConfig).initialTo ??
            (widget.rowData as SettingsSliderFromToConfig).to
      ];
    } else if (widget.rowData is SettingsTextFieldConfig) {
      _result = (widget.rowData as SettingsTextFieldConfig).initialValue ?? '';
    } else if (widget.rowData is SettingsYesNoConfig) {
      _result = (widget.rowData as SettingsYesNoConfig).initialValue ?? true;
    }
  }

  void updateState() {
    setState(() {
      currentRowColor = null;
    });
  }

  void gotoNewPage() {
    if (_stateRowData.type != SettingDataType.kWidgetNewScreen)
      return;
    else {
      final SettingsNewScreenConfig tmp = _stateRowData;
      Navigator.of(context, rootNavigator: true)
          .push(new MaterialPageRoute(builder: (context) => tmp.newScreen));
    }
  }

  Future<void> gotoURL() async {
    if (_stateRowData.type != SettingDataType.kWidgetUrlData)
      return;
    else {
      final SettingsURLConfig tmp = _stateRowData;
      await _launchURL(tmp.url);
    }
  }

  Future<void> callFunction() async {
    if (_stateRowData.type != SettingDataType.kWidgetButtonData)
      return;
    else {
      final SettingsButtonConfig tmp = _stateRowData;
      await tmp.functionToCall();
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  void onYesNoChange({bool newVal}) {
    setState(() {
      final SettingsYesNoConfig tmp = _stateRowData;
      tmp.result = newVal;
    });

    widget.onSettingDataRowChange(_result);
  }

  void onSliderChange(double newVal) {
    setState(() {
      _result = newVal;
    });
  }

  void onSliderChangeEnd(double newVal) {
    setState(() {
      _result = newVal;
    });
    widget.onSettingDataRowChange(_result);
  }

  void onSliderFromToMinChange(double newVal) {
    setState(() {
      _result[0] = newVal;
    });

    widget.onSettingDataRowChange(_result);
  }

  void onSliderFromToMaxChange(double newVal) {
    setState(() {
      _result[1] = newVal;
    });

    widget.onSettingDataRowChange(_result);
  }

  void onDropdownChange(int newIndex) {
    setState(() {
      final SettingsDropDownConfig tmp = _stateRowData;
      _result = tmp.choices.keys.elementAt(newIndex);
    });

    widget.onSettingDataRowChange(_result);
  }

  void onTextFieldChange() {
    //setState(() {
    final SettingsTextFieldConfig tmp = _stateRowData;
    _result = _textfieldController.text;
    //});

    widget.onSettingDataRowChange(_result);
  }

  Widget getRightWidget() {
    String resultText;
    if (_stateRowData.type == SettingDataType.kWidgetSlider) {
      final SettingsSliderConfig tmp = _stateRowData;
      if (tmp.to - _result < 0.1)
        resultText = 'MAX';
      else
        resultText = tmp.justIntValues
            ? _result.round().toString() + tmp.unit
            : _result.toString() + tmp.unit;
    } else if (_stateRowData.type == SettingDataType.kWidgetSliderFromTo) {
      final SettingsSliderFromToConfig tmp = _stateRowData;
      String resultFrom = '', resultTo = '';
      if (tmp.to - _result[1] < 0.1)
        resultTo = 'MAX';
      else
        resultTo = tmp.justIntValues
            ? _result[1].round().toString()
            : _result[1].toString();
      if (tmp.to - _result[0] < 0.1)
        resultFrom = 'MAX';
      else
        resultFrom = tmp.justIntValues
            ? _result[0].round().toString()
            : _result[0].toString();

      resultText = resultFrom + '-' + resultTo + tmp.unit;
    }
    if (resultText != null)
      return new Text(resultText,
          style: TextStyle(
              fontSize: widget.style.fontSize,
              color: !widget.config.showAsTextField
                  ? CupertinoColors.inactiveGray
                  : widget.style.textColor));

    // Widgets which are "pressable"
    if (_stateRowData.type == SettingDataType.kWidgetDropdown) {
      final SettingsDropDownConfig tmp = _stateRowData;
      resultText = tmp.choices[_result] + tmp.unit;
    } else if (_stateRowData.type == SettingDataType.kWidgetNewScreen) {
      final SettingsNewScreenConfig tmp = _stateRowData;
      resultText = _result + tmp.unit;
    } else if (_stateRowData.type == SettingDataType.kWidgetUrlData ||
        _stateRowData.type == SettingDataType.kWidgetButtonData) {
      resultText = '';
    }
    if (resultText != null) {
      return new Row(children: [
        Text(resultText,
            style: TextStyle(
                fontSize: widget.style.fontSize,
                color: !widget.config.showAsTextField
                    ? CupertinoColors.inactiveGray
                    : widget.style.textColor),
            textAlign: _stateRowData.type != SettingDataType.kWidgetButtonData
                ? TextAlign.start
                : TextAlign.center),
        _stateRowData.type != SettingDataType.kWidgetButtonData ||
                (_stateRowData.type == SettingDataType.kWidgetButtonData &&
                    (_stateRowData as SettingsButtonConfig).tick)
            ? Container(
                margin: const EdgeInsets.only(left: 5.0),
                child: Icon(CupertinoIcons.forward,
                    color: !widget.config.showAsTextField
                        ? CupertinoColors.inactiveGray
                        : widget.style.textColor,
                    size: 17.0),
              )
            : Container(),
      ]);
    }

    // Yes/No
    if (_stateRowData.type == SettingDataType.kWidgetYesNo) {
      final SettingsYesNoConfig tmp = _stateRowData;
      return new CupertinoSwitch(
        value: tmp.result ?? tmp.initialValue,
        onChanged: !widget.enabled ? null : (val) => onYesNoChange(newVal: val),
        activeColor: widget.style.activeColor,
      );
    }

    // Text Field Widget
    if (_stateRowData.type == SettingDataType.kWidgetTextField) {
      final SettingsTextFieldConfig tmp = _stateRowData;
      _textfieldController.text = _result;
      _textfieldController.addListener(onTextFieldChange);

      final InputDecoration decorator = InputDecoration(
        isDense: true,
        hintText: tmp.title,
        hintStyle: TextStyle(
            color: CupertinoColors.inactiveGray,
            fontSize: widget.style.fontSize),
        contentPadding: EdgeInsets.all(widget.style.contentPadding),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide:
                BorderSide(color: CupertinoColors.inactiveGray, width: 0.0)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide:
                BorderSide(color: CupertinoColors.inactiveGray, width: 0.0)),
      );

      return Expanded(
        child: new TextFormField(
            enabled: widget.enabled,
            autofocus: false,
            inputFormatters: tmp.maxLength != null
                ? [
                    LengthLimitingTextInputFormatter(tmp.maxLength),
                  ]
                : null,
            maxLines: tmp.maxLines,
            keyboardType: tmp.textInputType,
            textCapitalization: tmp.textInputType == TextInputType.text
                ? TextCapitalization.sentences
                : TextCapitalization.none,
            autocorrect: tmp.textInputType == TextInputType.text,
            style: TextStyle(
                color: widget.style.textColor, fontSize: widget.style.fontSize),
            controller: _textfieldController,
            decoration: decorator),
      );
    }

    throw Exception('Wrong settings row type');
  }

  Widget getBottomWidget() {
    if (_stateRowData.type == SettingDataType.kWidgetSlider) {
      final SettingsSliderConfig tmp = _stateRowData;
      final double valueToUse = _result;
      return new Expanded(
          child: CupertinoSlider(
              min: tmp.from,
              max: tmp.to,
              value: valueToUse >= tmp.from && valueToUse <= tmp.to
                  ? valueToUse
                  : valueToUse > tmp.to ? tmp.to : tmp.from,
              activeColor: widget.style.activeColor,
              onChanged: onSliderChange,
              onChangeEnd: onSliderChangeEnd,
              divisions:
                  tmp.justIntValues ? (tmp.to - tmp.from).round() : null));
    } else if (_stateRowData.type == SettingDataType.kWidgetSliderFromTo) {
      final SettingsSliderFromToConfig tmp = _stateRowData;
      return new Expanded(
          child: CupertinoRangeSlider(
              min: tmp.from,
              max: tmp.to,
              minValue: _result[0],
              maxValue: _result[1],
              activeColor: widget.style.activeColor,
              onMaxChanged: onSliderFromToMaxChange,
              onMinChanged: onSliderFromToMinChange,
              divisions:
                  tmp.justIntValues ? (tmp.to - tmp.from).round() : null));
    } else
      return Container();
  }

  final double _kPickerSheetHeight = 250.0;
  final double _kPickerItemHeight = 50.0;

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 0.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: TextStyle(
          color: widget.style.textColor,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  List<Widget> _getDropdownWidgets({dynamic currentList, String pre = ''}) {
    final List<Widget> pickerListWidgets = [];
    for (var data in currentList) {
      if (data is List) {
        pickerListWidgets.addAll(_getDropdownWidgets(
            currentList: data, pre: pre == '' ? ' - ' : ' ' + pre));
      } else if (data is String) {
        pickerListWidgets.add(Center(
          child: Text(pre + data.toString()),
        ));
      }
    }

    return pickerListWidgets;
  }

  void showDropDownList() async {
    final SettingsDropDownConfig tmp = _stateRowData;
    int index = tmp.choices.keys.toList().indexOf(_result);
    if (index == -1) {
      index = 0;
    }

    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: index);

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomPicker(
          CupertinoPicker(
            backgroundColor: widget.style.backgroundColor,
            scrollController: scrollController,
            itemExtent: _kPickerItemHeight,
            onSelectedItemChanged: onDropdownChange,
            children: _getDropdownWidgets(currentList: tmp.choices.values),
          ),
        );
      },
    );

    if ((_stateRowData as SettingsDropDownConfig).onDropdownFinished != null)
      (_stateRowData as SettingsDropDownConfig).onDropdownFinished();
  }

  Color currentRowColor;
  void highlightRow(TapDownDetails det) {
    if (_stateRowData.type == SettingDataType.kWidgetNewScreen ||
        _stateRowData.type == SettingDataType.kWidgetDropdown ||
        _stateRowData.type == SettingDataType.kWidgetUrlData ||
        _stateRowData.type == SettingDataType.kWidgetButtonData) {
      currentRowColor = widget.style.highlightColor;
      setState(() {});
    }
  }

  void unhighlightRow() {
    if (_stateRowData.type == SettingDataType.kWidgetNewScreen ||
        _stateRowData.type == SettingDataType.kWidgetDropdown ||
        _stateRowData.type == SettingDataType.kWidgetUrlData ||
        _stateRowData.type == SettingDataType.kWidgetButtonData) {
      currentRowColor = widget.style.backgroundColor;
      setState(() {});
    }
  }

  void unhighlightUpRow(TapUpDetails det) {
    if (_stateRowData.type == SettingDataType.kWidgetNewScreen ||
        _stateRowData.type == SettingDataType.kWidgetDropdown ||
        _stateRowData.type == SettingDataType.kWidgetUrlData ||
        _stateRowData.type == SettingDataType.kWidgetButtonData) {
      currentRowColor = widget.style.backgroundColor;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    currentRowColor ??= widget.style.backgroundColor;
    return _buildSettingControl(context);
  }

  Widget _buildSettingControl(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.config.showTopTitle
              ? Column(children: <Widget>[
                  new Text(
                    _stateRowData.title,
                    style: TextStyle(
                        color: widget.style.activeColor,
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal),
                  ),
                  const Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                  ),
                ])
              : Container(),
          new GestureDetector(
            onTap: !widget.enabled
                ? null
                : () async {
                    if (_stateRowData.type ==
                        SettingDataType.kWidgetNewScreen) {
                      gotoNewPage();
                    } else if (_stateRowData.type ==
                        SettingDataType.kWidgetDropdown) {
                      showDropDownList();
                    } else if (_stateRowData.type ==
                        SettingDataType.kWidgetUrlData) {
                      await gotoURL();
                    } else if (_stateRowData.type ==
                        SettingDataType.kWidgetButtonData) {
                      await callFunction();
                    }
                  },
            onTapDown: !widget.enabled ? null : highlightRow,
            onTapCancel: !widget.enabled ? null : unhighlightRow,
            onTapUp: !widget.enabled ? null : unhighlightUpRow,
            child: Container(
              margin: widget.style.noPadding
                  ? EdgeInsets.zero
                  : widget.config.showAsSingleSetting
                      ? const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0)
                      : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: currentRowColor,
                border: widget.config.showAsSingleSetting
                    ? null
                    : Border(
                        bottom: BorderSide(
                            color: CupertinoColors.inactiveGray, width: 0.0),
                        top: BorderSide(
                            color: CupertinoColors.inactiveGray, width: 0.0)),
              ),
              padding: widget.config.showAsSingleSetting
                  ? EdgeInsets.zero
                  : _stateRowData.type == SettingDataType.kWidgetSlider ||
                          _stateRowData.type ==
                              SettingDataType.kWidgetSliderFromTo
                      ? const EdgeInsets.fromLTRB(25.0, 12.5, 25.0, 2.5)
                      : _stateRowData.type == SettingDataType.kWidgetYesNo
                          ? const EdgeInsets.fromLTRB(25.0, 2.5, 25.0, 2.5)
                          : const EdgeInsets.fromLTRB(25.0, 12.5, 25.0, 12.5),
              child: widget.config.showAsTextField
                  ? Container(
                      decoration: BoxDecoration(
                        color: currentRowColor,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border(
                          bottom: BorderSide(
                              color: CupertinoColors.inactiveGray, width: 0.0),
                          top: BorderSide(
                              color: CupertinoColors.inactiveGray, width: 0.0),
                          left: BorderSide(
                              color: CupertinoColors.inactiveGray, width: 0.0),
                          right: BorderSide(
                              color: CupertinoColors.inactiveGray, width: 0.0),
                        ),
                      ),
                      padding:
                          _stateRowData.type == SettingDataType.kWidgetSlider ||
                                  _stateRowData.type ==
                                      SettingDataType.kWidgetSliderFromTo
                              ? const EdgeInsets.fromLTRB(15.0, 12.5, 25.0, 2.5)
                              : EdgeInsets.all(widget.style.contentPadding),
                      child: Column(children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(child: getRightWidget()),
                          ],
                        ),
                        new Row(children: [getBottomWidget()]),
                      ]),
                    )
                  : Column(children: <Widget>[
                      Row(
                        children: <Widget>[
                          widget.config.showTitleLeft
                              ? Expanded(
                                  child: Text(_stateRowData.title,
                                      style: TextStyle(
                                        fontSize: widget.style.fontSize,
                                        color: widget.style.textColor,
                                      )))
                              : Container(),
                          Container(child: getRightWidget()),
                        ],
                      ),
                      new Row(children: [getBottomWidget()]),
                    ]),
            ),
          )
        ],
      ),
    );
  }
}

/// Represents the exit button on the right upper corner
class SettingsButton extends StatefulWidget {
  SettingsButton(
      {this.textColor = Colors.white,
      this.buttonText,
      this.buttonColor = CupertinoColors.systemBlue,
      this.callFunction});

  final Color buttonColor;
  final Color textColor;
  final String buttonText;
  final Function callFunction;

  @override
  SettingsButtonState createState() => new SettingsButtonState();
}

/// State of the widget
class SettingsButtonState extends State<SettingsButton> {
  bool currentlyProcessing = false;

  /// Builds the ExitButton
  @override
  Widget build(BuildContext context) {
    return new CupertinoButton(
      child: Tooltip(
        message: widget.buttonText,
        child:
            Text(widget.buttonText, style: TextStyle(color: widget.textColor)),
        excludeFromSemantics: true,
        preferBelow: true,
      ),
      minSize: 40.0,
      color: widget.buttonColor,
      disabledColor: CupertinoColors.inactiveGray,
      padding: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(4.0),
      onPressed: currentlyProcessing
          ? null
          : () async {
              setState(() {
                currentlyProcessing = true;
              });
              await widget.callFunction();

              setState(() {
                currentlyProcessing = false;
              });
            },
    );
  }
}
