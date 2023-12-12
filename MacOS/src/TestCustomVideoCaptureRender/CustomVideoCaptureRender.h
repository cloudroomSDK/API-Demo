#ifndef CUSTOMVIDEOCAPTURERENDER_H
#define CUSTOMVIDEOCAPTURERENDER_H

#include "ui_CustomVideoCaptureRender.h"
#include "CustomRenderWidget.h"
#include "CustomRenderGLWidget.h"

class CustomVideoView : public CustomRenderWidget
{
public:
	CustomVideoView(QWidget *parent) : CustomRenderWidget(parent, CRVSDK_VIEWTP_VIDEO) {}
};

class CustomVideoView_GL : public CustomRenderGLWidget
{
public:
	CustomVideoView_GL(QWidget *parent) : CustomRenderGLWidget(parent, CRVSDK_VIEWTP_VIDEO) {}
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
	void inputCustomPic();
	virtual void notifyVideoStatusChanged(const char* userID, int oldStatus, int newStatus, const char* oprUserID);

private:
	Ui::CustomVideoCaptureRender ui;

	//采集部分
	bool m_bVideoCap;
	int m_capVideoDevID;
	int m_oldDefVideoID;

	//渲染部分
	CustomVideoView* m_customRenderView;
	CustomVideoView_GL* m_customRenderView_GL;
};

#endif // CUSTOMVIDEOCAPTURERENDER_H
