#include "stdafx.h"
#include "DlgAudioSet.h"

DlgAudioSet::DlgAudioSet(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);

	for(QComboBox *pCbBx : this->findChildren<QComboBox*>())
	{
		QListView *pLV = new QListView;
		pCbBx->setView(pLV);
	}

	connect(ui.cbBx_micSel, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_micSelChanged(int)));
    connect(ui.cbBx_spkSel, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_spkSelChanged(int)));
	connect(ui.sld_micVol, &QSlider::valueChanged, this, &DlgAudioSet::slot_micVolChanged);
	connect(ui.sld_spkVol, &QSlider::valueChanged, this, &DlgAudioSet::slot_spkVolChanged);
	connect(ui.agc, &QCheckBox::stateChanged, this, &DlgAudioSet::slot_3AChanged);
	connect(ui.ans, &QCheckBox::stateChanged, this, &DlgAudioSet::slot_3AChanged);
	connect(ui.aec, &QCheckBox::stateChanged, this, &DlgAudioSet::slot_3AChanged);

	ui.sld_micVol->setRange(0, 255);
	ui.sld_spkVol->setRange(0, 255);

	g_sdkMain->getSDKMeeting().AddCallBack(this);
	initAudioDevs();
	slot_updateAudioVolum();
}

DlgAudioSet::~DlgAudioSet()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgAudioSet::notifyAudioDevChanged()
{
	initAudioDevs();
}

void DlgAudioSet::slot_micSelChanged(int idx)
{
	QString micId = ui.cbBx_micSel->itemData(idx).toString();
	CRAudioCfg aCfg = g_sdkMain->getSDKMeeting().getAudioCfg();
	aCfg._micID = qStrToCRStr(micId);
	g_sdkMain->getSDKMeeting().setAudioCfg(aCfg);
}

void DlgAudioSet::slot_spkSelChanged(int idx)
{
	QString spkId = ui.cbBx_spkSel->itemData(idx).toString();
	CRAudioCfg aCfg = g_sdkMain->getSDKMeeting().getAudioCfg();
    aCfg._spkID = qStrToCRStr(spkId);
	g_sdkMain->getSDKMeeting().setAudioCfg(aCfg);
}

void DlgAudioSet::slot_micVolChanged(int vol)
{
	g_sdkMain->getSDKMeeting().setMicVolume(vol);
}

void DlgAudioSet::slot_spkVolChanged(int vol)
{
	g_sdkMain->getSDKMeeting().setSpkVolume(vol);
}

void DlgAudioSet::slot_3AChanged()
{
	CRAudioCfg aCfg = g_sdkMain->getSDKMeeting().getAudioCfg();
	aCfg._agc = ui.agc->isChecked();
	aCfg._ans = ui.ans->isChecked();
	aCfg._aec = ui.aec->isChecked();
	g_sdkMain->getSDKMeeting().setAudioCfg(aCfg);

	ui.sld_micVol->setEnabled(!aCfg._agc);
}


void DlgAudioSet::initAudioDevs()
{
	ui.cbBx_micSel->blockSignals(true);
	ui.cbBx_spkSel->blockSignals(true);
	ui.agc->blockSignals(true);
	ui.aec->blockSignals(true);
	ui.ans->blockSignals(true);

	//添加麦设备列表
	ui.cbBx_micSel->clear();
	CRBase::CRArray<CRAudioDevInfo> micDevs = g_sdkMain->getSDKMeeting().getAudioMics();
	if (micDevs.count() > 0)
	{
		ui.cbBx_micSel->addItem(tr("系统默认设备"), "");
	}
    for(uint32_t i = 0; i < micDevs.count(); i++)
	{
		const CRAudioDevInfo &devInfo = micDevs.item(i);
		ui.cbBx_micSel->addItem(crStrToQStr(devInfo._name), crStrToQStr(devInfo._id));
	}

	//添加扬声器设备列表
	ui.cbBx_spkSel->clear();
	CRBase::CRArray<CRAudioDevInfo> spkDevs = g_sdkMain->getSDKMeeting().getAudioSpks();
	if (spkDevs.count() > 0)
	{
		ui.cbBx_spkSel->addItem(tr("系统默认设备"), "");
	}
    for (uint32_t i = 0; i < spkDevs.count(); i++)
	{
        const CRAudioDevInfo &devInfo = spkDevs.item(i);
		ui.cbBx_spkSel->addItem(crStrToQStr(devInfo._name), crStrToQStr(devInfo._id));
	}

	//显示当前配置
	CRAudioCfg aCfg = g_sdkMain->getSDKMeeting().getAudioCfg();
	QString curMic = crStrToQStr(aCfg._micID);
	QString curSpk = crStrToQStr(aCfg._spkID);
	if(!curMic.isEmpty() && ui.cbBx_micSel->count() > 0)
	{
		int micIdx = ui.cbBx_micSel->findData(curMic);
		if(-1 < micIdx)
		{
			ui.cbBx_micSel->setCurrentIndex(micIdx);
		}
		else
		{
			ui.cbBx_micSel->setCurrentIndex(0);
		}
	}
	if(!curSpk.isEmpty() && ui.cbBx_spkSel->count() > 0)
	{
		int spkIdx = ui.cbBx_spkSel->findData(curSpk);
		if(-1 < spkIdx)
		{
			ui.cbBx_spkSel->setCurrentIndex(spkIdx);
		}
		else
		{
			ui.cbBx_spkSel->setCurrentIndex(0);
		}
	}
	ui.agc->setChecked(aCfg._agc);
	ui.aec->setChecked(aCfg._aec);
	ui.ans->setChecked(aCfg._ans);

	ui.cbBx_micSel->blockSignals(false);
	ui.cbBx_spkSel->blockSignals(false);
	ui.agc->blockSignals(false);
	ui.aec->blockSignals(false);
	ui.ans->blockSignals(false);

	ui.sld_micVol->setEnabled(!aCfg._agc);
}

void DlgAudioSet::slot_updateAudioVolum()
{
	ui.sld_micVol->blockSignals(true);
	ui.sld_spkVol->blockSignals(true);

	int micVol = g_sdkMain->getSDKMeeting().getMicVolume();
	int spkVol = g_sdkMain->getSDKMeeting().getSpkVolume();
	ui.sld_micVol->setValue(micVol);
	ui.sld_spkVol->setValue(spkVol);

	ui.sld_micVol->blockSignals(false);
	ui.sld_spkVol->blockSignals(false);

	//周期性更新音量，以便系统值被改变时，能正确显示
	QTimer::singleShot(300, this, &DlgAudioSet::slot_updateAudioVolum);
}
