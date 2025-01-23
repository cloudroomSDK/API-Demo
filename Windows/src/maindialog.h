#ifndef MAINDIALOG_H
#define MAINDIALOG_H

#include "DlgLogin.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainDialog; }
QT_END_NAMESPACE

class DlgLogin;
class DlgLocalRecord;
class DlgServerRecord;
class VideoWallPage;
class CustomAudioCapture;
class CustomVideoCaptureRender;
class MediaPlayUI;
class ScreenShareUI;
class DlgRoomMsg;

#include "./TestRoomUsrAttrs/DlgRoomAttrs.h"
#include "./TestNetCamera/DlgNetCamera.h"
#include "./TestRoomUsrAttrs/DlgUserSelect.h"


class MainDialog : public QDialog
{
    Q_OBJECT

public:
	MainDialog(QWidget *parent, int meetId, const QString &userId);
	~MainDialog();

	static int getMeetID(){ return m_meetId; }
	static CRString getMyUserID(){ return m_myUserId; }

	QVariant getRecordContents(const QSize &recSize);

signals:
	void s_viewChanged();

protected:
	void slot_btnBaseFuncClicked();
	void slot_btnHigherFuncClicked();
	void slot_btnAudioSetClicked();
	void slot_btnVideoSetClicked();
	void slot_btnLocRecordClicked();
	void slot_btnSvrRecordClicked();
	void slot_btnMediaClicked();
	void slot_btnStartScreenClicked();
	void slot_btnStopScreenClicked();
	void slot_btnCustomAudioClicked();
	void slot_btnCustomVideoClicked();
	void slot_btnRoomMsgClicked();
	void slot_btnRoomSetClicked();
	void slot_btnMemberSetClicked();
	void slot_btnNetCameraClicked();
	void slot_btnVoiceChangeClicked();
	void slot_btnEchoTestClicked();
	void slot_btnSubAudioClicked();
	void slot_btnBeautyClicked();
	

	void slot_mediaPlaying(bool bPlaying);
	void slot_screenShareStateChanged(bool bShare);

private:
	Ui::MainDialog *ui;
	static CRString m_myUserId;
	static int m_meetId;
	
	VideoWallPage *m_videoWallPage;
	MediaPlayUI	*m_mediaPlayUI;
	ScreenShareUI *m_screeShareUI;

	DlgServerRecord *m_dlgSvrRecord;
	CustomAudioCapture *m_customAudioCapture;
	CustomVideoCaptureRender *m_customVideoCaptureRender;
	DlgRoomMsg *m_dlgRoomMsg;

	QPointer<DlgLocalRecord> m_dlgLocRecord;
	QPointer<DlgUserSelect> m_dlgUserSelect;
	QPointer<DlgRoomAttrs> m_dlgRoomAttrs;
	QPointer<DlgNetCamera> m_dlgNetCamera;
};

extern MainDialog *g_mainDialog;
#endif // MAINDIALOG_H
