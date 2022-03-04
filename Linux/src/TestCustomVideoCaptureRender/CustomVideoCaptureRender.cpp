#include "stdafx.h"
#include "CustomVideoCaptureRender.h"
#include "maindialog.h"

#define VideoCapFPS 24
#define VideoRate (float)16/9
CRVSDK_VIDEO_FORMAT InputFrmFmt = CRVSDK_VFMT_YUV420P;  //420p内部效率最高

CustomVideoCaptureRender::CustomVideoCaptureRender(QWidget *parent) : QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);
	m_capRenderView = new CustomVideoView(this);
	ui.capRenderLayout->addWidget(m_capRenderView);
	m_customRenderView = new CustomVideoView(this);
	ui.customRenderLayout->addWidget(m_customRenderView);

	m_bVideoCap = false;
	m_capVideoDevID = 0;
	m_oldDefVideoID = -1;
	float videoRate = (float)16 / 9;
	int h = 400 / videoRate;
	m_capRenderView->setFixedSize(400, h);
	connect(ui.btnVideoCap, &QPushButton::clicked, this, &CustomVideoCaptureRender::slot_videoCap);

	m_bVideoRender = false;
	m_customRenderView->setFixedSize(400, h);
	connect(ui.btnVideoRender, &QPushButton::clicked, this, &CustomVideoCaptureRender::slot_videoRender);

	//引擎渲染（仅windows生效）
	CRUserVideoID userVideoID(MainDialog::getMyUserID());
	ui.videoCanvas->setFixedSize(400, h);
	ui.videoCanvas->setVideoID(userVideoID);
	g_sdkMain->getSDKMeeting().AddCallBack(this);
}

CustomVideoCaptureRender::~CustomVideoCaptureRender()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
	//当前有视频采集，需要停止
	if (m_bVideoCap)
	{
		slot_videoCap();
	}
	//当前有视频渲染，需要停止
	if (m_bVideoRender)
	{
		slot_videoRender();
	}
}

///////////////自定义采集///////////////////
void CustomVideoCaptureRender::slot_videoCap()
{
	bool bCap = !m_bVideoCap;
	if (bCap)//开始视频采集
	{
		//添加一个自定义设备
		m_capVideoDevID = g_sdkMain->getSDKMeeting().createCustomVideoDev(qStrToStdStr(makeUUID()).c_str(), InputFrmFmt, 1280, 720, "");
		if (m_capVideoDevID <= 0)
		{
			QMessageBox::information(this, "提示", tr("开始视频自定义采集"));
			return;
		}

		//切换到该设备，并保存之前的默认设备
		m_oldDefVideoID = g_sdkMain->getSDKMeeting().getDefaultVideo(MainDialog::getMyUserID().constData());
		g_sdkMain->getSDKMeeting().setDefaultVideo(m_capVideoDevID);
		
		m_capRenderView->setVideoID(CRUserVideoID(MainDialog::getMyUserID(), m_capVideoDevID)); 
		g_sdkMain->getSDKMeeting().openVideo(MainDialog::getMyUserID().constData());

		//送入图像(如果图像有变化，可启动定时器，定时送入不同图像）
		inputCustomPic();
	}
	else//停止视频采集
	{
		m_capRenderView->setVideoID(CRUserVideoID());
		m_capRenderView->clearFrame();
		//恢复之前的默认设备
		g_sdkMain->getSDKMeeting().setDefaultVideo(m_oldDefVideoID);
		
		//删除自定义设备
		g_sdkMain->getSDKMeeting().destroyCustomVideoDev(m_capVideoDevID);
	}
	ui.btnVideoCap->setText(bCap ? tr("停止视频自定义采集") : tr("开始视频自定义采集"));
	m_bVideoCap = bCap;
}

void CustomVideoCaptureRender::inputCustomPic()
{
    CRByteArray jpgDat;
    ReadDataFromFile(":/Resources/custom_video_1280x720.jpg", jpgDat);

    CRVideoFrame frm;
    if (g_sdkMain->coverToVideoFrame(jpgDat, "jpg", frm) != 0)
	{
        QMessageBox::information(this, "提示", tr("解码 :/Resources/custom_video_1280x720.jpg 失败"));
		return;
	}
	g_sdkMain->videoFrameCover(frm, InputFrmFmt, frm.getWidth(), frm.getHeight());
	g_sdkMain->getSDKMeeting().inputCustomVideoDat(m_capVideoDevID, frm);
}


///////////////自定义渲染///////////////////
void CustomVideoCaptureRender::slot_videoRender()
{
	bool bRender = !m_bVideoRender;
	if (bRender)//开始视频渲染
	{
		CRUserVideoID userVideoID(MainDialog::getMyUserID());
		//确保打开摄像头
		g_sdkMain->getSDKMeeting().openVideo(userVideoID._userID.constData());
		//设置要渲染的视频源
		m_customRenderView->setVideoID(userVideoID);
	}
	else//停止视频渲染
	{
		m_customRenderView->setVideoID(CRUserVideoID());
		m_customRenderView->clearFrame();
	}
	ui.btnVideoRender->setText(bRender ? tr("停止视频自定义渲染") : tr("开始视频自定义渲染"));
	m_bVideoRender = bRender;
}


void CustomVideoCaptureRender::notifyVideoStatusChanged(const char* userID, int oldStatus, int newStatus, const char* oprUserID)
{
	if (MainDialog::getMyUserID() != userID)
	{
		return;
	}

	CRVSDK_VSTATUS videoStatus = (CRVSDK_VSTATUS)newStatus;
	ui.videoCanvas->setVideoID(videoStatus != CRVSDK_VST_OPEN ? CRUserVideoID() : CRUserVideoID(MainDialog::getMyUserID()));
}