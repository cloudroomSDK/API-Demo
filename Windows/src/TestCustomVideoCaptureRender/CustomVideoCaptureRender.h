#ifndef CUSTOMVIDEOCAPTURERENDER_H
#define CUSTOMVIDEOCAPTURERENDER_H

#include "ui_CustomVideoCaptureRender.h"
#include "CustomRenderWidget.h"

class CustomVideoView : public CustomRenderWidget
{
public:
	CustomVideoView(QWidget *parent) : CustomRenderWidget(parent, CRVSDK_VIEWTP_VIDEO) {}
};

class CustomVideoCaptureRender : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT
public:
	CustomVideoCaptureRender(QWidget *parent = 0);
	~CustomVideoCaptureRender();

protected slots:
	void slot_videoCap();
	void slot_videoRender();

protected:
	void inputCustomPic();
	virtual void notifyVideoStatusChanged(const char* userID, int oldStatus, int newStatus, const char* oprUserID);

private:
	Ui::CustomVideoCaptureRender ui;

	//采集部分
	bool m_bVideoCap;
	int m_capVideoDevID;
	int m_oldDefVideoID;
	CustomVideoView* m_capRenderView;

	//渲染部分
	bool m_bVideoRender;
	CustomVideoView* m_customRenderView;
};

#endif // CUSTOMVIDEOCAPTURERENDER_H
