#ifndef SCREENMARKVIEW_H
#define SCREENMARKVIEW_H
struct MarkData
{
	QString userid;
	QString markid;
	unsigned char penType;
	int penWidth;
	QString color;
	QList<quint32> points;

	QVariant toJson()
	{
		QVariantMap varMap;
		varMap["userid"] = userid;
		varMap["markid"] = markid;
		varMap["penType"] = penType;
		varMap["penWidth"] = penWidth;
		varMap["color"] = color;
		QVariantList varPosList;
		for (auto &pos : points)
		{
			varPosList.append(pos);
		}
		varMap["points"] = varPosList;
		return varMap;
	}
	void fromJson(const QVariant &json)
	{
		QVariantMap varMap = json.toMap();
		if (varMap.size() <= 0)
		{
			return;
		}
		userid = varMap["userid"].toString();
		markid = varMap["markid"].toString();
		penType = varMap["penType"].toInt();
		penWidth = varMap["penWidth"].toInt();
		color = varMap["color"].toString();
		points.clear();
		QVariantList varPosList = varMap["points"].toList();

		for (auto &varPos : varPosList)
		{
			points.append(varPos.toUInt());
		}
	}
};
typedef QList<MarkData>  MarkDataSeq;

class ScreenMarkView : public QWidget, public CRVideoSDKMeetingCallBack
{
	Q_OBJECT

public:
	ScreenMarkView(bool bForSharer, QWidget* parent);
	~ScreenMarkView();


	enum PenStyle { JS_PEN = 1, JS_NULL};

	struct MarkMouseInfo//图形控件使用
	{
		QString					_userid;
		QString					_id;
		int						_penWidth;
		QColor					_color;
		PenStyle				_penStyle;
		std::vector<QPoint>		_markUserData;

		virtual MarkMouseInfo* clone()
		{
			MarkMouseInfo *p = new MarkMouseInfo;
			*p = *this;
			return p;
		}
		inline MarkMouseInfo &operator=(const MarkMouseInfo &c)
		{
			if (this != &c)
			{
				_userid = c._userid;
				_id = c._id;
				_penWidth = c._penWidth;
				_color = c._color;
				_penStyle = c._penStyle;
				_markUserData = c._markUserData;
			}
			return *this;
		}
	};
	void SetScreenPixmap(const QImage &image);
	QImage GetScreenPixmap() { return m_OldBkPixmap; }
	int  GetMarketCount() { return m_curMarks.size(); }

	float getScaledValue(int v);
	QPointF getScaledValue(const QPoint& v);
	QVector<QPointF> getScaledValue(const QVector<QPoint> &pts);
	QPointF getUnScaledValue(const QPoint &v);

public:
// 	void notifyInitScreenMarkData(const char* jsonMarkDats) override
// 	{
// 		MarkDataSeq markDats;
// 		QVariantList varList = QJsonDocument::fromJson(jsonMarkDats).toVariant().toList();
// 		for (auto &var : varList)
// 		{
// 			MarkData data;
// 			data.fromJson(var);
// 			markDats.append(data);
// 		}
// 		notifyAllMarkData(markDats);
// 	}
	void notifySendScreenMarkData(const char* jsonMarkDat) override
	{
		QVariant var = QJsonDocument::fromJson(jsonMarkDat).toVariant();
		MarkData data;
		data.fromJson(var);
		notifyMarkData(data);
	}
	void notifyDelScreenMarkData(const char* jsonDelMarkId, const char* oprUserID) override
	{
		QStringList markIdList = QJsonDocument::fromJson(jsonDelMarkId).toVariant().toStringList();
		notifyDelMarkData(markIdList);
	}
	void notifyClearScreenMarks() override
	{
		notifyRemoveAllMark();
	}

protected:
	void notifyAllMarkData(const MarkDataSeq &);
	void notifyMarkData(const MarkData &mkdat);
	void notifyDelMarkData(const QStringList& markids);
	void notifyRemoveAllMark();

protected:
	virtual void mousePressEvent(QMouseEvent * event);
	virtual void mouseMoveEvent(QMouseEvent *event);
	virtual void mouseReleaseEvent(QMouseEvent *event);
	virtual void paintEvent(QPaintEvent *event);
	virtual void resizeEvent(QResizeEvent *event);

	void RedrawAll();
	void destroyAllMarks();
	void drawMarkData(QPainter &painter, const MarkMouseInfo &MarkInfo);
	void drawMarkData(const MarkMouseInfo &MarkInfo);
	void drawLastLine(const MarkMouseInfo &MarkInfo);
	void makePenPath(QPainterPath &path, const std::vector<QPoint>& marks);
	void appendMark(MarkMouseInfo *info);
	void delMyIDMark(MarkMouseInfo *info);
	void delIDMark(const QString &id);

	MarkMouseInfo* MarkData2Local(const MarkData &mkdat);
	void Local2MarkData(const MarkMouseInfo &info, MarkData &mkdat);

	QString ColorToHex(const QColor &clr);
	QColor HexToColor(const QString &str);
	QRect RectFrom2Point(const QPoint &pt1, const QPoint &pt2);

public:
	QImage					m_OldBkPixmap;
	QImage					m_BkPixmap;
	bool					m_bMarking;

	MarkMouseInfo			m_drawMark;
	QVector<MarkMouseInfo*>	m_allMarks;
	QVector<MarkMouseInfo*>	m_curMarks;

	PenStyle				m_penType;
	QColor					m_color;
	int						m_penWidth;

	float	m_scale[2];	//x,y
};

#endif //SCREENMARKVIEW_H