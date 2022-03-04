#ifndef DLGROOMATTRS_H
#define DLGROOMATTRS_H

#include "ui_DlgRoomAttrs.h"

class DlgRoomAttrs : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgRoomAttrs(QWidget *parent = 0);
	~DlgRoomAttrs();

protected:
	virtual void getMeetingAllAttrsSuccess(const char* attrs, const char* cookie);
	virtual void getMeetingAllAttrsFail(CRVSDK_ERR_DEF sdkErr, const char* cookie);
	virtual void addOrUpdateMeetingAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie);
	virtual void delMeetingAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie);
	virtual void clearMeetingAttrsRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie);

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
	Ui::DlgRoomAttrs ui;
	CRString		m_cookie;
	QVariantMap		m_allAttrs;
	QString			m_operKey;
	QString			m_operVal;
};

#endif // DLGROOMATTRS_H
