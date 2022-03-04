#include "stdafx.h"
#include "CustomRenderWidget.h"
#include "KeepAspectRatioDrawer.h"

CustomRenderWidget::CustomRenderWidget(QWidget *parent, CRVSDK_STREAM_VIEWTYPE viewType) : QWidget(parent), CRCustomRenderHandler(viewType)
{
	this->setAttribute(Qt::WA_OpaquePaintEvent);
	this->setAttribute(Qt::WA_NoSystemBackground);

	g_sdkMain->getSDKMeeting().addCustomRender(this);
	connect(this, SIGNAL(s_recvFrame(qint64)), this, SLOT(update()));

	m_bLocMirror = false;
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
	}
	emit s_recvFrame(frm.getTimestamp());
}

void CustomRenderWidget::paintEvent(QPaintEvent *event)
{
	CRVideoFrame frm = getFrame();
	KeepAspectRatioDrawer::DrawImage(this, frm, CRVSDK_RENDERMD_FIT, m_bLocMirror);
}
