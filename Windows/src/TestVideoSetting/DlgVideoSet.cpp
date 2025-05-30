﻿#include "stdafx.h"
#include "DlgVideoSet.h"
#include "maindialog.h"

DlgVideoSet::DlgVideoSet(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);

	for(QComboBox *pCbBx : this->findChildren<QComboBox*>())
	{
		QListView *pLV = new QListView;
		pCbBx->setView(pLV);
	}

	ui.cbBx_resolution->insertItem(0, QString("360P"), QSize(640, 360));
	ui.cbBx_resolution->insertItem(1, QString("480P"), QSize(856, 480));
	ui.cbBx_resolution->insertItem(2, QString("720P"), QSize(1280, 720));
	ui.cbBx_resolution->insertItem(3, QString("1080P"), QSize(1920, 1080));
	ui.cbBx_resolution->insertItem(4, QString("4K"), QSize(3840, 2160));

	ui.cbBx_fps->insertItem(0, QString("8"), 8);
	ui.cbBx_fps->insertItem(1, QString("15"), 15);
	ui.cbBx_fps->insertItem(2, QString("25"), 25);
	ui.cbBx_fps->insertItem(3, QString("30"), 30);
	ui.cbBx_fps->insertItem(4, QString("60"), 60);

	m_defKBps = 350;
	ui.sld_bps->setRange(5, 20);

	connect(ui.cbBx_camSel, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_camSelChanged(int)));
	connect(ui.cbBx_camSel_2, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_camSel2Changed(int)));
	
	connect(ui.cbBx_resolution, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_resolutionChanged(int)));
	connect(ui.cbBx_fps, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_fpsChanged(int)));
	connect(ui.sld_bps, &QSlider::valueChanged, this, &DlgVideoSet::slot_bpsChanged);
	connect(ui.ck_denoise, SIGNAL(stateChanged(int)), this, SLOT(slot_denoiseStateChanged(int)));

	QButtonGroup *modeGrp = new QButtonGroup(this);
	modeGrp->setExclusive(true);
	modeGrp->addButton(ui.rb_qualityMode, VTM_QUALITY);
	modeGrp->addButton(ui.rb_smoothMode, VTM_SMOOTH);
	connect(modeGrp, SIGNAL(buttonClicked(int)), this, SLOT(slot_videoTransModeChanged(int)));

	initVideoParams();
	g_sdkMain->getSDKMeeting().AddCallBack(this);
}

DlgVideoSet::~DlgVideoSet()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgVideoSet::notifyVideoDevChanged(const char* userID)
{
	if (MainDialog::getMyUserID() != userID)
		return;

	initCamera();
}

void DlgVideoSet::notifyDefaultVideoChanged(const char* userID, int videoID)
{
	if (MainDialog::getMyUserID() != userID)
		return;

	initCamera();
}

void DlgVideoSet::slot_camSelChanged(int idx)
{
	int camId = ui.cbBx_camSel->itemData(idx).toInt();

	g_sdkMain->getSDKMeeting().setDefaultVideo(camId);
}

void DlgVideoSet::slot_camSel2Changed(int idx)
{
	int camId = ui.cbBx_camSel_2->itemData(idx).toInt();
	if (camId != 0)
	{
		//开启多摄像头
		int moreVideos[1];
		moreVideos[0] = camId;
		g_sdkMain->getSDKMeeting().setMutiVideos(moreVideos, 1);
	}
	else
	{
		//关闭多摄像头
		g_sdkMain->getSDKMeeting().setMutiVideos(NULL, 0);
	}
}

void DlgVideoSet::slot_resolutionChanged(int idx)
{
	m_vCfg._size = ui.cbBx_resolution->itemData(idx).toSize();

	//同步修改bps
	ui.sld_bps->blockSignals(true);
	int defKBps = 350;
	if (m_vCfg._size.height() >= 2160)
	{
		defKBps = 6000;
	}
	else if (m_vCfg._size.height() >= 1080)
	{
		defKBps = 2000;
	}
	else if (m_vCfg._size.height() >= 720)
	{
		defKBps = 1000;
	}
	else if(m_vCfg._size.height() >= 480)
	{
		defKBps = 500;
	}
	m_defKBps = defKBps;
	m_vCfg._maxbps = -1;
	ui.sld_bps->setValue(10);
	ui.lbl_bps->setText(QString("%1kbps").arg(defKBps));
	ui.sld_bps->blockSignals(false);

	QByteArray jsonCfg = StructToJson(m_vCfg);
	g_sdkMain->getSDKMeeting().setVideoCfg(jsonCfg.constData());
}

void DlgVideoSet::slot_fpsChanged(int idx)
{
	int newFps = ui.cbBx_fps->itemData(idx).toInt();
	m_vCfg._fps = newFps;

	QByteArray jsonCfg = StructToJson(m_vCfg);
	g_sdkMain->getSDKMeeting().setVideoCfg(jsonCfg.constData());
}

void DlgVideoSet::slot_bpsChanged(int val)
{
	int setbps = m_defKBps * 100 * val;
	m_vCfg._maxbps = setbps;
	ui.lbl_bps->setText(QString("%1kbps").arg(setbps / 1000));

	QByteArray jsonCfg = StructToJson(m_vCfg);
	g_sdkMain->getSDKMeeting().setVideoCfg(jsonCfg.constData());
}

void DlgVideoSet::slot_videoTransModeChanged(int id)
{
	if(VTM_QUALITY == id)
	{
		m_vCfg._min_qp = 22;
		m_vCfg._max_qp = 22;
	}
	else if(VTM_SMOOTH == id)
	{
		m_vCfg._min_qp = 22;
		m_vCfg._max_qp = 40;
	}

	QByteArray jsonCfg = StructToJson(m_vCfg);
	g_sdkMain->getSDKMeeting().setVideoCfg(jsonCfg.constData());
}

void DlgVideoSet::slot_denoiseStateChanged(int st)
{
	m_vEffects._denoise = (st == Qt::Checked);
	QByteArray jsonCfg = StructToJson(m_vEffects);
	g_sdkMain->getSDKMeeting().setVideoEffects(jsonCfg.constData());
}


void DlgVideoSet::initVideoParams()
{
	initCamera();

	ui.cbBx_resolution->blockSignals(true);
	ui.cbBx_fps->blockSignals(true);
	ui.sld_bps->blockSignals(true);
	ui.rb_qualityMode->blockSignals(true);
	ui.rb_smoothMode->blockSignals(true);
	ui.ck_denoise->blockSignals(true);

	CRString jsonStr = g_sdkMain->getSDKMeeting().getVideoCfg();
	m_vCfg = JsonToStruct<VideoCfg>(crStrToByteArray(jsonStr));

	int findFps = 8;
	if (m_vCfg._fps >= 60)
	{
		findFps = 60;
	}
	else if(m_vCfg._fps >= 30)
	{
		findFps = 30;
	}
	else if (m_vCfg._fps >= 25)
	{
		findFps = 25;
	}
	else if(m_vCfg._fps >= 15)
	{
		findFps = 15;
	}
	ui.cbBx_fps->setCurrentIndex(ui.cbBx_fps->findData(findFps));

	QSize findSz(640, 360);
	int defKBps = 350;
	if (m_vCfg._size.height() >= 2160)
	{
		findSz = QSize(3840, 2160);
		defKBps = 6000;
	}
	else if (m_vCfg._size.height() >= 1080)
	{
		findSz = QSize(1920, 1080);
		defKBps = 2000;
	}
	else if (m_vCfg._size.height() >= 720)
	{
		findSz = QSize(1280, 720);
		defKBps = 1000;
	}
	else if(m_vCfg._size.height() >= 480)
	{
		findSz = QSize(856, 480);
		defKBps = 500;
	}
	ui.cbBx_resolution->setCurrentIndex(ui.cbBx_resolution->findData(findSz));
	m_defKBps = defKBps;
	if(-1 == m_vCfg._maxbps)
	{
		ui.sld_bps->setValue(10);
		ui.lbl_bps->setText(QString("%1kbps").arg(m_defKBps));
	}
	else
	{
		int setBps = m_vCfg._maxbps / 1000;
		if(setBps > m_defKBps * 2)
		{
			setBps = m_defKBps * 2;
		}
		else if(setBps < m_defKBps / 2)
		{
			setBps = m_defKBps / 2;
		}
		int setVal = setBps * 10 / m_defKBps;
		ui.sld_bps->setValue(setVal);
		ui.lbl_bps->setText(QString("%1kbps").arg(setBps));
	}

	if(m_vCfg._min_qp == m_vCfg._max_qp)
	{
		ui.rb_qualityMode->setChecked(true);
	}
	else
	{
		ui.rb_smoothMode->setChecked(true);
	}

	jsonStr = g_sdkMain->getSDKMeeting().getVideoEffects();
	m_vEffects = JsonToStruct<VideoEffectsObj>(crStrToByteArray(jsonStr));
	ui.ck_denoise->setChecked(m_vEffects._denoise);

	ui.cbBx_resolution->blockSignals(false);
	ui.cbBx_fps->blockSignals(false);
	ui.sld_bps->blockSignals(false);
	ui.rb_qualityMode->blockSignals(false);
	ui.rb_smoothMode->blockSignals(false);
	ui.ck_denoise->blockSignals(false);
}

void DlgVideoSet::initCamera()
{
	int defCam = g_sdkMain->getSDKMeeting().getDefaultVideo(MainDialog::getMyUserID().constData());
	initCamera(ui.cbBx_camSel, defCam);

	int multiCam = -1;
	CRBase::CRArray<int> lst = g_sdkMain->getSDKMeeting().getMutiVideos(MainDialog::getMyUserID().constData());
	if (lst.count() > 0)
	{
		multiCam = lst.item(0);
	}
	initCamera(ui.cbBx_camSel_2, multiCam);
}

void DlgVideoSet::initCamera(QComboBox *box, int defCam)
{
	box->blockSignals(true);

	box->clear();
	if (ui.cbBx_camSel_2 == box)
	{
		box->insertItem(0, tr("无"), 0);
	}
	CRBase::CRArray<CRVideoDevInfo> camDevs = g_sdkMain->getSDKMeeting().getAllVideoInfo(MainDialog::getMyUserID().constData());
    for(uint32_t i = 0; i < camDevs.count(); i++)
	{
		const CRVideoDevInfo &devInfo = camDevs.item(i);
		box->insertItem(box->count(), crStrToQStr(devInfo._devName), devInfo._videoID);
	}

	int boxIndex = -1;
	if (defCam >= 0 && box->count() > 0)
	{
		boxIndex = box->findData(defCam);
	}
	box->setCurrentIndex(boxIndex != -1 ? boxIndex: 0);
	box->blockSignals(false);
}

void DlgVideoSet::slot_HwChanged()
{

}