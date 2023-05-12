#include "stdafx.h"
#include "ScreenShareUI.h"
#include "KeepAspectRatioDrawer.h"
#include "maindialog.h"

ScreenShareUI::ScreenShareUI(QWidget *parent) : CustomRenderWidget(parent, CRVSDK_VIEWTP_SCREEN)
{
	setAttribute(Qt::WA_OpaquePaintEvent);
	setAttribute(Qt::WA_NoSystemBackground);
	ui.setupUi(this);

	//关注屏幕共享消息
	g_sdkMain->getSDKMeeting().AddCallBack(this);
}

ScreenShareUI::~ScreenShareUI()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

//开启屏幕共享结果
void ScreenShareUI::startScreenShareRslt(CRVSDK_ERR_DEF sdkErr)
{
	if (sdkErr == CRVSDKERR_NOERR)
	{
		notifyScreenShareStarted(MainDialog::getMyUserID().constData());
		return;
	}
	QMessageBox::information(this, tr("屏幕共享"), tr("开启屏幕共享失败（%1）").arg(getErrDesc(sdkErr)));
}

//停止屏幕共享结果
void ScreenShareUI::stopScreenShareRslt(CRVSDK_ERR_DEF sdkErr)
{
	if (sdkErr == CRVSDKERR_NOERR)
	{
		notifyScreenShareStopped(MainDialog::getMyUserID().constData());
		return;
	}
	QMessageBox::information(this, tr("屏幕共享"), tr("停止屏幕共享失败（%1）").arg(getErrDesc(sdkErr)));
}

//通知屏幕共享开始
void ScreenShareUI::notifyScreenShareStarted(const char* userID)
{
	if (MainDialog::getMyUserID() == userID)
	{
		enabledRender(false);
		ui.lbDesc->show();
	}
	else
	{
		enabledRender(true);
		ui.lbDesc->hide();
	}
	emit s_shareStateChanged(true);
}

//通知屏幕共享停止
void ScreenShareUI::notifyScreenShareStopped(const char* oprUserID)
{
	ui.lbDesc->hide();
	emit s_shareStateChanged(false);
}