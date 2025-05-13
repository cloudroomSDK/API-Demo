#include "stdafx.h"
#include "ScreenShareUI.h"
#include "KeepAspectRatioDrawer.h"
#include "maindialog.h"
#include "DlgScreenMark.h"
#include "VirtualKey_Def.h"

ScreenShareUI::ScreenShareUI(QWidget *parent) : CustomRenderWidget(parent, CRVSDK_VIEWTP_SCREEN)
{
	setAttribute(Qt::WA_OpaquePaintEvent);
	setAttribute(Qt::WA_NoSystemBackground);
	ui.setupUi(this);

	this->setFocusPolicy(Qt::StrongFocus);
	this->setMouseTracking(true);

	m_toolbar = new QWidget(this, Qt::SubWindow);
	uiToolbar.setupUi(m_toolbar);
	m_toolbar->show();
	connect(uiToolbar.startMarkBtn, &QToolButton::clicked, this, &ScreenShareUI::slot_startMarkClicked);
	connect(uiToolbar.stopMarkBtn, &QToolButton::clicked, this, &ScreenShareUI::slot_stopMarkClicked);
	connect(uiToolbar.openMarkDlgBtn, &QToolButton::clicked, this, &ScreenShareUI::slot_openMarkDlgClicked);
	connect(uiToolbar.remoteCtrlBtn, &QToolButton::clicked, this, &ScreenShareUI::slot_remoteCtrlBtnClicked);
	connect(this, &ScreenShareUI::s_recvFrame, this, &ScreenShareUI::slot_recvFrame);

#ifdef WIN32
	m_keyCatcher = new KeyBoardCatcher_WinHook(this);
#else
	m_keyCatcher = new KeyBoardCatcher(this);
#endif

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
	setCtrlState(false);
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
	uiToolbar.remoteCtrlBtn->setVisible(m_bForSharer);
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

void ScreenShareUI::slot_remoteCtrlBtnClicked()
{
	if (!m_bForSharer)
		return;

	//参会人员列表
	CRBase::CRArray<CRMeetingMember> mbs = g_sdkMain->getSDKMeeting().getAllMembers();
	if (mbs.count() <= 1)
	{
		QMessageBox::information(this, tr("提示"), tr("当前没有参会人员，无法将控制权限授予他人！"));
		return;
	}

	QMenu *pMenu = new QMenu(this);
	pMenu->setAttribute(Qt::WA_DeleteOnClose);
	connect(pMenu, &QMenu::triggered, this, &ScreenShareUI::slot_remoteCtrlTriggered);

	//收回控制权限
	CRScreenShareInfo shareInfo = g_sdkMain->getSDKMeeting().getScreenShareInfo();
	QAction *pAct = pMenu->addAction(tr("回收控制权限"));
	pAct->setProperty("ctrler", crStrToQStr(shareInfo._ctrlerUserID));
	pAct->setEnabled(shareInfo._ctrlerUserID.length() > 0);

	//授予他人权限
	for (int i = 0; i < mbs.count(); i++)
	{
		const CRMeetingMember &mb = mbs.item(i);
		if (mb._userId == MainDialog::getMyUserID())
			continue;

		pAct = pMenu->addAction(tr("授予：%1").arg(crStrToQStr(mb._nickName)));
		pAct->setProperty("uid", crStrToQStr(mb._userId));
		pAct->setCheckable(true);

		if (mb._userId == shareInfo._ctrlerUserID)
		{
			pAct->setChecked(true);
		}
	}

 	pMenu->popup(QCursor::pos());
}

void ScreenShareUI::slot_remoteCtrlTriggered(QAction *pAct)
{
	QByteArray ctrler = pAct->property("ctrler").toString().toUtf8();
	if (!ctrler.isEmpty())
	{
		g_sdkMain->getSDKMeeting().releaseCtrlRight(ctrler.constData());
		return;
	}

	QByteArray uid = pAct->property("uid").toString().toUtf8();
	g_sdkMain->getSDKMeeting().giveCtrlRight(uid.constData());
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

void ScreenShareUI::notifyGiveCtrlRight(const char* operUserId, const char* targetUserId)
{
	bool bCtrling = false;
	if (MainDialog::getMyUserID()==targetUserId)
	{
		bCtrling = true;
		QMessageBox::information(this, tr("提示"), tr("您已获得远程控制权限！"));
	}
	setCtrlState(bCtrling);
}

void ScreenShareUI::setCtrlState(bool bCtrling)
{
	if (bCtrling == m_bCtrling)
		return;
	m_bCtrling = bCtrling;
	if (m_bCtrling)
	{
		m_keyCatcher->setTargetWidget(this);
	}
	else
	{
		m_keyCatcher->setTargetWidget(nullptr);
	}
}


void ScreenShareUI::notifyReleaseCtrlRight(const char* operUserId, const char* targetUserId)
{
	setCtrlState(false);
	if (MainDialog::getMyUserID() == targetUserId)
	{
		QMessageBox::information(this, tr("提示"), tr("您的远程控制权限已被收回！"));
	}
}



bool ScreenShareUI::focusNextPrevChild(bool next)
{
	if (m_bCtrling)
	{
		//远程控制时，禁止tab切换焦点
		return false;
	}
	return QWidget::focusNextPrevChild(next);
}


QPoint ScreenShareUI::mapToRemote(const QPoint &pos)
{
	QSize frmSz = getFrameSize();
	QRect rt = KeepAspectRatioDrawer::getContentRect(this, frmSz, CRVSDK_RENDERMD_FIT);
	if (!rt.contains(pos))
	{
		return QPoint(-1, -1);
	}
	
	if (rt.width() <= 0 || rt.height() <= 0)
	{
		return QPoint(-1, -1);
	}

	QPoint remotePos = pos - rt.topLeft();
	QPoint newPt;
	newPt.setX(remotePos.x() * frmSz.width() / (rt.width()));
	newPt.setY(remotePos.y() * frmSz.height() / (rt.height()));
	return newPt;
}



void ScreenShareUI::mousePressEvent(QMouseEvent *e)
{
	sendMousePressMsg(e);
}

void ScreenShareUI::sendMousePressMsg(QMouseEvent *e)
{
	if (!m_bCtrling)
		return;

	QPoint curPos = mapToRemote(e->pos());
	if (curPos.x() < 0)
		return;

	CRVSDK_MOUSEMSG_TYPE msgType = (e->type() == QEvent::MouseButtonDblClick) ? CRVSDK_MOUSEMSG_DBCLICK : CRVSDK_MOUSEMSG_DOWN;
	switch (e->button())
	{
	case Qt::LeftButton:
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(msgType, CRVSDK_MOUSEKEY_L, curPos.x(), curPos.y());
		break;
	case Qt::MidButton:
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(msgType, CRVSDK_MOUSEKEY_M, curPos.x(), curPos.y());
		break;
	case Qt::RightButton:
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(msgType, CRVSDK_MOUSEKEY_R, curPos.x(), curPos.y());
		break;
	case Qt::XButton1:
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(msgType, CRVSDK_MOUSEKEY_X, curPos.x(), curPos.y());
		break;
	}
}


void ScreenShareUI::mouseReleaseEvent(QMouseEvent *e)
{
	if (!m_bCtrling)
		return;

	QPoint curPos = mapToRemote(e->pos());
	if (curPos.x() < 0)
		return;

	switch (e->button())
	{
	case Qt::LeftButton:
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(CRVSDK_MOUSEMSG_UP, CRVSDK_MOUSEKEY_L, curPos.x(), curPos.y());
		break;
	case Qt::MidButton:
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(CRVSDK_MOUSEMSG_UP, CRVSDK_MOUSEKEY_M, curPos.x(), curPos.y());
		break;
	case Qt::RightButton:
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(CRVSDK_MOUSEMSG_UP, CRVSDK_MOUSEKEY_R, curPos.x(), curPos.y());
		break;
	case Qt::XButton1:
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(CRVSDK_MOUSEMSG_UP, CRVSDK_MOUSEKEY_X, curPos.x(), curPos.y());
		break;
	}
}


void ScreenShareUI::mouseMoveEvent(QMouseEvent *e)
{
	if (!m_bCtrling)
		return;

	QPoint curPos = mapToRemote(e->pos());
	if (curPos.x() < 0)
		return;

	g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(CRVSDK_MOUSEMSG_MOVE, CRVSDK_MOUSEKEY_NULL, curPos.x(), curPos.y());
}

void ScreenShareUI::mouseDoubleClickEvent(QMouseEvent *e)
{
	sendMousePressMsg(e);
}


void ScreenShareUI::wheelEvent(QWheelEvent *e)
{
	if (!m_bCtrling)
		return;
	QPoint curPos = mapToRemote(e->pos());
	if (curPos.x() < 0)
		return;

	int numDegrees = e->delta();
	if (numDegrees > 0)
	{
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(CRVSDK_MOUSEMSG_DOWN, CRVSDK_MOUSEKEY_WHEEL, curPos.x(), curPos.y());
	}
	else
	{
		g_sdkMain->getSDKMeeting().sendMouseCtrlMsg(CRVSDK_MOUSEMSG_UP, CRVSDK_MOUSEKEY_WHEEL, curPos.x(), curPos.y());
	}
}
