#include "stdafx.h"
#include "KVideoUI.h"
#include "ui_KVideoUI.h"
#include "maindialog.h"
#include "KeepAspectRatioDrawer.h"

KVideoUI::KVideoUI(QWidget* pParent) : CustomRenderBase(pParent, CRVSDK_VIEWTP_VIDEO)
{
	ui = new Ui::KVideoUI;
	ui->setupUi(this);
	this->layout()->setMargin(0);

	m_mineVideo = false;
	m_videoRotate = 0;

	connect(ui->VUI_btnMic, SIGNAL(clicked()), this, SLOT(slot_btnMicClicked()));
	connect(ui->VUI_btnCam, SIGNAL(clicked()), this, SLOT(slot_btnCamClicked()));
	connect(ui->VUI_btnMirror, SIGNAL(clicked()), this, SLOT(slot_btnMirrorClicked()));
	connect(ui->VUI_btnRotate, SIGNAL(clicked()), this, SLOT(slot_btnRotateClicked()));

	initAllPics();
	updateBtnState(CRString(), CRVSDK_AST_NULL, CRVSDK_VST_NULL);

	setRenderEnabled(isRenderState());
}

void KVideoUI::clean()
{
 	this->setVideoInfo(CRUserVideoID());
	this->clearFrame();
}

KVideoUI::~KVideoUI()
{
	g_sdkMain->getSDKMeeting().rmCustomRender(this);

	delete ui;
	ui = NULL;
}

void KVideoUI::updateNickname(const QString &nickname)
{
	ui->VUI_nickname->setText(nickname);
	if (!m_fullVideoUI.isNull())
	{
		m_fullVideoUI->updateNickname(nickname);
	}
}

void KVideoUI::updateNetState(int level)
{
	ui->VUI_netState->setLevel(level);
	if (!m_fullVideoUI.isNull())
	{
		m_fullVideoUI->updateNetState(level);
	}
}

void KVideoUI::updateMicStatus(CRVSDK_ASTATUS aStatus)
{
	m_aST = aStatus;
	ui->VUI_btnMic->setVisible(aStatus > CRVSDK_AST_NULL);
	QString iconStr(":/Resources/micLv_0.png");
	if(aStatus != CRVSDK_AST_OPEN)
	{
		iconStr = QString(":/Resources/micClosed.png");
	}
	ui->VUI_btnMic->setIcon(QIcon(iconStr));

	if (!m_fullVideoUI.isNull())
	{
		m_fullVideoUI->updateMicStatus(aStatus);
	}
}

void KVideoUI::updateMicEnergy(int level)
{
	m_micEnergyLv = level;
	int micLv = 0;
	if(level >= 8)
		micLv = 3;
	else if(level > 5)
		micLv = 2;
	else if(level > 2)
		micLv = 1;

	QString iconStr = QString(":/Resources/micLv_%1.png").arg(micLv);
	QIcon icon;
	icon.addFile(iconStr, QSize(), QIcon::Normal);
	icon.addFile(iconStr, QSize(), QIcon::Disabled);
	ui->VUI_btnMic->setIcon(icon);

	if (!m_fullVideoUI.isNull())
	{
		m_fullVideoUI->updateMicEnergy(level);
	}
}

void KVideoUI::updateCamStatus(CRVSDK_VSTATUS vStatus)
{
	m_vST = vStatus;
    ui->VUI_btnCam->setVisible(vStatus > CRVSDK_VST_NULL);
	QString iconStr(":/Resources/camOpened.png");
	if(vStatus != CRVSDK_VST_OPEN)
	{
		iconStr = QString(":/Resources/camClosed.png");
	}
	ui->VUI_btnCam->setIcon(QIcon(iconStr));
	setRenderEnabled(isRenderState());

	if (!m_fullVideoUI.isNull())
	{
		m_fullVideoUI->updateCamStatus(vStatus);
	}
}


bool KVideoUI::isRenderState() const
{
	CRVSDK_VSTATUS vstatus = g_sdkMain->getSDKMeeting().getVideoStatus(m_vId._userID.constData());
	bool bRender = (vstatus == CRVSDK_VST_OPEN);
	return bRender;
}

void KVideoUI::initAllPics()
{
	ui->VUI_btnMirror->setIcon(QIcon(":/Resources/camMirror.png"));
	ui->VUI_btnRotate->setIcon(QIcon(":/Resources/camRotate.png"));
	ui->VUI_btnMic->setIcon(QIcon(":/Resources/micLv_0.png"));
	ui->VUI_btnCam->setIcon(QIcon(":/Resources/camOpened.png"));
	ui->VUI_btnMic->setIconSize(QSize(24, 24));
	ui->VUI_btnCam->setIconSize(QSize(24, 24));
	ui->VUI_btnMirror->setCursor(Qt::PointingHandCursor);
	ui->VUI_btnRotate->setCursor(Qt::PointingHandCursor);
	ui->VUI_btnMic->setCursor(Qt::PointingHandCursor);
	ui->VUI_btnCam->setCursor(Qt::PointingHandCursor);
}

void KVideoUI::updateBtnState(const CRBase::CRString &nickname, CRVSDK_ASTATUS aStatus, CRVSDK_VSTATUS vStatus)
{
	ui->VUI_btnMirror->setVisible(m_mineVideo);
	ui->VUI_btnRotate->setVisible(m_mineVideo);

	bool hasSub = !m_vId._userID.isEmpty();
	ui->VUITop->setVisible(m_mineVideo);
	ui->VUIBottom->setVisible(hasSub);
	ui->VUI_btnMic->setEnabled(m_mineVideo);
	ui->VUI_btnCam->setEnabled(m_mineVideo);

	updateNickname(QString(nickname.constData()));
	updateMicStatus(aStatus);
	updateCamStatus(vStatus);
}

void KVideoUI::setVideoInfo(const char* userID)
{
	CRVSDK::CRUserVideoID usrVideoID;
	usrVideoID._userID = CRBase::CRString(userID);
	usrVideoID._videoID = -1;
	setVideoInfo(usrVideoID);
}

void KVideoUI::setVideoInfo(const CRVSDK::CRUserVideoID &cam)
{
	if ( cam==m_vId )
	{
		return;
	}

	clearFrame();

	//应用新设置
	setLocMirror(false);
	m_vId = cam;
	m_mineVideo = (MainDialog::getMyUserID() == m_vId._userID);
	this->setVideoID(m_vId);
	setRenderEnabled(isRenderState());

	CRMeetingMember mem;
	if(!m_vId._userID.isEmpty())
	{
		g_sdkMain->getSDKMeeting().getMemberInfo(m_vId._userID.constData(), mem);
	}
	updateBtnState(mem._nickName, mem._audioStatus, mem._videoStatus);
}

void KVideoUI::slot_btnMicClicked()
{
	if(!m_mineVideo)
		return;
	if(m_vId._userID.isEmpty())
		return;

	const char* userId = m_vId._userID.constData();
	CRVSDK_ASTATUS aStatus = g_sdkMain->getSDKMeeting().getMicStatus(userId);
	if(aStatus == CRVSDK_AST_OPEN)
	{
		g_sdkMain->getSDKMeeting().closeMic(userId);
	}
	else
	{
		g_sdkMain->getSDKMeeting().openMic(userId);
	}
}

void KVideoUI::slot_btnCamClicked()
{
	if(!m_mineVideo)
		return;
	if(m_vId._userID.isEmpty())
		return;

	const char* userId = m_vId._userID.constData();
	CRVSDK_VSTATUS vStatus = g_sdkMain->getSDKMeeting().getVideoStatus(userId);
	if(vStatus == CRVSDK_VST_OPEN)
	{
		g_sdkMain->getSDKMeeting().closeVideo(userId);
	}
	else
	{
		g_sdkMain->getSDKMeeting().openVideo(m_vId._userID.constData());
	}
	setRenderEnabled(isRenderState());
}

void KVideoUI::slot_btnMirrorClicked()
{
	if(!m_mineVideo)
		return;
	if(m_vId._userID.isEmpty())
		return;

	//本地视频镜像
	this->setLocMirror(!getLocMirror());
}

void KVideoUI::slot_btnRotateClicked()
{
	if(!m_mineVideo)
		return;
	if(m_vId._userID.isEmpty())
		return;

	CRBase::CRString videoEff = g_sdkMain->getSDKMeeting().getVideoEffects();
	QByteArray qVideoEff(videoEff.constData(), videoEff.size());
	QVariantMap vMap = QJsonDocument::fromJson(qVideoEff).toVariant().toMap();
	int degree = vMap["degree"].toInt();
	if(degree < 0)
	{
		degree = 0;
	}
	degree += 90;
	if(degree >= 360)
	{
		degree = 0;
	}
	vMap["degree"] = degree;
	QByteArray newEff = CoverJsonToString(vMap);
	g_sdkMain->getSDKMeeting().setVideoEffects(newEff.constData());
}

void KVideoUI::paintEvent(QPaintEvent *event)
{
	bool showEmpty = m_vId._userID.isEmpty();
	if(showEmpty)
	{
		QPainter p(this);
		//填充全白
		p.fillRect(rect(), QColor(240, 240, 240));
		return;
	}

	CustomRenderBase::paintEvent(event);
}

void KVideoUI::mouseDoubleClickEvent(QMouseEvent *event)
{
	QWidget::mouseDoubleClickEvent(event);

	QDialog *pFullDlg = this->property("FullDlg").value<QDialog*>();
	if (pFullDlg == nullptr)
	{
		pFullDlg = new QDialog(this);
		QHBoxLayout* horizontalLayout = new QHBoxLayout(pFullDlg);
		horizontalLayout->setMargin(0);
		KVideoUI *pVUI = new KVideoUI(pFullDlg);
		horizontalLayout->addWidget(pVUI);


		pVUI->setProperty("FullDlg", QVariant::fromValue(pFullDlg));
		pVUI->setVideoInfo(m_vId);
		pVUI->updateNickname(ui->VUI_nickname->text());
		pVUI->updateNetState(ui->VUI_netState->getLevel());
		pVUI->updateMicStatus(m_aST);
		pVUI->updateMicEnergy(m_micEnergyLv);
		pVUI->updateCamStatus(m_vST);
		pVUI->show();

		pFullDlg->setAttribute(Qt::WA_DeleteOnClose);
		pFullDlg->showFullScreen();

		m_fullVideoUI = pVUI;
	}
	else
	{
		pFullDlg->close();
		pFullDlg->deleteLater();
	}
}
