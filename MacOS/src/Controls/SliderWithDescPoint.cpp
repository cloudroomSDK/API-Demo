#include "stdafx.h"
#include "SliderWithDescPoint.h"

#define SLD_POINT_ITEM_W 4
#define SLD_HAND_ITEM_W 12

SliderWithDescPoint::SliderWithDescPoint(QWidget *parent)
	: QSlider(parent)
{
	setMouseTracking(true);	// 鼠标跟踪
}

void SliderWithDescPoint::setPoint(int value, const QString &str)
{
	auto pos = m_strs.find(value);
	if (pos == m_strs.end())
	{
		if (str.isEmpty())
			return;
		
		m_strs[value] = str;
	}
	else
	{
		if (str == pos.value())
			return;

		if (str.isEmpty())
		{
			m_strs.erase(pos);
		}
		else
		{
			pos.value() = str;
		}
	}

	update();
}


void SliderWithDescPoint::setPoints(const QMap<int, QString> &strs)
{
	m_strs = strs;
	this->update();
}


void SliderWithDescPoint::mousePressEvent(QMouseEvent *ev)
{
	int curValue = this->value();
	this->blockSignals(true);
	QSlider::mousePressEvent(ev);
	bool bSliderDown = this->isSliderDown();
	this->setValue(curValue);
	this->blockSignals(false);

	//如果不是在滑动条上，则重新调整位置
	if (!bSliderDown)
	{
		int width = this->width();
		int rang = maximum() - minimum();
		int pressPos = qint64(ev->pos().x()) * rang / width + minimum();
		if (pressPos != curValue)
		{
			this->setValue(pressPos);
		}
	}
}

void SliderWithDescPoint::mouseMoveEvent(QMouseEvent *ev)
{
	QSlider::mouseMoveEvent(ev);
	if (m_strs.size() <= 0)
		return;
	if (this->isSliderDown())
		return;

	int rang = qMax(maximum() - minimum(), 1);
	//转换成value
	int xPos = ev->x();
	int minXPos = xPos - SLD_POINT_ITEM_W;
	int value = qint64(minXPos)*rang / width() + minimum();

	//找到与value相等或更小的item
	auto findPos = m_strs.lowerBound(value);
	if (findPos != m_strs.begin() && findPos.key() != value)
	{
		findPos--;
	}

	//找出
	QStringList tips;
	int totalWidth = width() - SLD_POINT_ITEM_W;
	for (; findPos != m_strs.end(); findPos++)
	{
		//计算item区域包含xpos;
		int ivalue = (findPos.key() - minimum());
		int drawStartPos = int(ivalue*totalWidth / (float)rang + 0.5);
		int drawEndPos = drawStartPos + SLD_POINT_ITEM_W;
		if (xPos >= drawStartPos && xPos <= drawEndPos)
		{
			tips += findPos.value();
			continue;
		}
		//鼠标还在块之后，继续往后找
		if (xPos > drawEndPos)
		{
			continue;
		}
		break;
	}

	if (tips.size()>0)
	{
		QString txt = tips.join("\n");
		QToolTip::showText(ev->globalPos(), txt);
	}
	else
	{
		QToolTip::hideText();
	}
}


void SliderWithDescPoint::paintEvent(QPaintEvent *ev)
{
	QSlider::paintEvent(ev);

	QPainter p(this);
	int rang = qMax(maximum() - minimum(), 1);
	//绘制Value区域
	int lWidth = width() * (value()-minimum()) / rang;
	//绘制点信息
	int totalWidth = width() - SLD_POINT_ITEM_W;
	for (QMap<int, QString>::iterator pos = m_strs.begin(); pos != m_strs.end(); pos++)
	{
		int ivalue = (pos.key()-minimum());
		int drawStartPos = int(ivalue*totalWidth/(float)rang + 0.5);
		p.fillRect(drawStartPos, 0, SLD_POINT_ITEM_W, height(), QColor(255, 255, 255));
	}
}
