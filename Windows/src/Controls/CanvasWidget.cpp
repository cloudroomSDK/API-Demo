#include "stdafx.h"
#include "CanvasWidget.h"
#include "KeepAspectRatioDrawer.h"

VideoCanvasWidget::VideoCanvasWidget(QWidget *parent)
	: QWidget(parent)
	, CRCanvas(CRVSDK_VIEWTP_VIDEO, (void*)winId())
{	
	this->setStyleSheet("QWidget{background: black;}");
	g_sdkMain->getSDKMeeting().addCanvas(this);
}

VideoCanvasWidget::~VideoCanvasWidget()
{
	g_sdkMain->getSDKMeeting().rmCanvas(this);
}

void VideoCanvasWidget::paintEvent(QPaintEvent *event)
{
	//支持设置qss
	QStyleOption opt;
	opt.init(this);
	QPainter p(this);
	style()->drawPrimitive(QStyle::PE_Widget, &opt, &p, this);
}