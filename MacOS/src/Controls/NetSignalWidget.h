#ifndef NETSIGNALWIDGET_H
#define NETSIGNALWIDGET_H


class NetSignalWidget : public QWidget
{
    Q_OBJECT

public:
	NetSignalWidget(QWidget *parent);
	~NetSignalWidget();

	//强度级别0-10
	void setLevel(int level); 
	int  getLevel() { return m_level; }

protected:
	virtual void paintEvent(QPaintEvent *event);

private:
	QImage m_imgMin;
	QImage m_imgMax;
	int     m_level;

};

#endif // NETSIGNALWIDGET_H
