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
	int gop;//I帧周期
};
static RecordParams g_recordParams[3] =
{
	// 大小					帧率     码率            质量     I帧周期
	{ QSize(640, 360),		15,		350 * 1000,		18,		15*15 },	//标清
	{ QSize(848, 480),		15,		500 * 1000,		18,		15*15 },	//高清
	{ QSize(1280, 720),		15,		1000 * 1000,	18,		15*15 },	//超清
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

	g_sdkMain->getSDKMeeting().AddCallBack(this);
    QString defPath = QCoreApplication::applicationDirPath() + "/record";
    m_recordPath = GetInifileString("UserCfg", "recordPath", g_cfgFile, defPath);
	ui.editPath->setText(m_recordPath);
	updateUI();
}

DlgLocalRecord::~DlgLocalRecord()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgLocalRecord::updateUI()
{
	CRVSDK_MIXER_STATE state = g_sdkMain->getSDKMeeting().getLocMixerState(LOCREC_MIXER_ID);
	ui.btnStartRecord->setVisible(state != CRVSDK_MIXER_RUNNING);
	ui.btnStopRecord->setVisible(state == CRVSDK_MIXER_RUNNING);

	ui.btnStartRecord->setDisabled(state == CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STOPPING);
	ui.btnStopRecord->setDisabled(state == CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STOPPING);
}

void DlgLocalRecord::slot_btnChoosePathClicked()
{
	QString path = QFileDialog::getExistingDirectory(this, "", m_recordPath);
	if (path.isEmpty())
	{
		return;
	}
	ui.editPath->setText(path);
	SetInifileString("UserCfg", "recordPath", path, g_cfgFile);
}

void DlgLocalRecord::slot_btnStartRecordClicked()
{
	//录制配置
	const RecordParams &recParams = g_recordParams[ui.cbDefinition->currentIndex()];
	QVariantMap mixerCfgMap;
	mixerCfgMap["width"] = recParams.sz.width();
	mixerCfgMap["height"] = recParams.sz.height();
	mixerCfgMap["frameRate"] = recParams.frameRate;
	mixerCfgMap["bitRate"] = recParams.bitRate;
	mixerCfgMap["defaultQP"] = recParams.defaultQP;
	mixerCfgMap["gop"] = recParams.gop;
	QByteArray mixerCfg = CoverJsonToString(mixerCfgMap);

	//录制内容
	QByteArray mixerContents = CoverJsonToString(g_mainDialog->getRecordContents(recParams.sz));

	//创建混图器
	CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().createLocMixer(LOCREC_MIXER_ID, mixerCfg.constData(), mixerContents.constData());
	if (err != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, tr("本地录制"), tr("录制失败（%1） ").arg(getErrDesc(err)));
		return;
	}

	//录制输出
	QString recordFileBaseName = QString("%1_%2_%3").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")).arg(GetPlatFormName()).arg(MainDialog::getMeetID());
	m_curRecordFile = QString("%1/%2.%3").arg(ui.editPath->text()).arg(recordFileBaseName).arg(ui.cbFormat->currentText());
	QVariantList mixerOutputList;
	QVariantMap mixerOutputObj;
	mixerOutputObj["type"] = CRVSDK_MIXER_OUTPUT_FILE;//录制文件
	mixerOutputObj["filename"] = m_curRecordFile;//文件名称
	mixerOutputList.append(mixerOutputObj);
	QByteArray mixerOutput = CoverJsonToString(mixerOutputList);
	err = g_sdkMain->getSDKMeeting().addLocMixerOutput(LOCREC_MIXER_ID, mixerOutput.constData());
	if (err != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, tr("本地录制"), tr("录制失败（%1） ").arg(err));
		g_sdkMain->getSDKMeeting().destroyLocMixer(LOCREC_MIXER_ID);
		return;
	}
	m_recordSize = recParams.sz;
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
		QMessageBox::information(this, tr("本地录制"), tr("更新本地录制内容失败（%1） ").arg(getErrDesc(err)));
		return;
	}
}

void DlgLocalRecord::notifyLocMixerStateChanged(const char* mixerID, CRVSDK_MIXER_STATE state) 
{
	if (QString(mixerID) != LOCREC_MIXER_ID)
	{
		return;
	}
	updateUI();
}

void DlgLocalRecord::notifyLocMixerOutputInfo(const char* mixerID, const char* nameOrUrl, const char* outputInfo)
{
	if (QString(mixerID) != LOCREC_MIXER_ID)
	{
		return;
	}

	QVariantMap mixerOutputMap = QJsonDocument::fromJson(outputInfo).toVariant().toMap();
	int state = mixerOutputMap["state"].toInt();
	if (state == 2)
	{
		QFileInfo fi(nameOrUrl);
		QString strInfo = tr("文件名：%1\n时长：\t%2秒\n大小：\t%3字节").arg(fi.fileName()).arg(mixerOutputMap["duration"].toInt() / 1000).arg(mixerOutputMap["fileSize"].toInt());
		ui.lbOutputInfo->setText(strInfo);
	}
	else if (state == 3)
	{
		QFileInfo fi(nameOrUrl);
		QString strInfo = tr("文件名：%1\n发生异常（%2） ").arg(fi.fileName()).arg(mixerOutputMap["errCode"].toInt());
		ui.lbOutputInfo->setText(strInfo);
	}
}
