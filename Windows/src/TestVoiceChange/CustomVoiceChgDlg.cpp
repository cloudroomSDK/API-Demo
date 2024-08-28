#include "stdafx.h"
#include "CustomVoiceChgDlg.h"

CustomVoiceChgDlg::CustomVoiceChgDlg(const CRString &usrid, int chgType, QWidget *parent)
	: QDialog(parent)
{
	ui.setupUi(this);

	m_usrID = usrid;
	if (chgType < 100 || chgType>200)
	{
		chgType = 150;
	}
	int value = chgType - 150;
	ui.slider->blockSignals(true);
	ui.slider->setValue(value);
	ui.slider->blockSignals(false);

	on_slider_valueChanged(value);
}

CustomVoiceChgDlg::~CustomVoiceChgDlg()
{

}

void CustomVoiceChgDlg::on_slider_valueChanged(int value)
{
	ui.label->setText(QString("自定义变调值：%1").arg(value));

	int chgType = getVoiceChangeType();
	g_sdkMain->getSDKMeeting().setVoiceChange(m_usrID.constData(), chgType);
}

int CustomVoiceChgDlg::getVoiceChangeType()
{
	int chgType = ui.slider->value() + 150;
	return chgType;
}

