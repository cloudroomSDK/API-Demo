#ifndef ScreenShareUI_H
#define ScreenShareUI_H

#include "ui_ScreenShareUI.h"
#include "CustomRenderWidget.h"
#include "ui_ScreenSharerToolBar.h"

class DlgScreenMark;
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
	//开启屏幕共享标注结果
	void startScreenMarkRslt(CRVSDK_ERR_DEF sdkErr) override;
	//停止屏幕共享标注结果
	void stopScreenMarkRslt(CRVSDK_ERR_DEF sdkErr) override;
	//通知屏幕共享标注开始
	void notifyScreenMarkStarted() override;
	//通知屏幕共享标注停止
	void notifyScreenMarkStopped() override;

protected:
	void resizeEvent(QResizeEvent *event) override;
	void paintEvent(QPaintEvent *event) override;

protected slots:
	void slot_recvFrame(qint64 ts);
	void showMarkDlg();
	void slot_startMarkClicked();
	void slot_stopMarkClicked();
	void slot_openMarkDlgClicked();
	void updateToolbar();

private:
	Ui::ScreenShareUI		ui;
	Ui::ScreenSharerToolBar		uiToolbar;
	QWidget *m_toolbar;
	DlgScreenMark *m_dlgMark;
	bool m_bForSharer;
};

#endif // ScreenShareUI_H
