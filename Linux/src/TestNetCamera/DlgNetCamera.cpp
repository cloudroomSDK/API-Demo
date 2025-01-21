#include "stdafx.h"
#include "DlgNetCamera.h"
#include "maindialog.h"

#define DEV_NAME "net_camera"


int DlgNetCamera::s_netCamID = -1;
int DlgNetCamera::s_oldDefVideoID = -1;
QString DlgNetCamera::s_netCamUrl;

DlgNetCamera::DlgNetCamera(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);	
	connect(ui.btnOperate, &QPushButton::clicked, this, &DlgNetCamera::slot_btnOperateClicked);

	g_sdkMain->getSDKMeeting().AddCallBack(this);
	init();
}

DlgNetCamera::~DlgNetCamera()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgNetCamera::init()
{
	ui.editUrl->setText(s_netCamUrl);
	updateUI();
}

void DlgNetCamera::updateUI()
{
	ui.btnOperate->setText(s_netCamID == -1 ? tr("添加") : tr("删除"));
	if (s_netCamID == -1)
	{
		ui.videoView->setVideoID(CRUserVideoID());
	}
	else
	{
		//打开
		g_sdkMain->getSDKMeeting().openVideo(MainDialog::getMyUserID().constData());
		ui.videoView->setVideoID(CRUserVideoID(MainDialog::getMyUserID(), s_netCamID));
	}
}

void DlgNetCamera::addCam()
{
	QVariantMap params;
	params["maxRetry"] = 1;
	QByteArray jsonParams = CoverJsonToString(params);

	int rslt = g_sdkMain->getSDKMeeting().addIPCam(qStrToStdStr(ui.editUrl->text()).c_str(), jsonParams.constData());
	if (rslt < 0)
	{
		QMessageBox::information(this, tr("提示"), tr("添加网络摄像头失败（%1）").arg(getErrDesc((CRVSDK_ERR_DEF)rslt)));
		return;
	}
	s_netCamID = rslt;
	s_netCamUrl = ui.editUrl->text();

	//切换到该设备，并保存之前的默认设备
	s_oldDefVideoID = g_sdkMain->getSDKMeeting().getDefaultVideo(MainDialog::getMyUserID().constData());
	g_sdkMain->getSDKMeeting().setDefaultVideo(s_netCamID);
	updateUI();
}

void DlgNetCamera::delCam()
{
	g_sdkMain->getSDKMeeting().delIPCam(s_netCamID);
	s_netCamID = -1;
	g_sdkMain->getSDKMeeting().setDefaultVideo(s_oldDefVideoID);
	updateUI();
}

void DlgNetCamera::slot_btnOperateClicked()
{
	if (s_netCamID == -1)
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
	if (s_netCamID == -1)
		return;

	if (!isSucceed)
	{
		delCam();
		QMessageBox::information(this, tr("提示"), tr("打开网络摄像头失败"));
	}
}