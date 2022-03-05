#ifndef MEDIATOOLBAR_H
#define MEDIATOOLBAR_H

#include "ui_mediatoolbar.h"
class CloudroomMediaUI;
class MediaToolBar : public QFrame
{
	friend class CloudroomMediaUI;
	Q_OBJECT

signals:
	void s_stopPlayMedia();
	void s_pauseMedia(bool bPause);
	void s_playPosSetting(int ms);
	void s_mouseEnter(bool);
	void s_volumeChanged(int);

public:
	MediaToolBar(QWidget *parent = 0);
	~MediaToolBar();

	void setMediaTotalTime(int64_t ms);	//设置视频的播放总时间
	void setMediaState(int state);	//播放与暂停按钮切换
	void setVolume(int level);		//0~255

	void setToolBarSize(int size);

public slots:
	void updatePlayPos(qint64 ms);

protected:
	QString formatPts2String(int seconds, int maxSeconds=0);
	void setChildrenMouseTracking(QWidget *, bool);
 	void enterEvent(QEvent *e);
 	void leaveEvent(QEvent *e);
	void mousePressEvent(QMouseEvent *e);
	void updateBtnState();

protected slots:
	void ss_mediaStopPlay();
	void ss_mediaStartPlay();
	void ss_meidaPausePlay();
	void ss_valueChanged(int);

private:
	Ui::MediaToolBarUI	ui;
	int					m_state;
	QPoint				m_cursorPos;
	QSize				m_picSize;
};

#endif // MEDIATOOLBAR_H
