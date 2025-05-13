#include "stdafx.h"
#include "DlgServerRecord.h"
#include "maindialog.h"
#include "DlgLoginSet.h"

DlgServerRecord::DlgServerRecord(QWidget *parent)
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
	connect(&m_delayUpdateContent, &QTimer::timeout, this, &DlgServerRecord::slot_mainViewChanged);

	connect(ui.btnStartRecord, &QPushButton::clicked, this, &DlgServerRecord::slot_btnStartRecordClicked);
	connect(ui.btnStopRecord, &QPushButton::clicked, this, &DlgServerRecord::slot_btnStopRecordClicked);
	connect(ui.ckOutputUrl, &QCheckBox::stateChanged, this, &DlgServerRecord::slot_uiParamsChanged);

	m_mixerID = getMyCloudMixerID();
	g_sdkMain->getSDKMeeting().AddCallBack(this);
	slot_uiParamsChanged();
}

DlgServerRecord::~DlgServerRecord()
{
	g_sdkMain->getSDKMeeting().destroyCloudMixer(m_mixerID.toUtf8().constData());
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

QString DlgServerRecord::getMyCloudMixerID()
{
	CRBase::CRString strJosnInfos = g_sdkMain->getSDKMeeting().getAllCloudMixerInfo();
	QVariantList infoList = QJsonDocument::fromJson(strJosnInfos.constData()).toVariant().toList();
	for (auto &infoVar : infoList)
	{
		QVariantMap infoMap = infoVar.toMap();
		if (infoMap["owner"].toString() == crStrToQStr(MainDialog::getMyUserID()))
		{
			return infoMap["ID"].toString();
		}
	}
	return "";
}

CRVSDK_MIXER_STATE DlgServerRecord::getSvrRecordState()
{
	CRVSDK_MIXER_STATE state = CRVSDK_MIXER_NULL;
	if (!m_mixerID.isEmpty())
	{
		CRBase::CRString strJosnMixerInfo = g_sdkMain->getSDKMeeting().getCloudMixerInfo(m_mixerID.toUtf8().constData());
		QVariantMap mixerInfoMap = QJsonDocument::fromJson(strJosnMixerInfo.constData()).toVariant().toMap();
		state = (CRVSDK_MIXER_STATE)mixerInfoMap["state"].toInt();
		
		QVariantMap mixerCfgMap = QJsonDocument::fromJson(mixerInfoMap["cfg"].toByteArray()).toVariant().toMap();
		QVariantMap videoCfgMap = mixerCfgMap.value("videoFileCfg").toMap();
		m_recordSize = QSize(videoCfgMap["vWidth"].toInt(), videoCfgMap["vHeight"].toInt());
	}
	return state;
}

void DlgServerRecord::slot_uiParamsChanged()
{
	CRVSDK_MIXER_STATE state = getSvrRecordState();

	ui.cbDefinition->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.cbFormat->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.ckOutputFile->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.ckOutputUrl->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.editUrl->setEnabled(state == CRVSDK_MIXER_NULL && ui.ckOutputUrl->isChecked());

	ui.btnStartRecord->setVisible(state == CRVSDK_MIXER_NULL || state == CRVSDK_MIXER_STARTING);
	ui.btnStopRecord->setVisible(state == CRVSDK_MIXER_RUNNING || state == CRVSDK_MIXER_STOPPING);
	ui.btnStartRecord->setEnabled(state == CRVSDK_MIXER_NULL);
	ui.btnStopRecord->setEnabled(state == CRVSDK_MIXER_RUNNING);
}

void DlgServerRecord::slot_btnStartRecordClicked()
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

	QSize recordSize;
	if (ui.cbDefinition->currentIndex() == 0)
	{
		recordSize = QSize(640, 360);
	}
	else if (ui.cbDefinition->currentIndex() == 1)
	{
		recordSize = QSize(856, 480);
	}
	else
	{
		recordSize = QSize(1280, 720);
	}

	QString svrPathName;
	if (bHaveRecrodFile)
	{
		QDateTime curTime = QDateTime::currentDateTime();
		QString recordFileBaseName = QString("%1_%2_%3").arg(curTime.toString("yyyy-MM-dd_hh-mm-ss")).arg(GetPlatFormName()).arg(MainDialog::getMeetID());
		QString recordFile = QString("/%1/%2.%3").arg(curTime.toString("yyyy-MM-dd")).arg(recordFileBaseName).arg(ui.cbFormat->currentText());
		svrPathName += recordFile + ";";
		m_outputs.push_back(recordFile);
	}
	if (!pushUrl.isEmpty())
	{
		svrPathName += pushUrl + ";";
		m_outputs.push_back(pushUrl);
	}

	QVariantMap mixerCfgMap;
	mixerCfgMap["mode"] = 0;//合流模式
	QVariantMap videoFileCfgMap;
	videoFileCfgMap["svrPathName"] = svrPathName;
	videoFileCfgMap["vWidth"] = recordSize.width();//视频宽
	videoFileCfgMap["vHeight"] = recordSize.height();//视频高
	videoFileCfgMap["mixedLayout"] = 1;//自定义布局
	videoFileCfgMap["layoutConfig"] = g_mainDialog->getRecordContents(recordSize);//布局内容
	mixerCfgMap["videoFileCfg"] = videoFileCfgMap;

	QByteArray mixerCfg = CoverJsonToString(mixerCfgMap);
	CRBase::CRString rsltMixerID = g_sdkMain->getSDKMeeting().createCloudMixer(mixerCfg.constData());
	
	m_recordSize = recordSize;
    m_mixerID = rsltMixerID.constData();
	this->setWindowTitle(tr("mixerID：%1").arg(m_mixerID));
}

void DlgServerRecord::slot_btnStopRecordClicked()
{
	g_sdkMain->getSDKMeeting().destroyCloudMixer(m_mixerID.toUtf8().constData());
	this->setWindowTitle(tr("云端录制/推流"));
}

void DlgServerRecord::slot_mainViewChanged()
{
	CRVSDK_MIXER_STATE state = getSvrRecordState();
	if (state < CRVSDK_MIXER_STARTING || state > CRVSDK_MIXER_PAUSED)
		return;

	QVariantMap varContentMap;
	varContentMap["layoutConfig"] = g_mainDialog->getRecordContents(m_recordSize);
	QVariantMap varVideoMap;
	varVideoMap["videoFileCfg"] = varContentMap;
	QByteArray cfg = CoverJsonToString(varVideoMap);
	CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().updateCloudMixerContent(m_mixerID.toUtf8().constData(), cfg.constData());
	if (err != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, tr("错误"), tr("更新云端录制内容失败: %1（%2）").arg(err).arg(getErrDesc(err)));
		return;
	}
}

//创建云端录制/推流失败
void DlgServerRecord::createCloudMixerFailed(const char* mixerID, CRVSDK_ERR_DEF sdkErr)
{
	if (m_mixerID != mixerID)
	{
		return;
	}
	slot_uiParamsChanged();
	if (sdkErr != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, tr("错误"), tr("开始录制/推流失败: %1（%2）").arg(sdkErr).arg(getErrDesc(sdkErr)));
		return;
	}
}

//通知云端录制/推流状态变化
void DlgServerRecord::notifyCloudMixerStateChanged(const char* mixerID, CRVSDK_MIXER_STATE state, const char* exParam, const char* operUserID)
{
	if (m_mixerID != mixerID)
	{
		return;
	}
	slot_uiParamsChanged();
	if (state == CRVSDK_MIXER_NULL)
	{
		QVariantMap exParams = QJsonDocument::fromJson(exParam).toVariant().toMap();
		//录制异常
		if (exParams["err"].toInt() != 0)
		{
			QMessageBox::information(this, tr("错误"), tr("录制/推流失败: %1(%2）").arg(exParams["err"].toInt()).arg(exParams["errDesc"].toString()));
			return;
		}
	}
}

//通知云端录制/推流输出信息
void DlgServerRecord::notifyCloudMixerOutputInfoChanged(const char* mixerID, const char* jsonStr)
{
	if (m_mixerID != mixerID)
	{
		return;
	}
	//文件输出信息
	QVariantMap outputInfoMap = QJsonDocument::fromJson(jsonStr).toVariant().toMap();
	CRVSDK_CLOUDMIXER_OUTPUT_STATE fileState = (CRVSDK_CLOUDMIXER_OUTPUT_STATE)outputInfoMap["state"].toInt();
	switch (fileState)
	{
	case CRVSDK::CRVSDK_LOCMO_STARTED:
		break;
	case CRVSDK::CRVSDK_CLOUDMO_RUNNING:
		break;
	case CRVSDK::CRVSDK_CLOUDMO_STOPPED:
		break;
	case CRVSDK::CRVSDK_CLOUDMO_FAIL:
		{
			QMessageBox::information(this, tr("错误"), tr("录制/推流失败：%1（%2）").arg(outputInfoMap["errCode"].toInt()).arg(outputInfoMap["errDesc"].toString()));
		}
		break;
	case CRVSDK::CRVSDK_CLOUDMO_UPLOADING:
		break;
	case CRVSDK::CRVSDK_CLOUDMO_UPLOADED:
		break;
	case CRVSDK::CRVSDK_CLOUDMO_UPLOADFAIL:
		QMessageBox::information(this, tr("错误"), tr("上传文件失败：%1（%2）").arg(outputInfoMap["errCode"].toInt()).arg(outputInfoMap["errDesc"].toString()));
		break;
	default:
		break;
	}
}
