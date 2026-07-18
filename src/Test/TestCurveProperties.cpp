#include "CurveConnectAs.h"
#include "LineStyle.h"
#include "Settings.h"
#include "Test/TestCurveProperties.h"
#include "WindowModelBase.h"
#include "WindowTable.h"
#include <QMouseEvent>
#include <QSettings>
#include <QTemporaryDir>
#include <QtTest/QtTest>

QTEST_MAIN (TestCurveProperties)

void TestCurveProperties::testGraphCurveDefaultIsRelationStraight ()
{
  QTemporaryDir settingsDirectory;
  QVERIFY (settingsDirectory.isValid ());

  const QSettings::Format formatBefore = QSettings::defaultFormat ();
  QSettings::setDefaultFormat (QSettings::IniFormat);
  QSettings::setPath (QSettings::IniFormat,
                      QSettings::UserScope,
                      settingsDirectory.path ());

  QSettings settings (SETTINGS_ENGAUGE, SETTINGS_DIGITIZER);
  settings.clear ();
  settings.sync ();

  QCOMPARE (LineStyle::defaultGraphCurve (0).curveConnectAs (),
            CONNECT_AS_RELATION_STRAIGHT);

  QSettings::setDefaultFormat (formatBefore);
}

void TestCurveProperties::testMouseDragSelectsTableCellsWhenDragExportIsDisabled ()
{
  WindowModelBase model;
  model.setRowCount (3);
  model.setColumnCount (3);

  WindowTable table (model);
  table.setDragEnabled (false);
  table.resize (360, 240);
  table.show ();
  QApplication::processEvents ();

  const QPoint start = table.visualRect (model.index (0, 0)).center ();
  const QPoint finish = table.visualRect (model.index (2, 2)).center ();

  QMouseEvent pressEvent (QEvent::MouseButtonPress,
                          start,
                          Qt::LeftButton,
                          Qt::LeftButton,
                          Qt::NoModifier);
  table.mousePressEvent (&pressEvent);

  QMouseEvent moveEvent (QEvent::MouseMove,
                         finish,
                         Qt::NoButton,
                         Qt::LeftButton,
                         Qt::NoModifier);
  table.mouseMoveEvent (&moveEvent);

  const QModelIndexList selected = table.selectionModel ()->selectedIndexes ();
  QCOMPARE (selected.count (), 9);
  QVERIFY (selected.contains (model.index (0, 0)));
  QVERIFY (selected.contains (model.index (2, 2)));
}
