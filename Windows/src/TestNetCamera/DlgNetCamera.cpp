#include "stdafx.h"
#include "DlgNetCamera.h"
#include "maindialog.h"

#define DEV_NAME "net_camera"
DlgNetCamera::DlgNetCamera(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);	
	m_videoView = new NetVideoView(this);
	ui.videoLayout->addWidget(m_videoView);

	connect(ui.btnOperate, &QPushButton::clicked, this, &DlgNetCamera::slot_btnOperateClicked);

	g_sdkMain->getSDKMeeting().AddCallBack(this);
	init();
}

DlgNetCamera::~DlgNetCamera()
{
	if (m_videoID != -1)
	{
		delCam();
	}
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgNetCamera::init()
{
	m_videoID = -1;
	CRBase::CRArray<CRVideoDevInfo> camDevs = g_sdkMain->getSDKMeeting().getAllVideoInfo(MainDialog::getMyUserID().constData());
	for (uint32_t i = 0; i < camDevs.count(); i++)
	{
		const CRVideoDevInfo &devInfo = camDevs.item(i);
		if (devInfo._devName == DEV_NAME)
		{
			m_videoID = devInfo._videoID;
			ui.editUrl->setText(devInfo._devGuid.constData());
			break;
		}
	}
	updateUI();
}

void DlgNetCamera::updateUI()
{
	ui.btnOperate->setText(m_videoID == -1 ? tr("添加") : tr("删除"));
	if (m_videoID == -1)
	{
		m_videoView->setVideoID(CRUserVideoID());
		m_videoView->clearFrame();
		//恢复之前的默认设备
		g_sdkMain->getSDKMeeting().setDefaultVideo(m_oldDefVideoID);
	}
	else
	{
		//切换到该设备，并保存之前的默认设备
		m_oldDefVideoID = g_sdkMain->getSDKMeeting().getDefaultVideo(MainDialog::getMyUserID().constData());
		g_sdkMain->getSDKMeeting().setDefaultVideo(m_videoID);
		//打开
		g_sdkMain->getSDKMeeting().openVideo(MainDialog::getMyUserID().constData());
		m_videoView->setVideoID(CRUserVideoID(MainDialog::getMyUserID(), m_videoID));
	}
}

void DlgNetCamera::addCam()
{
	QVariantMap params;
	params["maxRetry"] = 1;
	QByteArray jsonParams = QJsonDocument::fromVariant(params).toJson();

	int rslt = g_sdkMain->getSDKMeeting().addIPCam(qStrToStdStr(ui.editUrl->text()).c_str(), jsonParams.constData());
	if (rslt < 0)
	{
		QMessageBox::information(this, tr("提示"), tr("添加网络摄像头失败（%1）").arg(getErrDesc((CRVSDK_ERR_DEF)rslt)));
		return;
	}
	m_videoID = rslt;
	updateUI();
}

void DlgNetCamera::delCam()
{
	g_sdkMain->getSDKMeeting().delIPCam(m_videoID);
	m_videoID = -1;
	updateUI();
}

void DlgNetCamera::slot_btnOperateClicked()
{
	if (m_videoID == -1)
	{
		addCam();
	}
	else
	{
		delCam();
	}
}

void DlgNetCamera::openVideoDevRslt(int videoID, bool isSucceed)
{
	if (m_videoID == -1)
		return;

	if (!isSucceed)
	{
		delCam();
		QMessageBox::information(this, tr("提示"), tr("打开网络摄像头失败"));
	}
}