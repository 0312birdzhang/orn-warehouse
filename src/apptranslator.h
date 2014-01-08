#ifndef APPTRANSLATOR_H
#define APPTRANSLATOR_H

#include <QObject>
#include <QCoreApplication>
#include <QVariant>
#include <QTranslator>

class AppTranslator : public QObject
{
    Q_OBJECT

private:
    QCoreApplication * m_app;
    QString m_langdir;
    QTranslator m_translator;
    QVariantMap m_languages;

    Q_INVOKABLE void loadAvailableLanguages();

public:
    explicit AppTranslator(QCoreApplication *app = 0);

    Q_INVOKABLE void changeLanguage(QVariant lang);
    Q_INVOKABLE QVariant getAvailableLanguages();
    Q_INVOKABLE QVariant getLanguageName(QVariant code);
    Q_INVOKABLE QVariant getDefaultLanguage();


signals:
    void languageChanged(QVariant language);
};

#endif // APPTRANSLATOR_H
