#include "stdafx.h"
#include "CustomVideoCaptureRender.h"
#include "maindialog.h"

#define VideoRate (float)16/9
CRVSDK_VIDEO_FORMAT InputFrmFmt = CRVSDK_VFMT_YUV420P;  //420p内部效率最高

CustomVideoCaptureRender::CustomVideoCaptureRender(QWidget *parent) : QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);
	m_customRenderView = new CustomVideoView(this);
	ui.customRenderLayout->addWidget(m_customRenderView);

    m_customRenderView_GL = new CustomVideoView_GL(this);
    ui.customRenderLayoutGL->addWidget(m_customRenderView_GL);
	
	m_bVideoCap = false;
	m_capVideoDevID = 0;
	m_oldDefVideoID = -1;
	connect(ui.btnVideoCap, &QPushButton::clicked, this, &CustomVideoCaptureRender::slot_videoCap);

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
		
		g_sdkMain->getSDKMeeting().openVideo(MainDialog::getMyUserID().constData());

		m_customInputThrd.start(m_capVideoDevID);
	}
	else//停止视频采集
	{
		m_customInputThrd.stop();

		//恢复之前的默认设备
		g_sdkMain->getSDKMeeting().setDefaultVideo(m_oldDefVideoID);
		
		//删除自定义设备
		g_sdkMain->getSDKMeeting().destroyCustomVideoDev(m_capVideoDevID);
	}
	ui.btnVideoCap->setText(bCap ? tr("停止视频自定义采集") : tr("开始视频自定义采集"));
	m_bVideoCap = bCap;
}

void CustomVideoCaptureRender::notifyVideoStatusChanged(const char* userID, CRVSDK_VSTATUS oldStatus, CRVSDK_VSTATUS newStatus, const char* oprUserID)
{
	if (MainDialog::getMyUserID() != userID)
	{
		return;
	}
	updateVideoID();
}

void CustomVideoCaptureRender::updateVideoID()
{
	CRVSDK_VSTATUS videoStatus = g_sdkMain->getSDKMeeting().getVideoStatus(MainDialog::getMyUserID().constData());
	bool bShow = (this->isVisible() && videoStatus == CRVSDK_VST_OPEN);
	CRUserVideoID userVideoID;
	if (bShow)
	{
		userVideoID = CRUserVideoID(MainDialog::getMyUserID());
	}

	m_customRenderView->setVideoID(userVideoID);
	m_customRenderView_GL->setVideoID(userVideoID);
	ui.videoCanvas->setVideoID(userVideoID);
}


void CustomVideoCaptureRender::showEvent(QShowEvent *evt)
{
	QDialog::showEvent(evt);
	updateVideoID();


}

void CustomVideoCaptureRender::hideEvent(QHideEvent *evt)
{
	QDialog::hideEvent(evt);
	updateVideoID();
}

//////////////////////////////////////////////////////////////////////////
// CustomVideoInputThread
void CustomVideoInputThread::slot_doInput()
{
	CRVSDK_ERR_DEF err;

	static CRVideoFrame frm;
	if (frm.getFormat() == CRVSDK_VFMT_INVALID)
	{
		CRByteArray jpgDat;
		ReadDataFromFile(":/Resources/custom_video_1280x720.jpg", jpgDat);

		if ((err=g_sdkMain->coverToVideoFrame(jpgDat, "jpg", frm)) != 0)
		{
			qDebug("decode jpg failed: %d!", err);
			return;
		}
		if (!g_sdkMain->videoFrameCover(frm, InputFrmFmt, frm.getWidth(), frm.getHeight()))
		{
			qDebug("decode jpg failed!");
			return;
		}
	}

	if ((err = g_sdkMain->getSDKMeeting().inputCustomVideoDat(_id, frm)) != 0)
	{
		qDebug("inputCustomVideoDat failed: %d!", err);
		return;
	}
}

