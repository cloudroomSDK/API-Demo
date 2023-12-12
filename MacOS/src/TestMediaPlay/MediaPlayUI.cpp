#include "stdafx.h"
#include "MediaPlayUI.h"
#include "KeepAspectRatioDrawer.h"
#include "maindialog.h"

MediaPlayUI::MediaPlayUI(QWidget *parent) : CustomRenderWidget(parent, CRVSDK_VIEWTP_MEDIA)
{
	setAttribute(Qt::WA_OpaquePaintEvent);
	setAttribute(Qt::WA_NoSystemBackground);
	setMouseTracking(true);
	ui.setupUi(this);

	//工具条事件
	connect(ui.mediaToolBar, &MediaToolBar::s_stopPlayMedia, this, &MediaPlayUI::slot_stopPlayMedia);
	connect(ui.mediaToolBar, &MediaToolBar::s_pauseMedia, this, &MediaPlayUI::slot_pauseMedia);
	connect(ui.mediaToolBar, &MediaToolBar::s_mouseEnter, this, &MediaPlayUI::slot_mouseEnterToolbar);
	connect(ui.mediaToolBar, &MediaToolBar::s_playPosSetting, this, &MediaPlayUI::slot_playPosSetting);
	connect(ui.mediaToolBar, &MediaToolBar::s_volumeChanged, this, &MediaPlayUI::slot_volumeChanged);
	connect(this, &CustomRenderWidget::s_recvFrame, ui.mediaToolBar, &MediaToolBar::updatePlayPos);

	//工具条动画
	m_animation = new QPropertyAnimation(ui.mediaToolBar, "pos");
	connect(m_animation, &QPropertyAnimation::finished, this, &MediaPlayUI::slot_animationFinished);
	m_hideBarTimer.setInterval(3000);
	m_hideBarTimer.setSingleShot(true);
	connect(&m_hideBarTimer, &QTimer::timeout, this, &MediaPlayUI::slot_hideAnimation);

	//关注影音共享消息
	g_sdkMain->getSDKMeeting().AddCallBack(this);

	QTimer::singleShot(10, this, &MediaPlayUI::slot_checkMeetingPlayMedia);
}

MediaPlayUI::~MediaPlayUI()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void MediaPlayUI::slot_checkMeetingPlayMedia()
{
	CRMediaInfo info = g_sdkMain->getSDKMeeting().getMediaInfo();
	if (info._state != CRVSDK_MEDIAST_STOPPED)
	{
		notifyMediaStart(info._userID.constData());
	}
}

void MediaPlayUI::notifyMediaOpened(int totalTime, int w, int h)
{
	ui.mediaToolBar->setMediaTotalTime(totalTime);
	ui.mediaToolBar->updatePlayPos(0);

	m_lastMyPlayMedia = g_sdkMain->getSDKMeeting().getMediaInfo();
	m_hideBarTimer.start();
}

void MediaPlayUI::notifyMediaStart(const char* userID)
{
	ui.mediaToolBar->setMediaState(CRVSDK_MEDIAST_PLAYING);
	//他人的影音共享，本地不能再操作
	if (MainDialog::getMyUserID()!=userID)
	{
		ui.mediaToolBar->hide();
		ui.mediaToolBar->setDisabled(true);
	}
	else
	{
		ui.mediaToolBar->show();
		ui.mediaToolBar->setEnabled(true);
	}
	emit s_mediaPlaying(true);
}

void MediaPlayUI::notifyMediaStop(const char* userID, CRVSDK_MEDIA_STOPREASON reason)
{
	ui.mediaToolBar->setMediaState(CRVSDK_MEDIAST_STOPPED);
	ui.mediaToolBar->setEnabled(true);
	emit s_mediaPlaying(false);
}

void MediaPlayUI::notifyMediaPause(const char* userID, bool bPause)
{
	ui.mediaToolBar->setMediaState(bPause ? CRVSDK_MEDIAST_PAUSED:CRVSDK_MEDIAST_PLAYING);
}


void MediaPlayUI::slot_stopPlayMedia()
{
	g_sdkMain->getSDKMeeting().stopPlayMedia();
}

void MediaPlayUI::slot_pauseMedia(bool bPause)
{
	CRMediaInfo info = g_sdkMain->getSDKMeeting().getMediaInfo();
	if (info._state == CRVSDK_MEDIAST_STOPPED)
	{
		if (m_lastMyPlayMedia._mediaName.length() > 0)
		{
			g_sdkMain->getSDKMeeting().startPlayMedia(m_lastMyPlayMedia._mediaName.constData());
		}
	}
	else
	{
		g_sdkMain->getSDKMeeting().pausePlayMedia(bPause);
	}
}

void MediaPlayUI::slot_mouseEnterToolbar(bool isIn)
{
	m_bMouseInToolbar = isIn;
}

void MediaPlayUI::slot_playPosSetting(int pts)
{
	g_sdkMain->getSDKMeeting().setMediaPlayPos(pts);
}

void MediaPlayUI::slot_volumeChanged(int level)
{
	g_sdkMain->getSDKMeeting().setMediaVolume(level);
}

void MediaPlayUI::mouseMoveEvent(QMouseEvent *event)
{
	if (m_hideBarTimer.isActive())
	{
		m_hideBarTimer.stop();
	}
	slot_showAnimation();
	m_hideBarTimer.start();
}

void MediaPlayUI::slot_hideAnimation()
{
	if (!ui.mediaToolBar->isVisible())
	{
		return;
	}
	if (m_bMouseInToolbar)//如果鼠标在工具栏中，则不隐藏
	{
		return;
	}
	m_animation->setProperty("show", false);
	QPoint p = ui.mediaToolBar->pos();
	m_animation->setDuration(200);
	m_animation->setStartValue(p);
	m_animation->setEndValue(QPoint(0, height()));
	m_animation->start();
}

void MediaPlayUI::slot_showAnimation()
{
	if (ui.mediaToolBar->isVisibleTo(this))
	{
		return;
	}
	//他人在共享时，阻止工具条显示
	if (!ui.mediaToolBar->isEnabledTo(this))
	{
		return;
	}
	ui.mediaToolBar->show();
	m_animation->setProperty("show", true);
	QPoint p = ui.mediaToolBar->pos();
	m_animation->setDuration(200);
	m_animation->setStartValue(p);
	m_animation->setEndValue(QPoint(0, height() - ui.mediaToolBar->height()));
	m_animation->start();
}

//动画结束
void MediaPlayUI::slot_animationFinished()
{
	if (!m_animation->property("show").toBool())
	{
		ui.mediaToolBar->setVisible(false);
	}
}