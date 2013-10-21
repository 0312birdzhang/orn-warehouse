import QtQuick 1.1
import "../js/database.js" as Database

QtObject {
    id: config

    signal settingsLoaded

    Component.onCompleted: {
        loadSettings();
    }

    function loadSettings() {
        var results = Database.getAllSettings()
        for (var s in results) {
            settingChanged(s, results[s]);
        }
        settingsLoaded()
    }

    function resetSettings() {
        Database.resetSettings();
        updateType = "none"
        imageLoad = "all"
        language = "en"
        debugEnabled = ""
    }

    function settingChanged(name, value) {
        if (config.hasOwnProperty(name)) {
            config[name] = value;
        }
    }

    property string updateType: "none"
    onUpdateTypeChanged: Database.setSetting({"updateType": updateType})

    property string language: "en"
    onLanguageChanged: {
        Database.setSetting({"language": language})
        appTranslator.changeLanguage(language);
    }

    property string debugEnabled: ""
    onDebugEnabledChanged: Database.setSetting({"debugEnabled": debugEnabled})

    property string imageLoad: ""
    onImageLoadChanged: Database.setSetting({"imageLoad": imageLoad})
}
