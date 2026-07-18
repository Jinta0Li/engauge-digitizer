#include <QApplication>
#include <QDir>
#include <QLibraryInfo>
#include <QLocale>
#include <QSettings>
#include <QTranslator>
#include "Settings.h"
#include "TranslatorContainer.h"

TranslatorContainer::TranslatorContainer(QApplication & /* app */) :
  m_translatorGeneric (nullptr),
  m_translatorEngauge (nullptr)
{
  const QString selectedLocaleName = interfaceLocaleName ();
  const QLocale locale = selectedLocaleName == systemLocaleName () ?
                         QLocale::system () : QLocale (selectedLocaleName);

  // English strings are compiled into the application, so translators are only needed for other languages.
  if (locale.language () != QLocale::English) {
    // Basic translators, like buttons in QWizard
    m_translatorGeneric = new QTranslator;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    const QString qtTranslationsPath = QLibraryInfo::path (QLibraryInfo::TranslationsPath);
#else
    const QString qtTranslationsPath = QLibraryInfo::location (QLibraryInfo::TranslationsPath);
#endif
    bool genericLoaded = m_translatorGeneric->load (locale,
                                                     "qt",
                                                     "_",
                                                     qmDirectory ());
    if (!genericLoaded) {
      genericLoaded = m_translatorGeneric->load (locale,
                                                  "qt",
                                                  "_",
                                                  qtTranslationsPath);
    }
    Q_UNUSED (genericLoaded);
    QApplication::installTranslator (m_translatorGeneric);

    // Engauge-specific translators. Qt first tries the full locale (for example zh_TW), then falls back
    // to the language-only file (for example zh).
    //
    // In OSX, QDir::currentPath points to /Users/?/Library/Containers/Digitizer/Data and
    // QCoreApplication::applicationDirPath points to ../Engauge Digitizer.app/Contents/MacOS (which we want)
    m_translatorEngauge = new QTranslator;
    const bool engaugeLoaded = m_translatorEngauge->load (locale,
                                                           "engauge",
                                                           "_",
                                                           qmDirectory ());
    Q_UNUSED (engaugeLoaded);
    QApplication::installTranslator (m_translatorEngauge);
  }
}

QString TranslatorContainer::qmDirectory()
{
#if defined(OSX_DEBUG) || defined(OSX_RELEASE)
    return QCoreApplication::applicationDirPath () + "/../Resources/translations";
#else
    return QCoreApplication::applicationDirPath () + "/translations";
#endif
}

QStringList TranslatorContainer::availableLocaleNames ()
{
  QDir translationPath (qmDirectory ());
  const QStringList filenames = translationPath.entryList (QStringList ("engauge_*.qm"),
                                                            QDir::Files,
                                                            QDir::Name);
  QStringList localeNames;
  for (const QString &filename : filenames) {
    QString localeName = filename;
    localeName.chop (3); // Remove .qm
    localeName.remove (0, QString ("engauge_").size ());
    const QString normalizedLocaleName = QLocale (localeName).name ();
    if (!localeNames.contains (normalizedLocaleName)) {
      localeNames.append (normalizedLocaleName);
    }
  }

  return localeNames;
}

QString TranslatorContainer::interfaceLocaleName ()
{
  QSettings settings (SETTINGS_ENGAUGE, SETTINGS_DIGITIZER);
  settings.beginGroup (SETTINGS_GROUP_MAIN_WINDOW);

  QString localeName;
  if (settings.contains (SETTINGS_INTERFACE_LOCALE)) {
    localeName = settings.value (SETTINGS_INTERFACE_LOCALE).toString ();
  } else if (settings.contains (SETTINGS_LOCALE_LANGUAGE) &&
             settings.contains (SETTINGS_LOCALE_COUNTRY)) {
    // Migrate the interface language used by Engauge 12.9.1 and earlier, where it shared the numeric locale.
    const QLocale::Language language = static_cast<QLocale::Language> (
          settings.value (SETTINGS_LOCALE_LANGUAGE).toInt ());
    const QLocale::Country country = static_cast<QLocale::Country> (
          settings.value (SETTINGS_LOCALE_COUNTRY).toInt ());
    localeName = QLocale (language, country).name ();
  } else {
    localeName = systemLocaleName ();
  }

  settings.endGroup ();
  if (localeName.isEmpty () || localeName == systemLocaleName ()) {
    return systemLocaleName ();
  }
  return QLocale (localeName).name ();
}

QString TranslatorContainer::localeLabel (const QString &localeName)
{
  const QLocale locale (localeName);
  QString label = locale.nativeLanguageName ();
  if (locale.language () == QLocale::English) {
    label = QLocale::languageToString (QLocale::English);
  } else if (locale.language () == QLocale::Spanish) {
    label = QStringLiteral ("Español");
  }
  if (label.isEmpty ()) {
    label = QLocale::languageToString (locale.language ());
  }

  if (!label.isEmpty ()) {
    label [0] = label.at (0).toUpper ();
  }

  return label;
}

QString TranslatorContainer::systemLocaleName ()
{
  return "system";
}
