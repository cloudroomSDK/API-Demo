#ifndef DLGUSERATTRS_H
#define DLGUSERATTRS_H

#include "ui_DlgUserAttrs.h"

class DlgUserAttrs : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgUserAttrs(const CRString &userId, QWidget *parent = 0);
	~DlgUserAttrs();

protected:
	virtual void getUserAttrsSuccess(const char* attrsMap, const char* cookie);
	virtual void getUserAttrsFail(CRVSDK_ERR_DEF sdkErr, const char* cookie);
	virtual void addOrUpdateUserAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie);
	virtual void delUserAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie);
	virtual void clearUserAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie);

public slots:
	void slot_btnAddClicked();
	void slot_btnRemoveClicked();
	void slot_btnRemoveAllClicked();
	void slot_btnEditClicked();
	void slot_cellDoubleClicked(int row, int col);
	void updateButtonsState();

private:
	void showOperRsltTips(CRVSDK_ERR_DEF sdkErr);
	void updateAttrsTable();
	void clearOperStrings();

private:
	Ui::DlgUserAttrs ui;
	CRString		m_userId;
	CRString		m_cookie;
	QVariantMap		m_allAttrs;
	QString			m_operKey;
	QString			m_operVal;
};

#endif // DLGUSERATTRS_H
