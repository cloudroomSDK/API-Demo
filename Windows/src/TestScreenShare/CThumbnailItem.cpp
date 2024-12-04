#include "stdafx.h"
#include "CThumbnailItem.h"
#include "KeepAspectRatioDrawer.h"

CThumbnailItem::CThumbnailItem(QWidget *parent) : QWidget(parent)
{
	ui.setupUi(this);
	ui.thumbImg->installEventFilter(this);
	ui.icon->installEventFilter(this);
	ui.textLabel->installEventFilter(this);
}

CThumbnailItem::~CThumbnailItem()
{
}

void CThumbnailItem::setInfo(const CRScreenCaptureSourceInfo& info)
{
	QString txt;
	if (info._type == CRVSDK_CAPSOURCE_SCREEN)
	{
		txt = tr("屏幕%1").arg(int(info._sourceId) + 1);
	}
	else
	{
		txt = crStrToQStr(info._sourceTitle);
	}

	ui.textLabel->setToolTip(txt);
	ui.textLabel->setText(txt);
	m_info = info;
}

void CThumbnailItem::updateStyle(bool bSelected)
{
	if (bSelected)
	{
		ui.frmItem->setObjectName("frmItem_checked");
		WidgetStyleUpdate(ui.frmItem);
		WidgetStyleUpdate(ui.textLabel);
	}
	else
	{
		ui.frmItem->setObjectName("frmItem");
		WidgetStyleUpdate(ui.frmItem);
		WidgetStyleUpdate(ui.textLabel);
	}
}

void CThumbnailItem::paintEvent(QPaintEvent *event)
{
	QStyleOption opt;
	opt.init(this);
	QPainter p(this);
	style()->drawPrimitive(QStyle::PE_Widget, &opt, &p, this);
}


bool CThumbnailItem::eventFilter(QObject *watched, QEvent *event)
{
	if (watched == ui.thumbImg && event->type() == QEvent::Paint)
	{
		//绘制缩略图
		KeepAspectRatioDrawer::DrawImage(ui.thumbImg, m_info._thumbImage, CRVSDK_RENDERMD_FIT, false, QColor(0, 0, 0, 0));
		return true;
	}
	if (watched == ui.icon && event->type() == QEvent::Paint)
	{
		//绘制缩略图
		KeepAspectRatioDrawer::DrawImage(ui.icon, m_info._iconImage, CRVSDK_RENDERMD_FIT, false, QColor(0, 0, 0, 0));
		return true;
	}
	if (watched == ui.textLabel && event->type() == QEvent::Resize)
	{
		QString strOrgText = ui.textLabel->toolTip();
		if (!strOrgText.isEmpty())
		{
			QFontMetrics fontMetrics(ui.textLabel->font());
			int fontSize = fontMetrics.width(strOrgText);//获取之前设置的字符串的像素大小
			QString str = strOrgText;
			int showWidth = ui.textLabel->width() - 10;
			if (fontSize > showWidth)
			{
				str = fontMetrics.elidedText(strOrgText, Qt::ElideRight, showWidth);//返回一个带有省略号的字符串
			}
			ui.textLabel->setText(str);
		}
	}
	return QWidget::eventFilter(watched, event);
}