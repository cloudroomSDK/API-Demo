#ifndef MEDIAPLAYUI_H
#define MEDIAPLAYUI_H

#include "ui_MediaPlayUI.h"
#include "CustomRenderWidget.h"

class MediaPlayUI : public CustomRenderWidget, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT
public:
	MediaPlayUI(QWidget *parent = 0);
	~MediaPlayUI();

signals:
	void s_mediaPlaying(bool bPlaying);

protected:
	void notifyMediaOpened(int totalTime, int w, int h) override;
	void notifyMediaStart(const char* userID) override;
	void notifyMediaStop(const char* userID, CRVSDK_MEDIA_STOPREASON reason) override;
	void notifyMediaPause(const char* userID, bool bPause) override;

	void mouseMoveEvent(QMouseEvent *event) override;

protected slots:
	void slot_checkMeetingPlayMedia();
	void slot_hideAnimation();
	void slot_showAnimation();
	void slot_animationFinished();

	void slot_stopPlayMedia();
	void slot_pauseMedia(bool bPause);
	void slot_mouseEnterToolbar(bool);
	void slot_playPosSetting(int pts);
	void slot_volumeChanged(int level);

private:
	Ui::MediaPlayUI		ui;

	QTimer				m_hideBarTimer;
	QPropertyAnimation *m_animation;
	bool				m_bMouseInToolbar;

	CRMediaInfo			m_lastMyPlayMedia;
};

#endif // MEDIAPLAYUI_H
