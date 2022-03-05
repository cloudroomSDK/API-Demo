#ifndef DLGNETCAMERA_H
#define DLGNETCAMERA_H

#include "ui_DlgNetCamera.h"
#include "CustomRenderWidget.h"

class NetVideoView : public CustomRenderWidget
{
public:
	NetVideoView(QWidget *parent) : CustomRenderWidget(parent, CRVSDK_VIEWTP_VIDEO) {}
};

class DlgNetCamera : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgNetCamera(QWidget *parent = 0);
	~DlgNetCamera();

protected slots:
	void slot_btnOperateClicked();

protected:
	void init();
	void updateUI();
	void addCam();
	void delCam();
	virtual void openVideoDevRslt(int videoID, bool isSucceed);

private:
	Ui::DlgNetCamera ui;
	NetVideoView *m_videoView;
	int m_videoID;
	int m_oldDefVideoID;
};

#endif // DLGNETCAMERA_H
