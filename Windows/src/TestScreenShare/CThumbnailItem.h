#ifndef CThumbnailItem_h
#define CThumbnailItem_h

#include "ui_CThumbnailItem.h"

class CThumbnailItem : public QWidget
{
	Q_OBJECT
	
public:
	CThumbnailItem(QWidget *parent = Q_NULLPTR);
	~CThumbnailItem();

	void setInfo(const CRScreenCaptureSourceInfo& info);
	const CRScreenCaptureSourceInfo &getInfo() const { return m_info; }
	void updateStyle(bool bSelected);

protected:
	void paintEvent(QPaintEvent *event) override;
	bool eventFilter(QObject *watched, QEvent *event) override;

private:
	Ui::CThumbnailItem ui;
	CRScreenCaptureSourceInfo m_info;
};

#endif