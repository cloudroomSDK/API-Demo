#include "stdafx.h"
#include "NetSignalWidget.h"

NetSignalWidget::NetSignalWidget(QWidget *parent)
: QWidget(parent)
, m_level(0)
{
}

NetSignalWidget::~NetSignalWidget()
{

}

void NetSignalWidget::paintEvent(QPaintEvent *event)
{
	QPainter painter(this);
	
	if (m_imgMin.size() != this->size())
	{
		m_imgMin = QImage(":/Resources/net_min.png").scaled(this->size(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
	}
	if (m_imgMax.size() != this->size())
	{
		m_imgMax = QImage(":/Resources/net_max.png").scaled(this->size(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
	}

	painter.drawImage(QPoint(),  m_imgMin);
	int nMaxDraw = this->width()*m_level / 10;
	if (nMaxDraw > 0)
	{
		painter.drawImage(QPoint(), m_imgMax, QRect(0, 0, nMaxDraw, this->height()));
	}
}

void NetSignalWidget::setLevel(int level)
{
	m_level = level;
	update();
}
