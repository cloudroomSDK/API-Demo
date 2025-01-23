#ifndef DLGVIDEOSET_H
#define DLGVIDEOSET_H

#include "ui_DlgVideoSet.h"

class DlgVideoSet : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgVideoSet(QWidget *parent = 0);
	~DlgVideoSet();

protected:
	virtual void notifyVideoDevChanged(const char* userID);
	virtual void notifyDefaultVideoChanged(const char* userID, int videoID);

public slots:
	void slot_camSelChanged(int idx);
	void slot_camSel2Changed(int idx);
	void slot_resolutionChanged(int idx);
	void slot_fpsChanged(int idx);
	void slot_bpsChanged(int val);
	void slot_videoTransModeChanged(int id);
	void slot_HwChanged();
	void slot_denoiseStateChanged(int st);

protected:
	void initVideoParams();
	void initCamera();
	void initCamera(QComboBox *box, int defCam);

private:
	Ui::DlgVideoSet ui;
	VideoCfg		m_vCfg;
	int				m_defKBps;
	VideoEffectsObj	m_vEffects;

	enum VIDEO_TRANS_MODE {VTM_QUALITY, VTM_SMOOTH, VTM_BUTT};
};

#endif // DLGVIDEOSET_H
