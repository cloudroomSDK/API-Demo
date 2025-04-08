#ifndef TESTVIRTUALBACKGROUND_H
#define TESTVIRTUALBACKGROUND_H

#include <QDialog>
#include "ui_TestVirtualBackground.h"

class TestVirtualBackground : public QDialog
{
	Q_OBJECT

public:
	TestVirtualBackground(QWidget *parent = 0);
	~TestVirtualBackground();

protected slots:
	void on_modeButtonToggled(int id, bool bChecked);
	void on_okBtnClicked();

protected:
	void updateUIFromSdk();
	void applyUIToSdk();

private:
	Ui::TestVirtualBackground ui;
	QButtonGroup* _modeBtnGrp;
};

#endif // TESTVIRTUALBACKGROUND_H
