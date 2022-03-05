#ifndef DLGVOICECHANGE_H
#define DLGVOICECHANGE_H

#include "ui_DlgVoiceChange.h"
#include "ui_VoiceChangeItem.h"

class VoiceChangeItem : public QWidget
{
	Q_OBJECT

public:
	VoiceChangeItem(QWidget *parent = 0);
	~VoiceChangeItem() {}

	void setUserInfo(const CRString &userId, const QString &nickname, int type);
	void updateNickName(const QString &nickname);
	void updateVoiceType(int type);

	CRString getUserId() { return m_userId; }

protected slots:
	void slot_voiceChooseChanged(int index);

private:
	Ui::VoiceChangeItem ui;

	CRString	m_userId;
};

class DlgVoiceChange : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgVoiceChange(QWidget *parent = 0);
	~DlgVoiceChange();

protected:
	virtual void notifyUserEnterMeeting(const char* userID);
	virtual void notifyUserLeftMeeting(const char* userID);
	virtual void notifyNickNameChanged(const char* userID, const char* oldName, const char* newName, const char* oprUserID);
	virtual void notifySetVoiceChange(const char* userID, int type, const char* oprUserID);

	virtual void showEvent(QShowEvent *evt);
	virtual void hideEvent(QHideEvent *evt);

	void updateMemberList();

private:
	Ui::DlgVoiceChange ui;
};

#endif // DLGVOICECHANGE_H
