#include "stdafx.h"
#include "DlgLogin.h"
#include "DlgLoginSet.h"
#include "maindialog.h"


DlgLogin::DlgLogin(QWidget *parent)
	: QDialog(parent, Qt::Dialog | Qt::WindowCloseButtonHint)
{
	ui.setupUi(this);
	m_mainDlg = NULL;

	g_sdkMain->AddCallBack(this);
	g_sdkMain->getSDKMeeting().AddCallBack(this);

	m_state = STATE_NULL;
	connect(ui.btnEnterMeeting, &QPushButton::clicked, this, &DlgLogin::slot_btnEnterMeetingClicked);
	connect(ui.btnCreateMeeting, &QPushButton::clicked, this, &DlgLogin::slot_btnCreateMeetingClicked);
	connect(ui.btnLoginSet, &QPushButton::clicked, this, &DlgLogin::slot_btnSetClicked);
	

	DlgLoginSet::initSettingInfo();
}

DlgLogin::~DlgLogin()
{
	g_sdkMain->RmCallBack(this);
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

void DlgLogin::showEvent(QShowEvent *)
{
	int lastRoomId = GetIniFileInt("UserCfg", "lastRoomId", g_cfgFile, 0);
	if (lastRoomId != 0)
	{
		ui.editRoomID->setText(QString::number(lastRoomId));
	}

	qsrand(QTime(0, 0, 0).secsTo(QTime::currentTime()));
	ui.editNickName->setText(QString("APIDemo_%1").arg(qrand() % (9999 - 1000) + 1000));
	QString strVer = QString("V%1").arg(getVersion());
	ui.lbVersion->setText(strVer);
}

void DlgLogin::slot_btnSetClicked()
{
	DlgLoginSet *dlg = new DlgLoginSet(this);
	dlg->setAttribute(Qt::WA_DeleteOnClose);
	dlg->show();
}

void DlgLogin::slot_btnEnterMeetingClicked()
{
	QString strMeetID = ui.editRoomID->text();
	if (strMeetID.isEmpty())
	{
		QMessageBox::information(this, tr("提示"), tr("请输入房间号"));
		return;
	}
	int meetid = strMeetID.toInt();
	if (meetid <= 0 || strMeetID.length() != 8)
	{
		QMessageBox::information(this, tr("提示"), tr("请输入8位正确房间号"));
		return;
	}

	loginAndJoinMeeting(meetid);
}

void DlgLogin::slot_btnCreateMeetingClicked()
{
	loginAndJoinMeeting();
}

void DlgLogin::loginAndJoinMeeting(int meetid)
{
	if (m_state != STATE_NULL)
	{
		return;
	}
	m_meetid = meetid;
	m_userId = ui.editNickName->text();

	ui.btnEnterMeeting->setEnabled(false);
	ui.btnCreateMeeting->setEnabled(false);

	const DlgLoginSet::SettingInfo &info = DlgLoginSet::getSettingInfo();
	CRLoginDat loginDat;
	loginDat._sdkAuthType = info.authType;
	loginDat._appID = qStrToCRStr(info.loginAppID);
	loginDat._md5_appSecret = qStrToCRStr(MakeMd5(info.loginAppSecret.toUtf8()));
	loginDat._token = qStrToCRStr(info.loginToken);

	loginDat._serverAddr = qStrToCRStr(info.server);
	loginDat._webProtocol = info.httpType;
	loginDat._userID = loginDat._nickName = qStrToCRStr(m_userId);

    m_state = STATE_LOGIN_ING;
    g_sdkMain->login(loginDat);
}

void DlgLogin::clearStatus()
{
	if (m_mainDlg != NULL)
	{
		m_mainDlg->hide();
		m_mainDlg->deleteLater();
		m_mainDlg = NULL;
	}
	ui.btnEnterMeeting->setEnabled(true);
	ui.btnCreateMeeting->setEnabled(true);
	//取消入会 / 退出会议
	if (m_state >= STATE_ENTERMEETING_ING)
	{
		g_sdkMain->getSDKMeeting().exitMeeting();
	}
	//取消登录 / 登出
	if (m_state >= STATE_LOGIN_ING)
	{
		g_sdkMain->logout();
	}

	m_state = STATE_NULL;
}

void DlgLogin::loginRslt(CRVSDK_ERR_DEF sdkErr, const char* cookie)
{
	if (sdkErr != CRVSDKERR_NOERR)
	{
		clearStatus();
		QMessageBox::information(this, tr("提示"), tr("登录异常(%1)").arg(getErrDesc(sdkErr)));
		return;
	}
	m_state = STATE_LOGIN_SUCCESS;

	//登录成功，进入房间或者创建房间
	if (m_meetid != 0)
	{
		enterMeeting(m_meetid);
	}
	else
	{
		g_sdkMain->createMeeting();
	}
}

void DlgLogin::notifyLineOff(CRVSDK_ERR_DEF sdkErr)
{
	QMessageBox::information(this, tr("提示"), tr("与服务器的连接中断！(原因:%1)").arg(getErrDesc(sdkErr)));
	slot_mainDlgFinished();
}

void DlgLogin::createMeetingSuccess(const CRMeetInfo& meetObj, const char* cookie)
{
	m_meetid = meetObj._ID;
	//创建房间成功，进入房间
	enterMeeting(m_meetid);
}

void DlgLogin::createMeetingFail(CRVSDK_ERR_DEF sdkErr, const char* cookie)
{
	clearStatus();
	QMessageBox::information(this, tr("提示"), tr("创建房间异常(%1)").arg(getErrDesc(sdkErr)));
}

void DlgLogin::enterMeeting(int meetid)
{
	m_state = STATE_ENTERMEETING_ING;
	g_sdkMain->getSDKMeeting().enterMeeting(meetid);
}

void DlgLogin::enterMeetingRslt(CRVSDK_ERR_DEF sdkErr)
{
	//进入房间失败
	if (sdkErr != CRVSDKERR_NOERR)
	{
		clearStatus();
		QMessageBox::information(this, tr("提示"), tr("进入房间异常(%1)").arg(getErrDesc(sdkErr)));
		return;
	}
	m_state = STATE_ENTERMEETING_SUCCESS;
	SetInifileString("UserCfg", "lastRoomId", QString::number(m_meetid), g_cfgFile);

	//显示主窗口，隐藏登录窗口
	m_mainDlg = new MainDialog(QApplication::desktop(), m_meetid, m_userId);
	m_mainDlg->setAttribute(Qt::WA_DeleteOnClose);
	connect(m_mainDlg, &MainDialog::finished, this, &DlgLogin::slot_mainDlgFinished);
	m_mainDlg->show();
	this->hide();
}

void DlgLogin::notifyMeetingStopped()
{
	QMessageBox::information(this, tr("提示"), tr("会议已结束！"));
	slot_mainDlgFinished();
}


void DlgLogin::slot_mainDlgFinished()
{
	clearStatus();
	this->show();
}

void DlgLogin::closeEvent(QCloseEvent *)
{
	//退出进程
	clearStatus();
}
