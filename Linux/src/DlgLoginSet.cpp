#include "stdafx.h"
#include "DlgLoginSet.h"

DlgLoginSet::SettingInfo DlgLoginSet::m_info;

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
	this->setFixedSize(400, 400);
}

DlgLoginSet::~DlgLoginSet()
{
}

void DlgLoginSet::initSettingInfo()
{
	readCfgFile(m_info);
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
	SetInifileString("UserCfg", "server", m_info.server, g_cfgFile);
	SetInifileString("UserCfg", "httpType", QString::number(m_info.httpType), g_cfgFile);
	SetInifileString("UserCfg", "authType", QString::number(m_info.authType), g_cfgFile);
	SetInifileString("UserCfg", "crAcnt", m_info.loginAppID, g_cfgFile);
	SetInifileString("UserCfg", "crPswd", m_info.loginAppSecret, g_cfgFile);
	SetInifileString("UserCfg", "token", m_info.loginToken, g_cfgFile);
}


void DlgLoginSet::resetUI()
{
	ui.editServer->setText(m_info.server);
	if (m_info.httpType == CRVSDK_WEBPTC_HTTPS)
	{
		ui.rbHttps->setChecked(true);
	}
	else if (m_info.httpType == CRVSDK_WEBPTC_HTTPS_NOVERRIFY)
	{
		ui.rbHttps2->setChecked(true);
	}
	else
	{
		ui.rbHttp->setChecked(true);
	}
	ui.rbToken->setChecked(m_info.authType == CRVSDK_AUTHTP_TOKEN);
	ui.editAppID->setText(m_info.loginAppID);
	ui.editAppSecret->setText(m_info.loginAppSecret);
	ui.editToken->setPlainText(m_info.loginToken);
}

void DlgLoginSet::slot_btnResetClicked()
{
	m_info.reset();
	resetUI();
	writeCfgFile();
}

void DlgLoginSet::slot_btnSaveClicked()
{
	m_info.server = ui.editServer->text();
	m_info.httpType = ui.rbHttps->isChecked() ? CRVSDK_WEBPTC_HTTPS : (ui.rbHttps2->isChecked() ? CRVSDK_WEBPTC_HTTPS_NOVERRIFY : CRVSDK_WEBPTC_HTTP);
	m_info.authType = ui.rbToken->isChecked() ? CRVSDK_AUTHTP_TOKEN : CRVSDK_AUTHTP_SECRET;
	m_info.loginAppID = ui.editAppID->text();
	m_info.loginAppSecret = ui.editAppSecret->text();
	m_info.loginToken = ui.editToken->toPlainText();
	writeCfgFile();
	close();
}

void DlgLoginSet::slot_rbTokenCheckChanged()
{
	ui.stackedWidget->setCurrentIndex(ui.rbToken->isChecked() ? 1 : 0);
}
