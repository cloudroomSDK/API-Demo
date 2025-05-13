#ifndef MAINDIALOG_H
#define MAINDIALOG_H

#include "DlgLogin.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainDialog; }
QT_END_NAMESPACE

class DlgLogin;
class DlgAudioSet;
class DlgVideoSet;
class DlgLocalRecord;
class DlgServerRecord;
class VideoWallPage;
class CustomAudioCapture;
class CustomVideoCaptureRender;
class MediaPlayUI;
class ScreenShareUI;
class DlgRoomMsg;
class DlgEchoTest;
class DlgSubscribeAudio;
class TestVideoBeauty;
class TestVirtualBackground;
class DlgRoomAttrs;
class DlgNetCamera;
class DlgUserSelect;


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
	void slot_btnVirtualBKClicked();

	void slot_mediaPlaying(bool bPlaying);
	void slot_screenShareStateChanged(bool bShare);

protected:
	void keyPressEvent(QKeyEvent *event) override;

	void showDlg(QDialog *p);
private:
	Ui::MainDialog *ui{ nullptr };
	static CRString m_myUserId;
	static int m_meetId;
	
	VideoWallPage *m_videoWallPage{ nullptr };
	MediaPlayUI	*m_mediaPlayUI{ nullptr };
	ScreenShareUI *m_screeShareUI{ nullptr };

	QPointer<DlgAudioSet> m_dlgAudioSet;
	QPointer<DlgVideoSet> m_dlgVideoSet;
	QPointer<CustomAudioCapture> m_customAudioCapture;
	QPointer<CustomVideoCaptureRender> m_customVideoCaptureRender;
	QPointer<DlgRoomMsg> m_dlgRoomMsg;

	QPointer<DlgLocalRecord> m_dlgLocRecord;
	QPointer<DlgServerRecord> m_dlgSvrRecord;
	QPointer<DlgUserSelect> m_dlgUserSelect;
	QPointer<DlgRoomAttrs> m_dlgRoomAttrs;
	QPointer<DlgNetCamera> m_dlgNetCamera;
	QPointer<DlgEchoTest> m_dlgEchoTest;
	QPointer<DlgSubscribeAudio> m_dlgSubscribeAudio;
	QPointer<TestVideoBeauty> m_testVideoBeauty;
	QPointer<TestVirtualBackground> m_testVirtualBackground;
};

extern MainDialog *g_mainDialog;
#endif // MAINDIALOG_H
