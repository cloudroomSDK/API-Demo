#ifndef CUSTOMAUDIOCAPTURE_H
#define CUSTOMAUDIOCAPTURE_H

#include "ui_CustomAudioCapture.h"

class CustomAudioCapture : public QDialog
{
	Q_OBJECT

public:
	CustomAudioCapture(QWidget *parent = 0);
	~CustomAudioCapture();

protected slots:
	void slot_btnCustomCapClicked();
	void slot_btnCustomRenderClicked();
	void slot_capTimeout();
	void slot_renderTimeout();

protected:
	void saveOutputAudioData();

private:
	Ui::CustomAudioCapture ui;
	bool	m_bEnableCapture{ false };
	bool	m_bEnableRender{ false };

	QTimer		m_capTimer;
	qint64		m_capStartTime{ 0 };
	int			m_capInputCount{ 0 };
	QByteArray	m_inputAudioData;

	QTimer		m_renderTimer;
	QByteArray	m_outputAudioData;

};

#endif // CUSTOMAUDIOCAPTURE_H
