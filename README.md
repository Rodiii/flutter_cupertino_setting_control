
# Flutter Cupertino Setting Control

With cupertino_setting_control you can create a settings page or a simple form very easy. Therefore, cupertino_setting_control
offers multiple Cupertino-Widgets which can be used very flexible and abstracted.

## Quick Usage
A few examples:

Example for a drop down widget displayed as text field:
```dart
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
```

Example for a yes/no widget with a setting title on the left side:
```dart
new SettingRow(
    rowData: SettingsYesNoConfig(
        initialValue: _chatResult, title: 'Allow Chat'),
    onSettingDataRowChange: onChatSettingChange,
),
```

Please refer to the example for more examples: [Quick-Link](https://github.com/Rodiii/flutter_cupertino_setting_control/blob/master/example/lib/main.dart)

### Example
<img src="https://github.com/Rodiii/flutter_cupertino_setting_control/raw/master/example.png" width="300">

## Bugs/Requests
If you encounter any problems feel free to open an issue. If you feel the library is
missing a feature, please raise a ticket on Github and I'll look into it.
Pull Request are also welcome.
