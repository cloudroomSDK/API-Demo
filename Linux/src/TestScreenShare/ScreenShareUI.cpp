#include "stdafx.h"
#include "ScreenShareUI.h"
#include "KeepAspectRatioDrawer.h"
#include "maindialog.h"
#include "DlgScreenMark.h"

ScreenShareUI::ScreenShareUI(QWidget *parent) : CustomRenderWidget(parent, CRVSDK_VIEWTP_SCREEN)
{
	setAttribute(Qt::WA_OpaquePaintEvent);
	setAttribute(Qt::WA_NoSystemBackground);
	ui.setupUi(this);

	m_bForSharer = false;
	m_dlgMark = NULL;
	m_toolbar = new QWidget(this, Qt::SubWindow);
	uiToolbar.setupUi(m_toolbar);
	m_toolbar->show();
	connect(uiToolbar.startMarkBtn, &QToolButton::clicked, this, &ScreenShareUI::slot_startMarkClicked);
	connect(uiToolbar.stopMarkBtn, &QToolButton::clicked, this, &ScreenShareUI::slot_stopMarkClicked);
	connect(uiToolbar.openMarkDlgBtn, &QToolButton::clicked, this, &ScreenShareUI::slot_openMarkDlgClicked);
	connect(this, &ScreenShareUI::s_recvFrame, this, &ScreenShareUI::slot_recvFrame);

	//关注屏幕共享消息
	g_sdkMain->getSDKMeeting().AddCallBack(this);
}

ScreenShareUI::~ScreenShareUI()
{
	if (m_dlgMark != NULL)
	{
		m_dlgMark->close();
		m_dlgMark->deleteLater();
		m_dlgMark = NULL;
	}
	g_sdkMain->getSDKMeeting().RmCallBack(this);
}

//开启屏幕共享结果
void ScreenShareUI::startScreenShareRslt(CRVSDK_ERR_DEF sdkErr)
{
	if (sdkErr == CRVSDKERR_NOERR)
	{
		notifyScreenShareStarted(MainDialog::getMyUserID().constData());
		return;
	}
	QMessageBox::information(this, tr("屏幕共享"), tr("开启屏幕共享失败（%1）").arg(getErrDesc(sdkErr)));
}

//停止屏幕共享结果
void ScreenShareUI::stopScreenShareRslt(CRVSDK_ERR_DEF sdkErr)
{
	if (sdkErr == CRVSDKERR_NOERR)
	{
		notifyScreenShareStopped(MainDialog::getMyUserID().constData());
		return;
	}
	QMessageBox::information(this, tr("屏幕共享"), tr("停止屏幕共享失败（%1）").arg(getErrDesc(sdkErr)));
}

//开启屏幕共享标注结果
void ScreenShareUI::startScreenMarkRslt(CRVSDK_ERR_DEF sdkErr)
{
	if (sdkErr == CRVSDKERR_NOERR)
	{
		notifyScreenMarkStarted();
		return;
	}
	QMessageBox::information(this, tr("屏幕共享"), tr("开启屏幕共享标注失败（%1）").arg(getErrDesc(sdkErr)));
}

//停止屏幕共享标注结果
void ScreenShareUI::stopScreenMarkRslt(CRVSDK_ERR_DEF sdkErr)
{
	if (sdkErr == CRVSDKERR_NOERR)
	{
		notifyScreenMarkStopped();
		return;
	}
	QMessageBox::information(this, tr("屏幕共享"), tr("停止屏幕共享标注失败（%1）").arg(getErrDesc(sdkErr)));
}

//通知屏幕共享开始
void ScreenShareUI::notifyScreenShareStarted(const char* userID)
{
	m_bForSharer = MainDialog::getMyUserID() == userID;
	if (m_bForSharer)
	{
		ui.lbDesc->show();
	}
	else
	{
		ui.lbDesc->hide();
	}
	updateToolbar();
	emit s_shareStateChanged(true);
}

//通知屏幕共享停止
void ScreenShareUI::notifyScreenShareStopped(const char* oprUserID)
{
	ui.lbDesc->hide();
	updateToolbar();
	emit s_shareStateChanged(false);
}

//通知屏幕共享标注开始
void ScreenShareUI::notifyScreenMarkStarted()
{
	m_dlgMark = new DlgScreenMark(m_bForSharer);
	showMarkDlg();
	updateToolbar();
}

//通知屏幕共享标注停止
void ScreenShareUI::notifyScreenMarkStopped()
{
	if (m_dlgMark != NULL)
	{
		m_dlgMark->close();
		m_dlgMark->deleteLater();
		m_dlgMark = NULL;
	}
	updateToolbar();
}

void ScreenShareUI::updateToolbar()
{
	bool isMarking = g_sdkMain->getSDKMeeting().isScreenMarkedState();
	uiToolbar.startMarkBtn->setVisible(m_bForSharer && !isMarking);
	uiToolbar.stopMarkBtn->setVisible(m_bForSharer && isMarking);
	uiToolbar.openMarkDlgBtn->setVisible(isMarking);
}

void ScreenShareUI::slot_startMarkClicked()
{
	if (m_bForSharer)
	{
		g_sdkMain->getSDKMeeting().startScreenMark();
	}
}

void ScreenShareUI::slot_stopMarkClicked()
{
	if (m_bForSharer)
	{
		g_sdkMain->getSDKMeeting().stopScreenMark();
	}
}

void ScreenShareUI::slot_openMarkDlgClicked()
{
	if (m_dlgMark != NULL)
	{
		if (m_dlgMark->isMinimized())
		{
			m_dlgMark->setWindowState(m_dlgMark->windowState() & ~Qt::WindowMinimized);
		}

		if (!m_dlgMark->HasScreenPixmap())
		{
			m_dlgMark->SetScreenPixmap(getFrame());
		}
		m_dlgMark->show();
	}
}

void ScreenShareUI::slot_recvFrame(qint64 ts)
{
	if (m_dlgMark != NULL && !m_dlgMark->isVisible())
	{
		showMarkDlg();
	}
}

void ScreenShareUI::showMarkDlg()
{
	if (m_dlgMark == NULL)
	{
		return;
	}
	//需要等屏幕数据准备好
	if (getFrame().getDatSize() <= 0)
	{
		return;
	}
	CRVideoFrame frm = getFrame();
	QSize showSize(frm.getWidth(), frm.getHeight());
	showSize.scale(800, 500, Qt::KeepAspectRatio);
	m_dlgMark->SetScreenPixmap(frm);
	m_dlgMark->setMinimumSize(showSize);
	m_dlgMark->show();
}

void ScreenShareUI::resizeEvent(QResizeEvent *event)
{
	CustomRenderWidget::resizeEvent(event);

	m_toolbar->setFixedSize(this->width(), 40);
	m_toolbar->move(0, this->height() - m_toolbar->height()); 
}

void ScreenShareUI::paintEvent(QPaintEvent *event)
{
	if (m_bForSharer)
	{
		QPainter painter(this);
		QRect widgetRt = this->rect();
		painter.fillRect(widgetRt, QColor(0, 0, 0));
	}
	else
	{
		CustomRenderWidget::paintEvent(event);
	}
}
