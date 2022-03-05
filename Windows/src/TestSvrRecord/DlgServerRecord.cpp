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

	m_mixerID = getMyCloudMixerID();
	g_sdkMain->getSDKMeeting().AddCallBack(this);
	updateUI();
}

DlgServerRecord::~DlgServerRecord()
{
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

void DlgServerRecord::updateUI()
{
	CRVSDK_MIXER_STATE state = getSvrRecordState();
 	ui.btnStartRecord->setVisible(state != CRVSDK_MIXER_RUNNING);
 	ui.btnStopRecord->setVisible(state == CRVSDK_MIXER_RUNNING);
 	ui.btnStartRecord->setDisabled(state == CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STOPPING);
 	ui.btnStopRecord->setDisabled(state == CRVSDK_MIXER_STARTING || state == CRVSDK_MIXER_STOPPING);
}

void DlgServerRecord::slot_btnStartRecordClicked()
{
	QSize recordSize;
	if (ui.cbDefinition->currentIndex() == 0)
	{
		recordSize = QSize(640, 360);
	}
	else if (ui.cbDefinition->currentIndex() == 1)
	{
		recordSize = QSize(848, 480);
	}
	else
	{
		recordSize = QSize(1280, 720);
	}

	QVariantMap mixerCfgMap;
	mixerCfgMap["mode"] = 0;//合流模式
	QString recordFileBaseName = QString("%1_%2_%3").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")).arg(GetPlatFormName()).arg(MainDialog::getMeetID());
	QVariantMap videoFileCfgMap;
	videoFileCfgMap["svrPathName"] = QString("/%1/%2.%3").arg(QDate::currentDate().toString("yyyy-MM-dd")).arg(recordFileBaseName).arg(ui.cbFormat->currentText());
	videoFileCfgMap["vWidth"] = recordSize.width();//视频宽
	videoFileCfgMap["vHeight"] = recordSize.height();//视频高
	videoFileCfgMap["mixedLayout"] = 1;//自定义布局
	videoFileCfgMap["layoutConfig"] = g_mainDialog->getRecordContents(recordSize);//布局内容
	mixerCfgMap["videoFileCfg"] = videoFileCfgMap;

	QByteArray mixerCfg = QJsonDocument::fromVariant(mixerCfgMap).toJson();
	CRBase::CRString rsltMixerID;
	CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().createCloudMixer(mixerCfg.constData(), rsltMixerID);
	if (err != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, tr("云端录制"), tr("录制失败（%1） ").arg(getErrDesc(err)));
		return;
	}
	m_recordSize = recordSize;
    m_mixerID = rsltMixerID.constData();
	this->setWindowTitle(tr("云端录制：%1").arg(m_mixerID));
}

void DlgServerRecord::slot_btnStopRecordClicked()
{
	g_sdkMain->getSDKMeeting().destroyCloudMixer(m_mixerID.toUtf8().constData());
	this->setWindowTitle(tr("云端录制"));
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
	QByteArray cfg = QJsonDocument::fromVariant(varVideoMap).toJson();
	CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().updateCloudMixerContent(m_mixerID.toUtf8().constData(), cfg.constData());
	if (err != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, tr("云端录制"), tr("更新云端录制内容失败（%1） ").arg(getErrDesc(err)));
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
	updateUI();
	if (sdkErr != CRVSDKERR_NOERR)
	{
		QMessageBox::information(this, tr("云端录制"), tr("开始录制失败（%1）").arg(getErrDesc(sdkErr)));
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
	updateUI();
	if (state == CRVSDK_MIXER_NULL)
	{
		QVariantMap exParams = QJsonDocument::fromJson(exParam).toVariant().toMap();
		//录制异常
		if (exParams["err"].toInt() != 0)
		{
			QMessageBox::information(this, tr("云端录制"), tr("录制失败（错误码:%1, 描述：%2）").arg(exParams["err"].toInt()).arg(exParams["errDesc"].toString()));
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
	CRVSDK_MIXER_FILE_STATE fileState = (CRVSDK_MIXER_FILE_STATE)outputInfoMap["state"].toInt();
	switch (fileState)
	{
	case CRVSDK::CRVSDK_MFS_NORECORD:
		break;
	case CRVSDK::CRVSDK_MFS_RECORDING:
		break;
	case CRVSDK::CRVSDK_MFS_RECORDED:
		break;
	case CRVSDK::CRVSDK_MFS_RECORDFAIL:
		QMessageBox::information(this, tr("云端录制"), tr("录制文件失败（%1） ").arg(outputInfoMap["errDesc"].toString()));	
		break;
	case CRVSDK::CRVSDK_MFS_UPLOADING:
		break;
	case CRVSDK::CRVSDK_MFS_UPLOADED:
		//上传完成
		showResultDlg();
		break;
	case CRVSDK::CRVSDK_MFS_UPLOADFAIL:
		QMessageBox::information(this, tr("云端录制"), tr("上传文件失败（%1） ").arg(outputInfoMap["errDesc"].toString()));
		break;
	default:
		break;
	}
}

void DlgServerRecord::showResultDlg()
{
	ServerRecordResultDlg *pDlg = new ServerRecordResultDlg(this);
	pDlg->show();
}

//////////////////////////////////////////////////////////////////////////
ServerRecordResultDlg::ServerRecordResultDlg(QWidget *parent) : QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);
	ui.recordPath->setReadOnly(true);
	this->setAttribute(Qt::WA_DeleteOnClose);

	QString protocol = (DlgLoginSet::getSettingInfo().httpType == CRVSDK_WEBPTC_HTTP) ? "http://" : "https://";
	QString url = protocol + DlgLoginSet::getSettingInfo().server + QString("/mgr_sdk/");
	ui.recordPath->setText(url);

	connect(ui.btnCopy, &QPushButton::clicked, this, &ServerRecordResultDlg::slot_copyUrl);
}

void ServerRecordResultDlg::slot_copyUrl()
{
	QClipboard *clip = QApplication::clipboard();
	clip->setText(ui.recordPath->text());

	QToolTip::showText(ui.btnCopy->mapToGlobal(QPoint()), tr("已复制到剪切板！"), ui.btnCopy);
}
