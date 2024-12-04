#ifndef CUSTOMVOICECHGDLG_H
#define CUSTOMVOICECHGDLG_H

#include <QWidget>
#include "ui_CustomVoiceChgDlg.h"

class CustomVoiceChgDlg : public QDialog
{
	Q_OBJECT

public:
	CustomVoiceChgDlg(const CRString &usrid, int chgType = 150, QWidget *parent = 0);
	~CustomVoiceChgDlg();


protected slots:
	void on_slider_valueChanged(int value);

protected:
	int getVoiceChangeType();

private:
	Ui::CustomVoiceChgDlg ui;
	CRString	 m_usrID;
};

#endif // CUSTOMVOICECHGDLG_H
