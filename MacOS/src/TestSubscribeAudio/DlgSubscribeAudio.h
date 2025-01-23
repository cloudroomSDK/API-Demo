#ifndef DLGSUBSCRIBEAUDIO_H
#define DLGSUBSCRIBEAUDIO_H

#include "ui_DlgSubscribeAudio.h"

class DlgSubscribeAudio : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgSubscribeAudio(QWidget *parent = 0);
	~DlgSubscribeAudio();


protected slots:
	void slot_modeChanged();
	void slot_listTpyeChanged();
	void slot_listMembersClicked(QListWidgetItem *item);
	void slot_listSubsClicked(QListWidgetItem *item);

private:
	Ui::DlgSubscribeAudio ui;

	struct UserInfo
	{
		QString userId;
		QString nickName;
	};
	struct SubInfo
	{
		CRVSDK_ASUBSCRIB_MODE mode;			//订阅模式
		CRVSDK_ASUBSCRIB_LISTTYPE listType;	//订阅列表类型
		QList<UserInfo> subUserList;		//订阅列表
		SubInfo()
		{
			mode = CRVSDK_ASM_MIXED;
			listType = CRVSDK_ASLT_INCLUDE;
			subUserList.clear();
		}
	};
	static SubInfo m_info;

protected:
	void init();
	QList<DlgSubscribeAudio::UserInfo> getSubListFromUI();
	void setSubListToSdk();
};

#endif // DLGSUBSCRIBEAUDIO_H
