#include "stdafx.h"
#include "CustomAudioCapture.h"

#define BYTE_PER_10MS 320
#define PUSH_TIME	  20 //发送数据周期：20毫秒

CustomAudioCapture::CustomAudioCapture(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);

	m_bEnableCapture = false;
	connect(ui.btnCustomCap, &QPushButton::clicked, this, &CustomAudioCapture::slot_btnCustomCapClicked);
	connect(&m_timer, &QTimer::timeout, this, &CustomAudioCapture::slot_timeout);
	m_timer.setInterval(PUSH_TIME);

	//从测试音频文件audio_16k_1ch.pcm读取所有数据
    ReadDataFromFile(":/Resources/custom_audio_16k16bit1ch.pcm", m_audioData);
	//初齐为10ms的整数倍
	int dstLen = (m_audioData.length() / 320) * 320;
	m_audioData = m_audioData.left(dstLen);
}

CustomAudioCapture::~CustomAudioCapture()
{
	if (m_bEnableCapture)
	{
		g_sdkMain->getSDKMeeting().setCustomAudioCapture(false, "");
	}
	m_bEnableCapture = false;
}

void CustomAudioCapture::slot_btnCustomCapClicked()
{
	bool bCapture = !m_bEnableCapture;
	CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().setCustomAudioCapture(bCapture, "");
	if (err != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, "提示", tr("%1失败（%2） ").arg(ui.btnCustomCap->text()).arg(getErrDesc(err)));
		return;
	}
	ui.btnCustomCap->setText(bCapture ? tr("停止音频自定义采集") : tr("开始音频自定义采集"));
	if (bCapture)
	{
		m_startTime = QDateTime::currentMSecsSinceEpoch();
		m_inputCount = 0;

		m_timer.start();
		slot_timeout();
	}
	else
	{
		m_timer.stop();
	}
	m_bEnableCapture = bCapture;
}

void CustomAudioCapture::slot_timeout()
{
	if (m_audioData.length() <= 0)
		return;

	int passedMS = QDateTime::currentMSecsSinceEpoch() - m_startTime;
	int nPassed10MS = (passedMS + 9) / 10;
	int nToInputed = nPassed10MS - m_inputCount;

	for (int i = 0; i < nToInputed; i++)
	{
		int readPos = m_inputCount * BYTE_PER_10MS;
		readPos = readPos%m_audioData.length();

		CRAudioFrame2 frm;
		frm._format = CRVSDK_AFMT_PCM16BIT;
		frm._data.append(m_audioData.constData() + readPos, BYTE_PER_10MS);
		CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().pushCustomAudioDat(frm);
		if (err != CRVSDKERR_NOERR)
		{
			return;
		}

		m_inputCount++;
	}

}
