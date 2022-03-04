#ifndef DLGECHOTEST_H
#define DLGECHOTEST_H

#include "ui_DlgEchoTest.h"

class DlgEchoTest : public QDialog
{
	Q_OBJECT

public:
	DlgEchoTest(QWidget *parent = 0);
	~DlgEchoTest();

protected slots:
	void slot_btnTestClicked();
	void slot_timeout();

protected:
	void startTest();
	void stopTest();

private:
	Ui::DlgEchoTest ui;
	QTimer m_timer;
	int m_nSecondsToStop;
};

#endif // DLGECHOTEST_H
