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

class DlgRoomAttrs;
class DlgUserSelect;
class DlgRoomMsg;
class DlgNetCamera;

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
	void slot_btnCustomAudioClicked();
	void slot_btnCustomVideoClicked();
	void slot_btnRoomMsgClicked();
	void slot_btnRoomSetClicked();
	void slot_btnMemberSetClicked();
	void slot_btnNetCameraClicked();
	void slot_btnVoiceChangeClicked();
	void slot_btnEchoTestClicked();

	void slot_mediaPlaying(bool bPlaying);

private:
	Ui::MainDialog *ui;
	static CRString m_myUserId;
	static int m_meetId;
	
	VideoWallPage *m_videoWallPage;
	DlgLocalRecord *m_dlgLocRecord;
	DlgServerRecord *m_dlgSvrRecord;
	CustomAudioCapture *m_customAudioCapture;
	CustomVideoCaptureRender *m_customVideoCaptureRender;

	MediaPlayUI	*m_mediaPlayUI;

	DlgRoomAttrs *m_dlgRoomAttrs;
	DlgUserSelect *m_dlgUserSelect;
	DlgRoomMsg *m_dlgRoomMsg;
	DlgNetCamera *m_dlgNetCamera;
};

extern MainDialog *g_mainDialog;
#endif // MAINDIALOG_H
