#include "stdafx.h"
#include "CustomRenderWidget.h"
#include "KeepAspectRatioDrawer.h"

CustomRenderWidget::CustomRenderWidget(QWidget *parent, CRVSDK_STREAM_VIEWTYPE viewType) : QWidget(parent), CRCustomRenderHandler(viewType)
{
	this->setAttribute(Qt::WA_OpaquePaintEvent);
	this->setAttribute(Qt::WA_NoSystemBackground);

	g_sdkMain->getSDKMeeting().addCustomRender(this);
	connect(this, SIGNAL(s_update()), this, SLOT(update()));

	m_bLocMirror = false;
	enabledRender(true);
}

CustomRenderWidget::~CustomRenderWidget()
{
	g_sdkMain->getSDKMeeting().rmCustomRender(this);
}

void CustomRenderWidget::enabledRender(bool bEnale)
{
	m_enabledRender = bEnale;
	if (!m_enabledRender)
	{
		clearFrame();
	}
	update();
}

CRVideoFrame CustomRenderWidget::getFrame()
{
	QMutexLocker locker(&m_frameLock);
	return m_frame;
}

int64_t CustomRenderWidget::getFrameTimestamp()
{
	QMutexLocker locker(&m_frameLock);
	return m_frame.getTimestamp();
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

void CustomRenderWidget::onRenderFrameDat(const CRVideoFrame &frm)
{
	{
		QMutexLocker locker(&m_frameLock);
		m_frame = frm;
		emit s_recvFrame(m_frame.getTimestamp());
	}
	if (m_enabledRender)
	{
		emit s_update();
	}
}

void CustomRenderWidget::paintEvent(QPaintEvent *event)
{
	CRVideoFrame frm = m_enabledRender ? getFrame() : CRVideoFrame();
	KeepAspectRatioDrawer::DrawImage(this, frm, CRVSDK_RENDERMD_FIT, m_bLocMirror);
}
