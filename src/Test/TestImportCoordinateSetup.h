#ifndef TEST_IMPORT_COORDINATE_SETUP_H
#define TEST_IMPORT_COORDINATE_SETUP_H

#include <QObject>

/// Regression tests for the coordinate definition selected during image import
class TestImportCoordinateSetup : public QObject
{
  Q_OBJECT

 private slots:
  void testFourAxisPointsAreDefault ();
};

#endif // TEST_IMPORT_COORDINATE_SETUP_H
