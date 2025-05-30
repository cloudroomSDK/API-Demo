﻿#ifndef DLGSERVERRECORD_H
#define DLGSERVERRECORD_H

#include "ui_DlgServerRecord.h"

class DlgServerRecord : public QDialog, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	DlgServerRecord(QWidget *parent = 0);
	~DlgServerRecord();

protected:
	QString getMyCloudMixerID();
	CRVSDK_MIXER_STATE getSvrRecordState();

protected:
	//创建云端录制/推流失败
	virtual void createCloudMixerFailed(const char* mixerID, CRVSDK_ERR_DEF sdkErr);
	//通知云端录制/推流状态变化
	virtual void notifyCloudMixerStateChanged(const char* mixerID, CRVSDK_MIXER_STATE state, const char* exParam, const char* operUserID);
	//通知云端录制/推流输出信息
	virtual void notifyCloudMixerOutputInfoChanged(const char* mixerID, const char* jsonStr);

public slots:
	void slot_uiParamsChanged();
	void slot_mainViewChanged();
	void slot_btnStartRecordClicked();
	void slot_btnStopRecordClicked();

private:
	Ui::DlgServerRecord ui;
	QString m_mixerID;
	QSize m_recordSize;
	QTimer m_delayUpdateContent;
	QStringList m_outputs;
};

#endif // DLGSERVERRECORD_H
