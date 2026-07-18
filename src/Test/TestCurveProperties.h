#ifndef TEST_CURVE_PROPERTIES_H
#define TEST_CURVE_PROPERTIES_H

#include <QObject>

class TestCurveProperties : public QObject
{
  Q_OBJECT

private slots:
  void testGraphCurveDefaultIsRelationStraight ();
  void testMouseDragSelectsTableCellsWhenDragExportIsDisabled ();
};

#endif // TEST_CURVE_PROPERTIES_H
