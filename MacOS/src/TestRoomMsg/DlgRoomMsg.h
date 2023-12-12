#ifndef DLGROOMMSG_H
#define DLGROOMMSG_H

#include "ui_DlgRoomMsg.h"

class DlgRoomMsg : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgRoomMsg(QWidget *parent = 0);
	~DlgRoomMsg();

protected:
	virtual void sendMeetingCustomMsgRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie);
	virtual void notifyMeetingCustomMsg(const char* fromUserID, const char* jsonDat);

	virtual void showEvent(QShowEvent *evt);

public slots:
	void slot_btnSendClicked();

protected:
	void append2ReceiveEdit(const QString &strMsg, const CRString &strUserId);
	void insertMsgRow(QTextCursor &cursor, const QString &strMsg, const QString &strNickname, bool isMine);

private:
	Ui::DlgRoomMsg ui;
	CRString		m_cookie;
};

#endif // DLGROOMMSG_H
