#ifndef DLGLOGIN_H
#define DLGLOGIN_H

#include "ui_DlgLogin.h"

class MainDialog;
class DlgLogin : public QDialog, public CRVideoSDKMainCallBack, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgLogin(QWidget *parent = 0);
	~DlgLogin();
	void clearStatus();
	int getMeetID(){ return m_meetid; }

protected:
	virtual void loginRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie);
	virtual void notifyLineOff(CRVSDK_ERR_DEF sdkErr);

	virtual void createMeetingSuccess(const CRMeetInfo& meetObj, const char* cookie);
	virtual void createMeetingFail(CRVSDK_ERR_DEF sdkErr, const char* cookie);
	virtual void enterMeetingRslt(CRVSDK_ERR_DEF sdkErr);
	virtual void notifyMeetingStopped();

protected:
	void showEvent(QShowEvent *);
	void closeEvent(QCloseEvent *);

	void loginAndJoinMeeting(int meetid = 0);
	void enterMeeting(int meetid);

protected slots:
	void slot_btnEnterMeetingClicked();
	void slot_btnCreateMeetingClicked();
	void slot_btnSetClicked();
	void slot_mainDlgFinished();

private:
	enum UI_STATE
	{
		STATE_NULL,
		STATE_LOGIN_ING,
		STATE_LOGIN_SUCCESS,
		STATE_ENTERMEETING_ING,
		STATE_ENTERMEETING_SUCCESS,
	};
	Ui::DlgLogin ui;
	QString m_userId;
	int m_meetid;
	UI_STATE m_state;
	MainDialog* m_mainDlg = nullptr;
};

#endif // DLGLOGIN_H
