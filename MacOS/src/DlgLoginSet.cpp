#include "stdafx.h"
#include "DlgLoginSet.h"
#include "AccountInfo.h"

DlgLoginSet::SettingInfo DlgLoginSet::s_info;

DlgLoginSet::DlgLoginSet(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);
	connect(ui.btnReset, &QPushButton::clicked, this, &DlgLoginSet::slot_btnResetClicked);
	connect(ui.btnSave, &QPushButton::clicked, this, &DlgLoginSet::slot_btnSaveClicked);
	connect(ui.rbPassword, &QRadioButton::toggled, this, &DlgLoginSet::slot_rbTokenCheckChanged);
	connect(ui.rbToken, &QRadioButton::toggled, this, &DlgLoginSet::slot_rbTokenCheckChanged);
	resetUI();
	slot_rbTokenCheckChanged();

    ui.rbHttps2->hide();
	this->setFixedSize(450, 320);
}

DlgLoginSet::~DlgLoginSet()
{
}

void DlgLoginSet::initSettingInfo()
{
	readCfgFile(s_info);
}

DlgLoginSet::SettingInfo DlgLoginSet::getSettingInfo()
{
	SettingInfo tmp(s_info);
	if (tmp.loginAppID.isEmpty())
	{
		tmp.loginAppID = TEST_AppID.c_str();
		tmp.loginAppSecret = TEST_AppScret.c_str();
	}
	return tmp;
}

void DlgLoginSet::readCfgFile(SettingInfo &info)
{
	info.server = GetInifileString("UserCfg", "server", g_cfgFile, info.server);
	info.httpType = (CRVSDK_WEBPROTOCOL)GetIniFileInt("UserCfg", "httpType", g_cfgFile, info.httpType);
	info.authType = (CRVSDK_AUTHTYPE)GetIniFileInt("UserCfg", "authType", g_cfgFile, info.authType);
	info.loginAppID = GetInifileString("UserCfg", "crAcnt", g_cfgFile, info.loginAppID);
	info.loginAppSecret = GetInifileString("UserCfg", "crPswd", g_cfgFile, info.loginAppSecret);
	info.loginToken = GetInifileString("UserCfg", "token", g_cfgFile, info.loginToken);
}

void DlgLoginSet::writeCfgFile()
{
	SetInifileString("UserCfg", "server", s_info.server, g_cfgFile);
	SetInifileString("UserCfg", "httpType", QString::number(s_info.httpType), g_cfgFile);
	SetInifileString("UserCfg", "authType", QString::number(s_info.authType), g_cfgFile);
	SetInifileString("UserCfg", "crAcnt", s_info.loginAppID, g_cfgFile);
	SetInifileString("UserCfg", "crPswd", s_info.loginAppSecret, g_cfgFile);
	SetInifileString("UserCfg", "token", s_info.loginToken, g_cfgFile);
}


void DlgLoginSet::resetUI()
{
	ui.editServer->setText(s_info.server);
	if (s_info.httpType == CRVSDK_WEBPTC_HTTPS)
	{
		ui.rbHttps->setChecked(true);
	}
	else if (s_info.httpType == CRVSDK_WEBPTC_HTTPS_NOVERRIFY)
	{
		ui.rbHttps2->setChecked(true);
	}
	else
	{
		ui.rbHttp->setChecked(true);
	}
	ui.rbToken->setChecked(s_info.authType == CRVSDK_AUTHTP_TOKEN);

	if (ui.rbPassword->isChecked() && s_info.loginAppID.isEmpty() && TEST_AppID.length()>0)
	{
		ui.editAppID->setText(tr("默认APPID"));
		ui.editAppSecret->setText(tr("*"));
	}
	else
	{
		ui.editAppID->setText(s_info.loginAppID);
		ui.editAppSecret->setText(s_info.loginAppSecret);
		ui.editToken->setPlainText(s_info.loginToken);
	}
}

void DlgLoginSet::slot_btnResetClicked()
{
	s_info.reset();
	resetUI();
	writeCfgFile();
}

void DlgLoginSet::slot_btnSaveClicked()
{
	s_info.server = ui.editServer->text();
	s_info.httpType = ui.rbHttps->isChecked() ? CRVSDK_WEBPTC_HTTPS : (ui.rbHttps2->isChecked() ? CRVSDK_WEBPTC_HTTPS_NOVERRIFY : CRVSDK_WEBPTC_HTTP);
	s_info.authType = ui.rbToken->isChecked() ? CRVSDK_AUTHTP_TOKEN : CRVSDK_AUTHTP_SECRET;
	s_info.loginAppID = ui.editAppID->text();
	s_info.loginAppSecret = ui.editAppSecret->text();
	s_info.loginToken = ui.editToken->toPlainText();
	if (s_info.loginAppID == tr("默认APPID"))
	{
		s_info.loginAppID.clear();
		s_info.loginAppSecret.clear();
	}
	writeCfgFile();
	close();
}

void DlgLoginSet::slot_rbTokenCheckChanged()
{
	ui.stackedWidget->setCurrentIndex(ui.rbToken->isChecked() ? 1 : 0);
}
