#ifndef CUSTOMVIDEOCAPTURERENDER_H
#define CUSTOMVIDEOCAPTURERENDER_H

#include "ui_CustomVideoCaptureRender.h"
#include "CustomRenderWidget.h"
#include "CustomRenderGLWidget.h"



class CustomVideoInputThread : public QThread
{
	Q_OBJECT
public:
	CustomVideoInputThread()
	{
		this->moveToThread(this);
		_timer.moveToThread(this);
		_timer.setTimerType(Qt::PreciseTimer);
		connect(&_timer, &QTimer::timeout, this, &CustomVideoInputThread::slot_doInput);
	}
	~CustomVideoInputThread() = default;

	void start(int videoID)
	{
		_id = videoID;
		QThread::start();
	}
	void stop()
	{
		QThread::quit();
	}

protected:
	virtual void run()
	{
		_timer.start(16); //fps 60
		QThread::run();
		_timer.stop();
	}

protected slots :
	void slot_doInput();

private:
	QTimer	_timer;
	int		_id{ 0 };
};


class CustomVideoCaptureRender : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT
public:
	CustomVideoCaptureRender(QWidget *parent = 0);
	~CustomVideoCaptureRender();

protected slots:
	void slot_videoCap();

protected:
	void notifyVideoStatusChanged(const char* userID, CRVSDK_VSTATUS oldStatus, CRVSDK_VSTATUS newStatus, const char* oprUserID) override;
	void showEvent(QShowEvent *evt) override;
	void hideEvent(QHideEvent *evt) override;

	void updateVideoID();

private:
	Ui::CustomVideoCaptureRender ui;

	//采集部分
	bool m_bVideoCap;
	int m_capVideoDevID;
	int m_oldDefVideoID;
	CustomVideoInputThread m_customInputThrd;

	//渲染部分
	CustomVideoView* m_customRenderView;
	CustomVideoView_GL* m_customRenderView_GL;

};

#endif // CUSTOMVIDEOCAPTURERENDER_H
