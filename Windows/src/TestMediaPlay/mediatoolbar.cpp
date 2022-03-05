#include "stdafx.h"
#include "mediatoolbar.h"

MediaToolBar::MediaToolBar(QWidget *parent) : QFrame(parent)
{
	ui.setupUi(this);

	connect(ui.MediaStopBtn, SIGNAL(clicked()), this, SLOT(ss_mediaStopPlay()));
	connect(ui.MediaPlayBtn, SIGNAL(clicked()), this, SLOT(ss_mediaStartPlay()));
	connect(ui.MediaPauseBtn, SIGNAL(clicked()), this, SLOT(ss_meidaPausePlay()));

	connect(ui.PlayProgressBar, SIGNAL(valueChanged(int)), this, SLOT(ss_valueChanged(int)));
	connect(ui.VolumeProgressBar, SIGNAL(valueChanged(int)), this, SLOT(ss_valueChanged(int)));

	setFocusPolicy(Qt::ClickFocus);
	setFocusProxy(ui.PlayProgressBar);
	setVolume(g_sdkMain->getSDKMeeting().getMediaVolume());

	m_state = CRVSDK_MEDIAST_STOPPED;
	setMediaTotalTime(0);
	updateBtnState();

	this->setToolBarSize(32);
}


void MediaToolBar::setToolBarSize(int size)
{
	this->setFixedHeight(size);
	int bt_value = size - 6;//button大小
	ui.MediaPauseBtn->setFixedSize(bt_value, bt_value);
	ui.MediaStopBtn->setFixedSize(bt_value, bt_value);
	ui.MediaPlayBtn->setFixedSize(bt_value, bt_value);
	ui.volumeLabel->setFixedSize(bt_value, bt_value);
}


MediaToolBar::~MediaToolBar()
{

}

void MediaToolBar::ss_mediaStopPlay()
{
	emit s_stopPlayMedia();
}

void MediaToolBar::ss_mediaStartPlay()
{
	emit s_pauseMedia(false);
}

void MediaToolBar::ss_meidaPausePlay()
{
	emit s_pauseMedia(true);
}

void MediaToolBar::ss_valueChanged(int pos)
{
	SliderWithDescPoint *senderSlider = qobject_cast<SliderWithDescPoint*>(sender());
	if (senderSlider == ui.PlayProgressBar)
		emit s_playPosSetting(pos);
	else
		emit s_volumeChanged(pos);
}

void MediaToolBar::setMediaState(int state)
{
	//播放与暂停状态图片切换
	m_state = state;
	if ( state==CRVSDK_MEDIAST_STOPPED )
	{
		updatePlayPos(0);
	}
	updateBtnState();
}

void MediaToolBar::setVolume(int level)
{
	ui.VolumeProgressBar->blockSignals(true);
	ui.VolumeProgressBar->setValue(level);
	ui.VolumeProgressBar->blockSignals(false);
}

QString MediaToolBar::formatPts2String(int second, int maxSeconds)
{
	QTime t1(0, 0, 0);
	t1 = t1.addSecs(second);
	if ( second>=3600 || maxSeconds>3600 )
	{
		return t1.toString("HH:mm:ss");
	}
	else
	{
		return t1.toString("mm:ss");
	}
}

void MediaToolBar::updatePlayPos(qint64 ms)
{
	int maxDuration = ui.PlayProgressBar->maximum();
	ui.PlayTimelabel->setText(formatPts2String(int(ms / 1000), maxDuration));

	ui.PlayProgressBar->blockSignals(true);
	ui.PlayProgressBar->setValue(int(ms));
	ui.PlayProgressBar->blockSignals(false);
}

void MediaToolBar::setMediaTotalTime(int64_t ms)
{
	if (ms < 0)
	{
		ms = 0;
	}

	ui.PlayProgressBar->blockSignals(true);
	ui.PlayProgressBar->setRange(0, int(ms));
	ui.PlayProgressBar->blockSignals(false);
	ui.TotalTimelabel->setText(formatPts2String(int(ms / 1000)));
	updatePlayPos(0);
}

void MediaToolBar::enterEvent(QEvent *e)
{
	emit s_mouseEnter(true);
}

void MediaToolBar::leaveEvent(QEvent *e)
{
	emit s_mouseEnter(false);
}

void MediaToolBar::mousePressEvent(QMouseEvent *e)
{
	ui.PlayProgressBar->setFocus();
	e->setAccepted(true);
}

void MediaToolBar::updateBtnState()
{
	ui.MediaPlayBtn->setVisible(m_state != CRVSDK_MEDIAST_PLAYING);
	ui.MediaPauseBtn->setVisible(m_state == CRVSDK_MEDIAST_PLAYING);
}
