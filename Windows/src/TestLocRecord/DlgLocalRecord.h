#ifndef DLGLOCALRECORD_H
#define DLGLOCALRECORD_H

#include "ui_DlgLocalRecord.h"

class DlgLocalRecord : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgLocalRecord(QWidget *parent = 0);
	~DlgLocalRecord();

protected:
	//通知本地录制/推流状态变化
	virtual void notifyLocMixerStateChanged(const char* mixerID, CRVSDK_MIXER_STATE state);
	//通知本地录制/推流输出信息
	virtual void notifyLocMixerOutputInfo(const char* mixerID, const char* nameOrUrl, const char* outputInfo);

public slots:
	void slot_mainViewChanged();
	void slot_btnChoosePathClicked();
	void slot_btnStartRecordClicked();
	void slot_btnStopRecordClicked();
	void slot_btnRecordPlayClicked();
	void slot_btnMarkClicked();
	void slot_uiParamsChanged();

private:
	Ui::DlgLocalRecord ui;
	QSize	m_recordSize;
	QString m_curRecordFile;
	QTimer	m_delayUpdateContent;
	QStringList m_outputs;
};

#endif // DLGLOCALRECORD_H
