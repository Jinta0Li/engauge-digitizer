#include "DlgImportAdvanced.h"
#include "DocumentAxesPointsRequired.h"
#include <QtTest/QtTest>
#include "Test/TestImportCoordinateSetup.h"

QTEST_APPLESS_MAIN (TestImportCoordinateSetup)

void TestImportCoordinateSetup::testFourAxisPointsAreDefault ()
{
  QCOMPARE (DlgImportAdvanced::defaultDocumentAxesPointsRequired (),
            DOCUMENT_AXES_POINTS_REQUIRED_4);
}
