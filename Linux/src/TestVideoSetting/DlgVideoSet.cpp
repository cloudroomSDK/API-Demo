#include "stdafx.h"
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
	ui.cbBx_resolution->insertItem(1, QString("480P"), QSize(848, 480));
	ui.cbBx_resolution->insertItem(2, QString("720P"), QSize(1280, 720));

	ui.cbBx_fps->insertItem(0, QString("8"), 8);
	ui.cbBx_fps->insertItem(1, QString("15"), 15);
	ui.cbBx_fps->insertItem(2, QString("24"), 24);

	m_defKBps = 350;
	ui.sld_bps->setRange(5, 20);

	connect(ui.cbBx_camSel, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_camSelChanged(int)));
	connect(ui.cbBx_resolution, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_resolutionChanged(int)));
	connect(ui.cbBx_fps, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_fpsChanged(int)));
	connect(ui.sld_bps, &QSlider::valueChanged, this, &DlgVideoSet::slot_bpsChanged);

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

void DlgVideoSet::slot_resolutionChanged(int idx)
{
	QSize newSize = ui.cbBx_resolution->itemData(idx).toSize();
	m_vCfg._size.setSize(newSize.width(), newSize.height());

	//同步修改bps
	ui.sld_bps->blockSignals(true);
	int defKBps = 350;
	if(m_vCfg._size.cy >= 720)
	{
		defKBps = 1000;
	}
	else if(m_vCfg._size.cy >= 480)
	{
		defKBps = 500;
	}
	m_defKBps = defKBps;
	m_vCfg._maxbps = -1;
	ui.sld_bps->setValue(10);
	ui.lbl_bps->setText(QString("%1kbps").arg(defKBps));
	ui.sld_bps->blockSignals(false);

	g_sdkMain->getSDKMeeting().setVideoCfg(m_vCfg);
}

void DlgVideoSet::slot_fpsChanged(int idx)
{
	int newFps = ui.cbBx_fps->itemData(idx).toInt();
	m_vCfg._fps = newFps;

	g_sdkMain->getSDKMeeting().setVideoCfg(m_vCfg);
}

void DlgVideoSet::slot_bpsChanged(int val)
{
	int setbps = m_defKBps * 100 * val;
	m_vCfg._maxbps = setbps;
	ui.lbl_bps->setText(QString("%1kbps").arg(setbps / 1000));

	g_sdkMain->getSDKMeeting().setVideoCfg(m_vCfg);
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

	g_sdkMain->getSDKMeeting().setVideoCfg(m_vCfg);
}

void DlgVideoSet::initVideoParams()
{
	initCamera();

	ui.cbBx_resolution->blockSignals(true);
	ui.cbBx_fps->blockSignals(true);
	ui.sld_bps->blockSignals(true);
	ui.rb_qualityMode->blockSignals(true);
	ui.rb_smoothMode->blockSignals(true);

	m_vCfg = g_sdkMain->getSDKMeeting().getVideoCfg();

	int findFps = 8;
	if(m_vCfg._fps >= 24)
	{
		findFps = 24;
	}
	else if(m_vCfg._fps >= 15)
	{
		findFps = 15;
	}
	ui.cbBx_fps->setCurrentIndex(ui.cbBx_fps->findData(findFps));

	QSize findSz(640, 360);
	int defKBps = 350;
	if(m_vCfg._size.cy >= 720)
	{
		findSz = QSize(1280, 720);
		defKBps = 1000;
	}
	else if(m_vCfg._size.cy >= 480)
	{
		findSz = QSize(848, 480);
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

	if(m_vCfg._min_qp == 22 && m_vCfg._max_qp == 22)
	{
		ui.rb_qualityMode->setChecked(true);
	}
	else if(m_vCfg._min_qp == 22 && m_vCfg._max_qp == 40)
	{
		ui.rb_smoothMode->setChecked(true);
	}

	ui.cbBx_resolution->blockSignals(false);
	ui.cbBx_fps->blockSignals(false);
	ui.sld_bps->blockSignals(false);
	ui.rb_qualityMode->blockSignals(false);
	ui.rb_smoothMode->blockSignals(false);
}

void DlgVideoSet::initCamera()
{
	ui.cbBx_camSel->blockSignals(true);

	ui.cbBx_camSel->clear();
	CRBase::CRArray<CRVideoDevInfo> camDevs = g_sdkMain->getSDKMeeting().getAllVideoInfo(MainDialog::getMyUserID().constData());
    for(uint32_t i = 0; i < camDevs.count(); i++)
	{
		const CRVideoDevInfo &devInfo = camDevs.item(i);
		ui.cbBx_camSel->insertItem(i, crStrToQStr(devInfo._devName), devInfo._videoID);
	}

	int defCam = g_sdkMain->getSDKMeeting().getDefaultVideo(MainDialog::getMyUserID().constData());
	if(defCam >= 0 && ui.cbBx_camSel->count() > 0)
	{
		int camIdx = ui.cbBx_camSel->findData(defCam);
		if(camIdx > -1)
		{
			ui.cbBx_camSel->setCurrentIndex(camIdx);
		}
		else
		{
			ui.cbBx_camSel->setCurrentIndex(0);
		}
	}

	ui.cbBx_camSel->blockSignals(false);
}

