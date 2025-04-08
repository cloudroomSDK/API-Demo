#include "stdafx.h"
#include "CustomAudioCapture.h"

#define BYTE_PER_10MS 320
#define PUSH_TIME	  20 //发送数据周期：20毫秒

//最大只保留2MB数据
#define MAXOUTPUTSIZE (1024*1024*2)

CustomAudioCapture::CustomAudioCapture(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);

	connect(ui.btnCustomCap, &QPushButton::clicked, this, &CustomAudioCapture::slot_btnCustomCapClicked);
	connect(ui.btnCustomRender, &QPushButton::clicked, this, &CustomAudioCapture::slot_btnCustomRenderClicked);
	connect(&m_capTimer, &QTimer::timeout, this, &CustomAudioCapture::slot_capTimeout);
	connect(&m_renderTimer, &QTimer::timeout, this, &CustomAudioCapture::slot_renderTimeout);
	m_capTimer.setInterval(PUSH_TIME);
	m_renderTimer.setInterval(PUSH_TIME);

	//从测试音频文件audio_16k_1ch.pcm读取所有数据
    ReadDataFromFile(":/Resources/custom_audio_16k16bit1ch.pcm", m_inputAudioData);
	//对齐为10ms的整数倍
	int dstLen = (m_inputAudioData.length() / 320) * 320;
	m_inputAudioData = m_inputAudioData.left(dstLen);
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
		m_capStartTime = QDateTime::currentMSecsSinceEpoch();
		m_capInputCount = 0;

		m_capTimer.start();
		slot_capTimeout();
	}
	else
	{
		m_capTimer.stop();
	}
	m_bEnableCapture = bCapture;
}


void CustomAudioCapture::slot_capTimeout()
{
	if (m_inputAudioData.length() <= 0)
		return;

	int passedMS = QDateTime::currentMSecsSinceEpoch() - m_capStartTime;
	int nPassed10MS = (passedMS + 9) / 10;
	int nToInputed = nPassed10MS - m_capInputCount;

	for (int i = 0; i < nToInputed; i++)
	{
		int readPos = m_capInputCount * BYTE_PER_10MS;
		readPos = readPos%m_inputAudioData.length();

		CRAudioFrame2 frm;
		frm._format = CRVSDK_AFMT_PCM16BIT;
		frm._data.append(m_inputAudioData.constData() + readPos, BYTE_PER_10MS);
		CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().pushCustomAudioDat(frm);
		if (err != CRVSDKERR_NOERR)
		{
			return;
		}

		m_capInputCount++;
	}
}


void CustomAudioCapture::slot_btnCustomRenderClicked()
{
	bool bRender = !m_bEnableRender;
	CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().setCustomAudioPlayback(bRender, "");
	if (err != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, "提示", tr("%1失败（%2） ").arg(ui.btnCustomRender->text()).arg(getErrDesc(err)));
		return;
	}

	ui.btnCustomRender->setText(bRender ? tr("停止音频自定义渲染") : tr("开始音频自定义渲染"));
	if (bRender)
	{
		m_renderTimer.start();
		m_outputAudioData.clear();
		m_outputAudioData.reserve(MAXOUTPUTSIZE);
	}
	else
	{
		m_renderTimer.stop();
		slot_renderTimeout();
		
		saveOutputAudioData();
		m_outputAudioData.clear();
	}
	m_bEnableRender = bRender;
}


void CustomAudioCapture::slot_renderTimeout()
{
	while (1)
	{
		CRAudioFrame2 frm;
		CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().pullCustomAudioDat(frm);
		if (err != CRVSDKERR_NOERR)
		{
			return;
		}
		if (frm._data.length() <= 0)
		{
			return;
		}

		if ((m_outputAudioData.length() + frm._data.length()) > MAXOUTPUTSIZE)
		{
			//移除头部1秒的数据
			m_outputAudioData.remove(0, BYTE_PER_10MS * 100);
		}
		m_outputAudioData.append(frm._data.constData(), frm._data.length());
	}
}

void CustomAudioCapture::saveOutputAudioData()
{
	QFileInfo qfinfo(g_cfgFile);
	QString strAppPath = qfinfo.absolutePath();
	QString outputFileName = strAppPath + "/customRenderAudio_16k16bit1ch.pcm";

	if (!WriteDataToFile(m_outputAudioData, outputFileName))
	{
		QMessageBox::information(this, "错误", tr("保存数据到失败，位置：%1 ").arg(outputFileName));
		return;
	}
	QMessageBox::information(this, "提示", tr("自渲染数据保存在文件：%1").arg(outputFileName));
}