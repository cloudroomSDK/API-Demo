#ifndef ScreenShareUI_H
#define ScreenShareUI_H

#include "ui_ScreenShareUI.h"
#include "CustomRenderWidget.h"
#include "ui_ScreenSharerToolBar.h"
#include "KeyBoardCatcher.h"

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

	//通知给予某人控制权限
	void notifyGiveCtrlRight(const char* operUserId, const char* targetUserId) override;
	//通知释放了控制权限
	void notifyReleaseCtrlRight(const char* operUserId, const char* targetUserId) override;

protected:
	void resizeEvent(QResizeEvent *event) override;
	void paintEvent(QPaintEvent *event) override;

	bool focusNextPrevChild(bool next) override;

	void mousePressEvent(QMouseEvent *) override;
	void mouseReleaseEvent(QMouseEvent *) override;
	void mouseMoveEvent(QMouseEvent *) override;
	void mouseDoubleClickEvent(QMouseEvent *) override;
	void wheelEvent(QWheelEvent *) override;

protected:
	void setCtrlState(bool bCtrling);
	QPoint mapToRemote(const QPoint &pos);
	void sendMousePressMsg(QMouseEvent *e);

protected slots:
	void slot_recvFrame(qint64 ts);
	void slot_startMarkClicked();
	void slot_stopMarkClicked();
	void slot_openMarkDlgClicked();

	void slot_remoteCtrlBtnClicked();
	void slot_remoteCtrlTriggered(QAction *pAct);
	void showMarkDlg();
	void updateToolbar();

private:
	Ui::ScreenShareUI			ui;
	Ui::ScreenSharerToolBar		uiToolbar;
	QWidget*					m_toolbar{ nullptr };
	DlgScreenMark*				m_dlgMark{ nullptr };
	bool						m_bForSharer{ false };
	bool						m_bCtrling{ false };
	KeyBoardCatcher*			m_keyCatcher{ nullptr };
};

#endif // ScreenShareUI_H
