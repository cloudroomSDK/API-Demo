#ifndef VIDEOWALLPAGE_H
#define VIDEOWALLPAGE_H


QT_BEGIN_NAMESPACE
namespace Ui {class VideoWallPage;}
QT_END_NAMESPACE

#define VIDEO_WALL_SPACE 2

class KVideoUI;
class VideoWallPage : public QWidget, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	VideoWallPage(QWidget* pParent = 0);
	~VideoWallPage();

	//设置视频墙显示模式：主模式/从模式
	void setVideoWallMode(bool asMain);

	const QList<KVideoUI*>& getVideos() { return m_videos; }

signals:
	void s_contentChanged();

protected:
	virtual void resizeEvent(QResizeEvent *event);

	virtual void notifyNetStateChanged(int level);
	virtual void notifyUserEnterMeeting(const char* userID);
	virtual void notifyUserLeftMeeting(const char* userID);
	virtual void notifyNickNameChanged(const char* userID, const char* oldName, const char* newName, const char* oprUserID);

	virtual void notifyMicStatusChanged(const char* userID, CRVSDK_ASTATUS oldStatus, CRVSDK_ASTATUS newStatus, const char* oprUserID);
	virtual void notifyMicEnergy(const char* userID, int oldLevel, int newLevel);

	virtual void notifyVideoStatusChanged(const char* userID, CRVSDK_VSTATUS oldStatus, CRVSDK_VSTATUS newStatus, const char* oprUserID);
	virtual void notifyVideoDevChanged(const char* userID);

private:
	KVideoUI* createVideoUI();
	QList<KVideoUI*> findVideoUIByUserID(const char* userID);
	KVideoUI* findUnusedUI();
	KVideoUI* findLastUsedUI();
	bool isWallPageFull();
	void replaceByLastUsedUI(KVideoUI *pVUI);
	CRUserVideoID findUserNotInWall();
	void delVideoUI(KVideoUI*);
	void clearVideoUIS();

	void ResetVideoUis();
	void MakeVideoUis();

	void resetVideoWidgetSize();
	void relayoutVideoWidgets_H();
	void resetVideoWidgetSize_H();
	QList<CRUserVideoID> addUserToVideoList(const CRBase::CRString &userId, bool bInsertFront);

private:
	Ui::VideoWallPage*		ui;
	bool				m_asMainMode;

	QList<KVideoUI*>	m_videos;
	QList<KVideoUI*>	m_freeVUIs;
};

#endif	//VIDEOWALLPAGE_H
