#ifndef SLIDERWITHDESCPOINT_H
#define SLIDERWITHDESCPOINT_H


class SliderWithDescPoint : public QSlider
{
	Q_OBJECT
public:
	SliderWithDescPoint(QWidget *parent);

	void setPoint(int value, const QString &str);
	void setPoints(const QMap<int, QString> &strs);
	const QMap<int, QString>& getPoints() { return m_strs; }

private:
	virtual void mouseMoveEvent(QMouseEvent *ev);
	virtual void mousePressEvent(QMouseEvent *ev);
	virtual void paintEvent(QPaintEvent *ev);

protected:
	QMap<int, QString>	m_strs;
};

#endif // SLIDERWITHDESCPOINT_H
