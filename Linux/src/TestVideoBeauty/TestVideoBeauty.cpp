#include "stdafx.h"
#include "TestVideoBeauty.h"
#include "maindialog.h"

#define SLIDE_MAX	20

float getBestMaxvalue(BeautyFilterType type)
{
	switch (type)
	{
	case BeautyThinFace: return 0.05;
	case BeautyBigEye: return 0.2;
	default: return 1.0;
	}
}

TestVideoBeauty::TestVideoBeauty(QWidget *parent)
	: QDialog(parent, Qt::WindowMaximizeButtonHint | Qt::WindowCloseButtonHint | Qt::Dialog)
{
	ui.setupUi(this);

	CRUserVideoID userVideoID = CRUserVideoID(MainDialog::getMyUserID());
	ui.videoCanvas->setVideoID(userVideoID);

	ui.cb_type->addItem(getBeautyFilterTypeName(BeautySmooth), BeautySmooth);
	ui.cb_type->addItem(getBeautyFilterTypeName(BeautyWhiten), BeautyWhiten);
	ui.cb_type->addItem(getBeautyFilterTypeName(BeautyLipstick), BeautyLipstick);
	ui.cb_type->addItem(getBeautyFilterTypeName(BeautyBlusher), BeautyBlusher);
	ui.cb_type->addItem(getBeautyFilterTypeName(BeautyThinFace), BeautyThinFace);
	ui.cb_type->addItem(getBeautyFilterTypeName(BeautyBigEye), BeautyBigEye);
	ui.sld_level->setMaximum(SLIDE_MAX);

	CRString jsonStr = g_sdkMain->getSDKMeeting().getBeautyParams();
	_cfg = JsonToStruct<BeautyCfg>(crStrToByteArray(jsonStr));
	updateCombBoxItemStr();

	ui.cb_type->setCurrentIndex(0);
	slot_filterTypeChanged(0);

	ui.settingPage->hide();

	connect(ui.enableBeautyBtn, &QCheckBox::stateChanged, this, &TestVideoBeauty::slot_enableBeautyStateChanged, Qt::QueuedConnection);
	connect(ui.sld_level, &QSlider::valueChanged, this, &TestVideoBeauty::slot_sliderValueChanged);
	connect(ui.cb_type, SIGNAL(currentIndexChanged(int)), this, SLOT(slot_filterTypeChanged(int)));

	bool bBeautyStarted = g_sdkMain->getSDKMeeting().isBeautyStarted();
	ui.enableBeautyBtn->setChecked(bBeautyStarted);

	g_sdkMain->getSDKMeeting().AddCallBack(this);
}

TestVideoBeauty::~TestVideoBeauty()
{
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void TestVideoBeauty::notifyVideoStatusChanged(const char* userID, CRVSDK_VSTATUS oldStatus, CRVSDK_VSTATUS newStatus, const char* oprUserID)
{
	if (MainDialog::getMyUserID() != userID)
		return;
	if ( newStatus== CRVSDK_VST_CLOSE )
	{
		ui.videoCanvas->clearVideoFrame();
	}
}

void TestVideoBeauty::slot_enableBeautyStateChanged(int v)
{
	bool bVisible = v == Qt::Checked;
	if (bVisible)
	{
		QByteArray jsonStr = StructToJson(_cfg);
		CRVSDK_ERR_DEF err = g_sdkMain->getSDKMeeting().startBeauty(jsonStr.constData());
		if (err != CRVSDKERR_NOERR)
		{
			ui.enableBeautyBtn->setChecked(false);
			QMessageBox::information(this, tr("错误"), tr("开启美颜失败！(%1)").arg(getErrDesc(err)));
			return;
		}
	}
	else
	{
		g_sdkMain->getSDKMeeting().stopBeauty();
	}
	ui.settingPage->setVisible(bVisible);

}

float TestVideoBeauty::getTypeLevel(const BeautyCfg &cfg, BeautyFilterType type)
{
	auto pos = cfg.filters.find(type);
	if (pos == cfg.filters.end())
		return 0.0;
	return pos->second;
}

void TestVideoBeauty::slot_filterTypeChanged(int index)
{
	BeautyFilterType type = BeautyFilterType(ui.cb_type->itemData(index).toInt());
	float lv = getTypeLevel(_cfg, type);
	float maxLv = getBestMaxvalue(type);

	int slideValue = int(lv/maxLv * SLIDE_MAX + 0.0001);
	ui.sld_level->setValue(slideValue);
}

void TestVideoBeauty::updateCombBoxItemStr()
{
	for (int i = 0; i < ui.cb_type->count(); i++)
	{
		BeautyFilterType type = BeautyFilterType(ui.cb_type->itemData(i).toInt());
		float lv = getTypeLevel(_cfg, type);
		updateCombBoxItemStr(i, lv);
	}
}

void TestVideoBeauty::updateCombBoxItemStr(int index, float lv)
{
	BeautyFilterType type = BeautyFilterType(ui.cb_type->itemData(index).toInt());
	QString str = getBeautyFilterTypeName(type);
	str += QString(" (等级:%1)").arg(lv, 0, 'f', 3);
	ui.cb_type->setItemText(index, str);
}

void TestVideoBeauty::slot_sliderValueChanged(int v)
{
	int index = ui.cb_type->currentIndex();
	BeautyFilterType type = BeautyFilterType(ui.cb_type->itemData(index).toInt());
	float maxItemValue = getBestMaxvalue(type);
	float fLv = (v / float(SLIDE_MAX)) * maxItemValue;
	updateCombBoxItemStr(index, fLv);

	_cfg.filters[type] = fLv;
	setCfgToSDK(_cfg);
}

void TestVideoBeauty::setCfgToSDK(const BeautyCfg &cfg)
{
	QByteArray jsonStr = StructToJson(_cfg);
	g_sdkMain->getSDKMeeting().updateBeautyParams(jsonStr.constData());
}
