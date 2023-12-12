#include "stdafx.h"
#include "CanvasWidget.h"
#include "KeepAspectRatioDrawer.h"

VideoCanvasWidget::VideoCanvasWidget(QWidget *parent)
	: QWidget(parent)
	, CRCanvas(CRVSDK_VIEWTP_VIDEO, (void*)winId())
{	
	g_sdkMain->getSDKMeeting().addCanvas(this);
	//设置该属性，将绘制全部交给内部渲染
	this->setAttribute(Qt::WA_PaintOnScreen);
}

VideoCanvasWidget::~VideoCanvasWidget()
{
	g_sdkMain->getSDKMeeting().rmCanvas(this);
}

//与WA_PaintOnScreen配合使用
QPaintEngine* VideoCanvasWidget::paintEngine() const
{
	return 0;
}