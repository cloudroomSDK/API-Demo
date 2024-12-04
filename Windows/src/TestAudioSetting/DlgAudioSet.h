#ifndef DLGAUDIOSET_H
#define DLGAUDIOSET_H

#include "ui_DlgAudioSet.h"

class DlgAudioSet : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgAudioSet(QWidget *parent = 0);
	~DlgAudioSet();

protected:
	virtual void notifyAudioDevChanged();

public slots:
	void slot_micSelChanged(int idx);
	void slot_spkSelChanged(int idx);
	void slot_micVolChanged(int vol);
	void slot_spkVolChanged(int vol);
	void slot_updateAudioVolum();
	void slot_3AChanged();

protected:
	void initAudioDevs();

private:
	Ui::DlgAudioSet ui;
};

#endif // DLGAUDIOSET_H
