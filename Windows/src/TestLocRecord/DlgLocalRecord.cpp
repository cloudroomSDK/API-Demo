#include "stdafx.h"
#include "DlgLocalRecord.h"
#include "maindialog.h"

#define LOCREC_MIXER_ID "loc_record"
struct RecordParams
{
	QSize sz;//大小
	int frameRate;//帧率
	int bitRate;//码率
	int defaultQP;//质量
};
static RecordParams g_recordParams[3] =
{
	// 大小					帧率     码率           质量
	{ QSize(640, 360),		15,		350 * 1000,		18},	//标清
	{ QSize(856, 480),		15,		500 * 1000,		18},	//高清
	{ QSize(1280, 720),		15,		1000 * 1000,	18},	//超清
};

DlgLocalRecord::DlgLocalRecord(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);

	for(QComboBox *pCbBx : this->findChildren<QComboBox*>())
	{
		QListView *pLV = new QListView;
		pCbBx->setView(pLV);
	}

	//s_viewChanged可能密集产生， 在此进行少量累积处理， 避免重复处理；
	m_delayUpdateContent.setSingleShot(true);
	m_delayUpdateContent.setInterval(32);
	connect(g_mainDialog, SIGNAL(s_viewChanged()), &m_delayUpdateContent, SLOT(start()));
	connect(&m_delayUpdateContent, &QTimer::timeout, this, &DlgLocalRecord::slot_mainViewChanged);

	connect(ui.btnChoosePath, &QPushButton::clicked, this, &DlgLocalRecord::slot_btnChoosePathClicked);
	connect(ui.btnStartRecord, &QPushButton::clicked, this, &DlgLocalRecord::slot_btnStartRecordClicked);
	connect(ui.btnStopRecord, &QPushButton::clicked, this, &DlgLocalRecord::slot_btnStopRecordClicked);
	connect(ui.btnRecordPlay, &QPushButton::clicked, this, &DlgLocalRecord::slot_btnRecordPlayClicked);
	connect(ui.btnMark, &QPushButton::clicked, this, &DlgLocalRecord::slot_btnMarkClicked);
	connect(ui.ckOutputFile, &QCheckBox::stateChanged, this, &DlgLocalRecord::slot_uiParamsChanged);
	connect(ui.ckOutputUrl, &QCheckBox::stateChanged, this, &DlgLocalRecord::slot_uiParamsChanged);

	g_sdkMain->getSDKMeeting().AddCallBack(this);
	QString recordPath = QCoreApplication::applicationDirPath() + "/record";
	recordPath = GetInifileString("UserCfg", "recordPath", g_cfgFile, recordPath);
	ui.editPath->setText(recordPath);
	slot_uiParamsChanged();
}

DlgLocalRecord::~DlgLocalRecord()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgLocalRecord::slot_uiParamsChanged()
{
	CRVSDK_MIXER_STATE state = g_sdkMain->getSDKMeeting().getLocMixerState(LOCREC_MIXER_ID);

	ui.cbDefinition->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.cbFormat->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.ckOutputFile->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.ckOutputUrl->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.btnChoosePath->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.editUrl->setEnabled(state == CRVSDK_MIXER_NULL && ui.ckOutputUrl->isChecked());
	ui.outputFileWidget->setEnabled(ui.ckOutputFile->isChecked());

	ui.btnStartRecord->setVisible(state == CRVSDK_MIXER_NULL || state == CRVSDK_MIXER_STARTING);
	ui.btnStopRecord->setVisible(state == CRVSDK_MIXER_RUNNING || state == CRVSDK_MIXER_STOPPING);
	ui.btnStartRecord->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.btnStopRecord->setEnabled(state == CRVSDK_MIXER_RUNNING);

	ui.btnMark->setVisible(state == CRVSDK_MIXER_RUNNING);
	ui.editMarkDesc->setVisible(state == CRVSDK_MIXER_RUNNING);

	ui.btnRecordPlay->setVisible(state == CRVSDK_MIXER_NULL);
	ui.btnRecordPlay->setEnabled(!m_curRecordFile.isEmpty());
}

void DlgLocalRecord::slot_btnChoosePathClicked()
{
	QString path = QFileDialog::getExistingDirectory(this, tr("选择录像存储目录"), ui.editPath->text());
	if (path.isEmpty())
	{
		return;
	}
	ui.editPath->setText(path);
	SetInifileString("UserCfg", "recordPath", path, g_cfgFile);
}

void DlgLocalRecord::slot_btnStartRecordClicked()
{
	bool bHavePushUrl = ui.ckOutputUrl->isChecked();
	bool bHaveRecrodFile = ui.ckOutputFile->isChecked();
	QString pushUrl;
	if (bHavePushUrl)
	{
		pushUrl = ui.editUrl->text();
		if (!pushUrl.startsWith("rtmp:", Qt::CaseInsensitive) && !pushUrl.startsWith("rtsp:", Qt::CaseInsensitive))
		{
			QMessageBox::information(this, tr("错误"), tr("请输入有效的推流地址！"));
			ui.editUrl->setFocus();
			return;
		}
	}
	if (!bHavePushUrl && !bHaveRecrodFile)
	{
		QMessageBox::information(this, tr("错误"), tr("未配置输出目标！"));
		return;
	}

	//录制配置
	const RecordParams &recParams = g_recordParams[ui.cbDefinition->currentIndex()];
	QVariantMap mixerCfgMap;
	mixerCfgMap["width"] = recParams.sz.width();
	mixerCfgMap["height"] = recParams.sz.height();
	mixerCfgMap["frameRate"] = recParams.frameRate;
	mixerCfgMap["bitRate"] = recParams.bitRate;
	mixerCfgMap["defaultQP"] = recParams.defaultQP;
	mixerCfgMap["gop"] = bHavePushUrl ? 4 * recParams.frameRate : 15 * recParams.frameRate;
	QByteArray mixerCfg = CoverJsonToString(mixerCfgMap);
	m_recordSize = recParams.sz;

	//录制内容
	QByteArray mixerContents = CoverJsonToString(g_mainDialog->getRecordContents(recParams.sz));

	//创建混图器
	CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().createLocMixer(LOCREC_MIXER_ID, mixerCfg.constData(), mixerContents.constData());
	if (err != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, tr("错误"), tr("录制失败: %1（%2） ").arg(err).arg(getErrDesc(err)));
		return;
	}

	m_curRecordFile.clear();
	m_outputs.clear();

	QVariantList mixerOutputList;
	//输出到文件
	if (bHaveRecrodFile)
	{
		QString recordFileBaseName = QString("%1_%2_%3").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")).arg(GetPlatFormName()).arg(MainDialog::getMeetID());
		m_curRecordFile = QString("%1/%2.%3").arg(ui.editPath->text()).arg(recordFileBaseName).arg(ui.cbFormat->currentText());
		QVariantMap mixerOutputObj;
		mixerOutputObj["type"] = CRVSDK_MIXER_OUTPUT_FILE;
		mixerOutputObj["filename"] = m_curRecordFile;
		mixerOutputList.append(mixerOutputObj);
		m_outputs.push_back(m_curRecordFile);
	}
	//推流到url
	if (bHavePushUrl)
	{
		QVariantMap mixerOutputObj;
		mixerOutputObj["type"] = CRVSDK_MIXER_OUTPUT_LIVE;
		mixerOutputObj["liveUrl"] = pushUrl;
		mixerOutputList.append(mixerOutputObj);
		m_outputs.push_back(pushUrl);
	}
	QByteArray mixerOutput = CoverJsonToString(mixerOutputList);
	g_sdkMain->getSDKMeeting().addLocMixerOutput(LOCREC_MIXER_ID, mixerOutput.constData());

}

void DlgLocalRecord::slot_btnStopRecordClicked()
{
	if (g_sdkMain->getSDKMeeting().getLocMixerState(LOCREC_MIXER_ID) == CRVSDK_MIXER_NULL)
	{
		return;
	}
	g_sdkMain->getSDKMeeting().rmLocMixerOutput(LOCREC_MIXER_ID, m_curRecordFile.toUtf8().constData());
	g_sdkMain->getSDKMeeting().destroyLocMixer(LOCREC_MIXER_ID);
}

void DlgLocalRecord::slot_btnRecordPlayClicked()
{
	g_sdkMain->getSDKMeeting().stopPlayMedia();
	g_sdkMain->getSDKMeeting().startPlayMedia(m_curRecordFile.toUtf8().constData());
}

void DlgLocalRecord::slot_btnMarkClicked()
{
	QString str = ui.editMarkDesc->text();
	if (str.isEmpty())
	{
		QMessageBox::information(this, tr("提示"), tr("请输入有效内容!"));
		return;
	}

	g_sdkMain->getSDKMeeting().setMarkText(m_curRecordFile.toUtf8().constData(), str.toUtf8().constData());
}


void DlgLocalRecord::slot_mainViewChanged()
{
	if (g_sdkMain->getSDKMeeting().getLocMixerState(LOCREC_MIXER_ID) == CRVSDK_MIXER_NULL)
	{
		return;
	}

	QByteArray mixerContents = CoverJsonToString(g_mainDialog->getRecordContents(m_recordSize));
	CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().updateLocMixerContent(LOCREC_MIXER_ID, mixerContents.constData());
	if (err != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, tr("提示"), tr("更新本地录制内容失败:%1（%2） ").arg(err).arg(getErrDesc(err)));
		return;
	}
}

void DlgLocalRecord::notifyLocMixerStateChanged(const char* mixerID, CRVSDK_MIXER_STATE state) 
{
	if (QString(mixerID) != LOCREC_MIXER_ID)
	{
		return;
	}
	slot_uiParamsChanged();
}

void DlgLocalRecord::notifyLocMixerOutputInfo(const char* mixerID, const char* nameOrUrl, const char* outputInfo)
{
	if (QString(mixerID) != LOCREC_MIXER_ID)
	{
		return;
	}

	QVariantMap mixerOutputMap = QJsonDocument::fromJson(outputInfo).toVariant().toMap();
	int state = mixerOutputMap["state"].toInt();
	if (state == CRVSDK_LOCMO_FAIL)
	{
		m_outputs.removeAll(QString::fromUtf8(nameOrUrl));
		//全部输出都失败时，停止Mix
		if (m_outputs.size() <= 0)
		{
			g_sdkMain->getSDKMeeting().destroyLocMixer(LOCREC_MIXER_ID);
		}

		CRVSDK_ERR_DEF err = (CRVSDK_ERR_DEF)mixerOutputMap["errCode"].toInt();
		QString strInfo = tr("输出到：%1\n发生异常:%2（%3） ").arg(nameOrUrl).arg(err).arg(getErrDesc(err));
		QMessageBox::information(this, tr("错误"), strInfo);

	}
}
