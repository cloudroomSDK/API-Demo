#include "stdafx.h"
#include "ScreenMarkView.h"
//#include "BoardPublic.h"
#include "maindialog.h"

ScreenMarkView::ScreenMarkView(bool bForSharer, QWidget* parent) : QWidget(parent)
{
	this->setObjectName(QString::fromUtf8("ScreenMarkView"));
	this->setFocusPolicy(Qt::NoFocus);
	this->setAttribute(Qt::WA_OpaquePaintEvent);

	m_bMarking = false;
	m_penType = JS_PEN;
	m_penWidth = 2;
	m_color = bForSharer ? QColor(255, 0, 0) : QColor(57, 171, 251);
	m_scale[0] = m_scale[1] = 1.00;

	SetScreenPixmap(QImage());

	g_sdkMain->getSDKMeeting().AddCallBack(this);
}

ScreenMarkView::~ScreenMarkView()
{
	destroyAllMarks();
    g_sdkMain->getSDKMeeting().RmCallBack(this);
}

float ScreenMarkView::getScaledValue(int v)
{
	return v*m_scale[0];
}

QPointF ScreenMarkView::getScaledValue(const QPoint& v)
{
	QPointF r(v.x()*m_scale[0], v.y()*m_scale[1]);
	return r;
}

QPointF ScreenMarkView::getUnScaledValue(const QPoint &v)
{
	QPointF r(v.x()/m_scale[0], v.y()/m_scale[1]);
	return r;
}

QVector<QPointF> ScreenMarkView::getScaledValue(const QVector<QPoint> &pts)
{
	QVector<QPointF> rslt;
	for (int i = 0; i < pts.size(); i++)
	{
		rslt.push_back(ScreenMarkView::getScaledValue(pts[i]));
	}
	return rslt;
}

void ScreenMarkView::paintEvent(QPaintEvent *event)
{
	QPainter painter(this);
	if ( m_BkPixmap.isNull() )
	{
		m_BkPixmap = m_OldBkPixmap.scaled(this->size(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
		//重绘标注
		for (int i = 0; i < m_allMarks.size(); i++)
		{
			drawMarkData(*m_allMarks[i]);
		}
		drawMarkData(m_drawMark);
	}

	const QRect &rt = event->rect();
	painter.drawImage(rt, m_BkPixmap, rt);
}

void ScreenMarkView::notifyAllMarkData(const MarkDataSeq &seq)
{
	destroyAllMarks();

	//图片重新绘制
	m_BkPixmap = m_OldBkPixmap;
	for (unsigned int i = 0; i < seq.size(); i++)
	{
		MarkMouseInfo *MarkInfo = MarkData2Local(seq[i]);
		appendMark(MarkInfo);
	}
	this->update();
}

void ScreenMarkView::notifyMarkData(const MarkData &mkdat)
{
	MarkMouseInfo *MarkInfo = MarkData2Local(mkdat);

	delMyIDMark(MarkInfo);
	appendMark(MarkInfo);
	this->RedrawAll();
}

void ScreenMarkView::notifyDelMarkData(const QStringList& markids)
{
	for (auto &id : markids)
	{
		delIDMark(id);
	}
	this->RedrawAll();
}

void ScreenMarkView::notifyRemoveAllMark()
{
	this->update();
	destroyAllMarks();
	m_BkPixmap = QImage();
}

void ScreenMarkView::SetScreenPixmap(const QImage &image)
{
	m_OldBkPixmap = image;
	RedrawAll();
}

void ScreenMarkView::resizeEvent(QResizeEvent *event)
{
	QWidget::resizeEvent(event);
	RedrawAll();
}

void ScreenMarkView::RedrawAll()
{
	m_BkPixmap = QImage();
	if ( !m_OldBkPixmap.isNull() )
	{
		m_BkPixmap = m_OldBkPixmap.scaled(this->size(), Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
		m_scale[0] = m_BkPixmap.width() / float(m_OldBkPixmap.width());
		m_scale[1] = m_BkPixmap.height() / float(m_OldBkPixmap.height());
		//重绘标注
		for (int i = 0; i < m_allMarks.size(); i++)
		{
			drawMarkData(*m_allMarks[i]);
		}
		drawMarkData(m_drawMark);
	}

	this->update();
}

void ScreenMarkView::drawLastLine(const MarkMouseInfo &MarkInfo)
{
	const int pointCount = MarkInfo._markUserData.size();
	if(pointCount < 2)
		return;
	//非手笔类不作处理
	if( MarkInfo._penStyle!=JS_PEN )
		return;

	QPainter painter(&m_BkPixmap);
	painter.setRenderHint(QPainter::Antialiasing);
	QPen tmpPen;
	tmpPen.setWidthF(getScaledValue(MarkInfo._penWidth));
	tmpPen.setColor(MarkInfo._color);
	tmpPen.setStyle(Qt::SolidLine);
	tmpPen.setCapStyle(Qt::RoundCap);
	tmpPen.setJoinStyle(Qt::RoundJoin);
	
	painter.setPen(tmpPen);

	//画最后一条线断
	const QPoint &pos1 = MarkInfo._markUserData[pointCount-2];
	const QPoint &pos2 = MarkInfo._markUserData[pointCount-1];
	painter.drawLine(getScaledValue(pos1), getScaledValue(pos2));
}

void ScreenMarkView::drawMarkData(QPainter &painter, const MarkMouseInfo &MarkInfo)
{
	if ( MarkInfo._markUserData.size()<=1 )
		return;
	//非手笔类不作处理
	if (MarkInfo._penStyle >= JS_NULL )
		return;

	painter.setRenderHint(QPainter::Antialiasing);
	
	QPen tmpPen;
	tmpPen.setWidthF(getScaledValue(MarkInfo._penWidth));
	tmpPen.setColor(MarkInfo._color);
	tmpPen.setStyle(Qt::SolidLine);
	tmpPen.setCapStyle(Qt::RoundCap);
	tmpPen.setJoinStyle(Qt::RoundJoin);
	
	painter.setPen(tmpPen);

	switch(MarkInfo._penStyle)
	{
	case JS_PEN: 
		{
			QPainterPath path;
			makePenPath(path, MarkInfo._markUserData);
			painter.drawPath(path);
		}
		break;

	default: return;
	}
}

void ScreenMarkView::drawMarkData(const MarkMouseInfo &MarkInfo)
{
	QPainter painter(&m_BkPixmap);
	drawMarkData(painter, MarkInfo);
}

void ScreenMarkView::mousePressEvent(QMouseEvent * event)
{
	if(Qt::LeftButton == event->button())
	{
		m_bMarking = true;
		m_drawMark._userid = MainDialog::getMyUserID().constData();
		m_drawMark._color = m_color;
		m_drawMark._penStyle = m_penType;
		m_drawMark._penWidth = m_penWidth;
		m_drawMark._markUserData.clear();
		m_drawMark._markUserData.push_back(getUnScaledValue(event->pos()).toPoint());
	}
}

void ScreenMarkView::mouseMoveEvent(QMouseEvent *event)
{
	if(m_bMarking)
	{
		QPoint curPos = event->pos();
		if (curPos.x() < 0)
		{
			curPos.setX(0); 
		}
		if (curPos.y() < 0)
		{
			curPos.setY(0);
		}
		if (curPos.x() > this->width())
		{
			curPos.setX(this->width());
		}
		if (curPos.y() > this->height())
		{
			curPos.setY(this->height());
		}
		m_drawMark._markUserData.push_back(getUnScaledValue(curPos).toPoint());
		drawLastLine(m_drawMark);

		int pointCount = m_drawMark._markUserData.size();

		QRect rt = RectFrom2Point(getScaledValue(m_drawMark._markUserData[pointCount - 2]).toPoint(), getScaledValue(m_drawMark._markUserData[pointCount - 1]).toPoint());
		rt.adjust(-10, -10, 10, 10); //画线宽度,箭头宽度
		this->update(rt);
	}
}

void ScreenMarkView::mouseReleaseEvent(QMouseEvent *event)
{
	if(m_bMarking)
	{
		m_bMarking = false;

		if ( m_drawMark._markUserData.size()>1 )
		{
			MarkData mkDat;
			m_drawMark._id = makeUUID();
			Local2MarkData(m_drawMark, mkDat);
			QByteArray jsonData = QJsonDocument::fromVariant(mkDat.toJson()).toJson(QJsonDocument::Compact);
			g_sdkMain->getSDKMeeting().sendScreenMarkData(jsonData.constData());
		
			MarkMouseInfo *info = new MarkMouseInfo;
			*info = m_drawMark;
			appendMark(info);
		}
		m_drawMark._markUserData.clear();

		//整个重绘一次，因为手绘时，是按线段来绘制的。
		this->RedrawAll();
	}
}

ScreenMarkView::MarkMouseInfo* ScreenMarkView::MarkData2Local(const MarkData &mkdat)
{
	MarkMouseInfo *info = new MarkMouseInfo;
	info->_penWidth = mkdat.penWidth;
	info->_color = HexToColor(mkdat.color);
	info->_penStyle = (PenStyle)mkdat.penType;
	info->_userid = mkdat.userid;
	info->_id = mkdat.markid;
	for (auto &pos : mkdat.points)
	{
		qint16 x = pos >> 16 & 0xFFFF;
		qint16 y = pos & 0xFFFF;
		info->_markUserData.push_back(QPoint(x, y));
	}
	return info;
}

void ScreenMarkView::Local2MarkData(const MarkMouseInfo &info, MarkData &mkdat)
{
	mkdat.userid = info._userid;
	mkdat.markid = info._id;
	mkdat.penType = info._penStyle;
	mkdat.penWidth = info._penWidth;
	mkdat.color = ColorToHex(info._color);
	for (auto &data : info._markUserData)
	{
		int pos = (data.x() << 16) | data.y();
		mkdat.points.append(pos);
	}
}

void ScreenMarkView::makePenPath(QPainterPath &path, const std::vector<QPoint>& marks)
{
	path.moveTo(getScaledValue(marks[0]));
	if (marks.size() <= 2)
	{
		path.lineTo(getScaledValue(marks[1]) + QPointF(0, 0.1));
	}
	else
	{
		for(quint32 i=2; i<marks.size()-1; i++)
		{
			QPointF pt = getScaledValue(marks[i]);
			QPointF ptNext = getScaledValue(marks[i + 1]);
			QPointF endP((pt.x() + ptNext.x())/2.0, (pt.y() + ptNext.y())/2.0);
			path.quadTo(pt, endP);
		}
		path.lineTo(getScaledValue(marks[marks.size() - 1]));
	}
}

void ScreenMarkView::appendMark(MarkMouseInfo *info)
{
	m_allMarks.push_back(info);
}

void ScreenMarkView::delIDMark(const QString &id)
{
	for (auto iter = m_allMarks.begin(); iter != m_allMarks.end(); iter++)
	{
		if ((*iter)->_id == id)
		{
			delete *iter;
			m_allMarks.erase(iter);
			break;
		}
	}
}

void ScreenMarkView::delMyIDMark(MarkMouseInfo *info)
{
	if (info->_userid != MainDialog::getMyUserID().constData())
	{
		return;
	}
	delIDMark(info->_id);
}

void ScreenMarkView::destroyAllMarks()
{
	//清空内存
	for (int i = 0; i < m_allMarks.size(); i++)
	{
		MarkMouseInfo *info = m_allMarks[i];
		delete info;
		info = NULL;
	}
	m_allMarks.clear();
}

QString ScreenMarkView::ColorToHex(const QColor &clr)
{
	int r = clr.red();
	int g = clr.green();
	int b = clr.blue();
	return QString("#%1%2%3").arg(r, 2, 16, QChar('0'))
		.arg(g, 2, 16, QChar('0'))
		.arg(b, 2, 16, QChar('0')).toUpper();
}

QColor ScreenMarkView::HexToColor(const QString &str)
{
	QString hexColor = str;
	int alpha = 255;
	if (hexColor.size() > 7)
	{
		QString hexAlpha = hexColor.mid(7, 2);
		bool ok;
		alpha = hexAlpha.toInt(&ok, 16);
		if (!ok)
		{
			alpha = 255;
		}
		hexColor.remove(7, 2);
	}

	QColor color;
	color.setNamedColor(hexColor);
	color.setAlpha(alpha);
	return color;
}

QRect ScreenMarkView::RectFrom2Point(const QPoint &pt1, const QPoint &pt2)
{
	QPoint topLeft(qMin(pt1.x(), pt2.x()), qMin(pt1.y(), pt2.y()));
	QPoint rBottom(qMax(pt1.x(), pt2.x()), qMax(pt1.y(), pt2.y()));
	return	QRect(topLeft, rBottom);
}
