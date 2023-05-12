#ifndef ScreenShareUI_H
#define ScreenShareUI_H

#include "ui_ScreenShareUI.h"
#include "CustomRenderWidget.h"

class ScreenShareUI : public CustomRenderWidget, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT
public:
	ScreenShareUI(QWidget *parent = 0);
	~ScreenShareUI();

signals:
	void s_shareStateChanged(bool bShare);

protected:
	//开启屏幕共享结果
	void startScreenShareRslt(CRVSDK_ERR_DEF sdkErr) override;
	//停止屏幕共享结果
	void stopScreenShareRslt(CRVSDK_ERR_DEF sdkErr) override;
	//通知屏幕共享开始
	void notifyScreenShareStarted(const char* userID) override;
	//通知屏幕共享停止
	void notifyScreenShareStopped(const char* oprUserID) override;
	
private:
	Ui::ScreenShareUI		ui;
};

#endif // ScreenShareUI_H
