#ifndef DLGADDOREDITATTR_H
#define DLGADDOREDITATTR_H

#include "ui_DlgAddOrEditAttr.h"

class DlgAddOrEditAttr : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgAddOrEditAttr(QWidget *parent = 0);
	~DlgAddOrEditAttr();

	void setKeyValue(const QString &key, const QString &value);
	void getKeyValue(QString &key, QString &value);

public slots:
	void slot_btnAddOrEditClicked();
	void slot_btnCancelClicked();

private:
	Ui::DlgAddOrEditAttr ui;
	bool			m_isEdit;
};

#endif // DLGADDOREDITATTR_H
