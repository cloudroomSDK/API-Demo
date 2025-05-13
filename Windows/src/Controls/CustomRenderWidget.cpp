#include "stdafx.h"
#include "CustomRenderWidget.h"
#include "KeepAspectRatioDrawer.h"

CustomRenderWidget::CustomRenderWidget(QWidget *parent, CRVSDK_STREAM_VIEWTYPE viewType) : QWidget(parent), CRCustomRenderHandler(viewType)
{
	this->setAttribute(Qt::WA_OpaquePaintEvent);
	this->setAttribute(Qt::WA_NoSystemBackground);

	connect(this, SIGNAL(s_recvFrame(qint64)), this, SLOT(update()));
	m_bLocMirror = false;
	m_defBkColor = Qt::black;
}

CustomRenderWidget::~CustomRenderWidget()
{
	g_sdkMain->getSDKMeeting().rmCustomRender(this);
}

CRVideoFrame CustomRenderWidget::getFrame()
{
	QMutexLocker locker(&m_frameLock);
	return m_frame;
}

QSize CustomRenderWidget::getFrameSize()
{
	QMutexLocker locker(&m_frameLock);
	return QSize(m_frame.getWidth(), m_frame.getHeight());
}

void CustomRenderWidget::setVideoID(const CRUserVideoID &id, CRVSDK_VSTEAMLV_TYPE lv)
{
	if (id == getVideoID() && lv == getVideoStreamLv())
		return;

	CRCustomRenderHandler::setVideoID(id, lv);
	clearFrame();
	if (!id._userID.isEmpty())
	{
		QMutexLocker locker(&m_frameLock);
		m_frame = g_sdkMain->getSDKMeeting().GetVideoImg(id, lv);
	}
}


int64_t CustomRenderWidget::getFrameTimestamp()
{
	QMutexLocker locker(&m_frameLock);
	return m_frame.getPts();
}

void CustomRenderWidget::clearFrame()
{
	{
		QMutexLocker locker(&m_frameLock);
		m_frame.clear();
	}
	update();
}

void CustomRenderWidget::setLocMirror(bool bMirror)
{
	m_bLocMirror = bMirror;
	update();
}

void CustomRenderWidget::setRenderEnabled(bool bEnable)
{
	m_bRenderEnable = bEnable;
	updateRenderHandler();
	if (!bEnable)
	{
		clearFrame();
		update();
	}
}

void CustomRenderWidget::updateRenderHandler()
{
	if (m_bRenderEnable && this->isVisible())
	{
		g_sdkMain->getSDKMeeting().addCustomRender(this);
	}
	else
	{
		g_sdkMain->getSDKMeeting().rmCustomRender(this);
	}
}


void CustomRenderWidget::onRenderFrameDat(const CRVideoFrame &frm, const CRUserVideoID &realVideoID)
{
	//m_recvFps.AddCount();
	//qDebug("recv fps:%d", int(m_recvFps.GetFPS()));

	{
		QMutexLocker locker(&m_frameLock);
		m_frame = frm;
	}
	emit s_recvFrame(frm.getPts());
}

void CustomRenderWidget::setDefaultBackground(const QColor &color)
{
	m_defBkColor = color; 
	update();
}

void CustomRenderWidget::paintEvent(QPaintEvent *event)
{
	//m_drawFps.AddCount();
	//qDebug("draw fps:%d", int(m_drawFps.GetFPS()));
	CRVideoFrame frm = getFrame();
	if (frm.getFrameSize().isEmpty())
	{
		QPainter p(this);
		p.fillRect(rect(), m_defBkColor);
	}
	else
	{
		KeepAspectRatioDrawer::DrawImage(this, frm, CRVSDK_RENDERMD_FIT, m_bLocMirror);
	}
}


void CustomRenderWidget::hideEvent(QHideEvent* event)
{
	QWidget::hideEvent(event);
	updateRenderHandler();
}

void CustomRenderWidget::showEvent(QShowEvent* event)
{
	QWidget::showEvent(event);
	updateRenderHandler();
}
