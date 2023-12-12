#ifndef CUSTOMAUDIOCAPTURE_H
#define CUSTOMAUDIOCAPTURE_H

#include "ui_CustomAudioCapture.h"

class CustomAudioCapture : public QDialog
{
	Q_OBJECT

public:
	CustomAudioCapture(QWidget *parent = 0);
	~CustomAudioCapture();

public slots:
	void slot_btnCustomCapClicked();
	void slot_timeout();

private:
	Ui::CustomAudioCapture ui;
	bool	m_bEnableCapture;
	QTimer	m_timer;

	qint64		m_startTime;
	int			m_inputCount;
	QByteArray	m_audioData;

};

#endif // CUSTOMAUDIOCAPTURE_H
