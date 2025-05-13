#include "stdafx.h"
#include "TestVirtualBackground.h"
#include "maindialog.h"

//随意定义，只要在sdk使用中不与其它模块重复即可
#define VIRTUALBK_RESID	"vbk_res_id"

TestVirtualBackground::TestVirtualBackground(QWidget *parent)
	: QDialog(parent, Qt::WindowCloseButtonHint | Qt::Dialog)
{
	ui.setupUi(this);

	CRUserVideoID userVideoID = CRUserVideoID(MainDialog::getMyUserID());
	ui.videoCanvas->setVideoID(userVideoID);

	_modeBtnGrp = new QButtonGroup(this);
	_modeBtnGrp->addButton(ui.nulMode, VBKTP_UNDEF);
	_modeBtnGrp->addButton(ui.colorMode, VBKTP_COLORKEY);
	_modeBtnGrp->addButton(ui.aiMode, VBKTP_HUMANSEG);
	connect(_modeBtnGrp, SIGNAL(buttonToggled(int, bool)), this, SLOT(on_modeButtonToggled(int, bool)));
	connect(ui.okBtn, &QPushButton::clicked, this, &TestVirtualBackground::on_okBtnClicked);
	connect(ui.cancelBtn, &QPushButton::clicked, this, &TestVirtualBackground::close);

	updateUIFromSdk();
}

TestVirtualBackground::~TestVirtualBackground()
{

}

void TestVirtualBackground::updateUIFromSdk()
{
	CRString jsonStr = g_sdkMain->getSDKMeeting().getVirtualBackgroundParams();
	VirtualBkCfg cfg = JsonToStruct<VirtualBkCfg>(crStrToByteArray(jsonStr));
	if (!g_sdkMain->getSDKMeeting().isVirtualBackgroundStarted())
	{
		cfg._type = VBKTP_UNDEF;
	}

	QAbstractButton *pBtn = _modeBtnGrp->button(cfg._type);
	if (pBtn == nullptr) pBtn = ui.nulMode;
	_modeBtnGrp->blockSignals(true);
	pBtn->setChecked(true);
	_modeBtnGrp->blockSignals(false);

	ui.colorValue->setEnabled(cfg._type == VBKTP_COLORKEY);
	ui.colorValue->setText(cfg._colorKey);
	ui.colorDesc->setVisible(cfg._type == VBKTP_COLORKEY);
}

void TestVirtualBackground::on_modeButtonToggled(int id, bool bChecked)
{
	if (!bChecked)
		return;

	ui.colorValue->setEnabled(id == VBKTP_COLORKEY);
	ui.colorDesc->setVisible(id == VBKTP_COLORKEY);
}

void TestVirtualBackground::on_okBtnClicked()
{
	CRString curStr = g_sdkMain->getSDKMeeting().getVirtualBackgroundParams();
	VirtualBkCfg curCfg = JsonToStruct<VirtualBkCfg>(crStrToByteArray(curStr));

	VirtualBkCfg newCfg;
	newCfg._type = (VIRTUALBK_TYPE)_modeBtnGrp->checkedId();
	newCfg._colorKey = ui.colorValue->text();
	newCfg._bkImgFromResID = VIRTUALBK_RESID;

	if (curCfg._type != newCfg._type)
	{
		g_sdkMain->getSDKMeeting().stopVirtualBackground();
		g_sdkMain->setPicResource(VIRTUALBK_RESID, CRVideoFrame());	//设置为空资源，移除sdk内部资源
	}
	if (newCfg._type != VBKTP_UNDEF)
	{
		CRVSDK_ERR_DEF err;
		if (g_sdkMain->getSDKMeeting().isVirtualBackgroundStarted())
		{
			QByteArray jsonStr = StructToJson(newCfg);
			err = g_sdkMain->getSDKMeeting().updateVirtualBackgroundParams(jsonStr.constData());
			if (err != CRVSDKERR_NOERR)
			{
				QMessageBox::information(this, tr("错误"), tr("更新虚拟背景失败，%1").arg(getErrDesc(err)));
				updateUIFromSdk();
			}
		}
		else
		{
			CRVideoFrame picFrm = loadImgAsCRVideoFrame(":/Resources/custom_video_1280x720.jpg");
			g_sdkMain->setPicResource(VIRTUALBK_RESID, picFrm);

			QByteArray jsonStr = StructToJson(newCfg);
			err = g_sdkMain->getSDKMeeting().startVirtualBackground(jsonStr.constData());
			if (err != CRVSDKERR_NOERR)
			{
				QMessageBox::information(this, tr("错误"), tr("开启虚拟背景失败，%1").arg(getErrDesc(err)));
				updateUIFromSdk();
			}
		}
	}
}
