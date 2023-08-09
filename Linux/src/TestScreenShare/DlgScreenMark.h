#ifndef DLGSCREENMARK_H
#define DLGSCREENMARK_H

class ScreenMarkView;
class DlgScreenMark : public QDialog
{
	Q_OBJECT
public:
    DlgScreenMark(bool bForSharer, QWidget *parent = 0, Qt::WindowFlags flags = Qt::Window);
	~DlgScreenMark();
	void SetScreenPixmap(const CRVideoFrame &frame);
	bool HasScreenPixmap();

protected:
	virtual void resizeEvent(QResizeEvent *event);
	virtual void paintEvent(QPaintEvent *event);

	void updateView();

protected slots:
	void slot_clearMarkClicked();

public:
	QVBoxLayout *m_pVLayout;
	QVBoxLayout *m_pVScrollLayout;
	ScreenMarkView *m_markView;
	QPushButton *m_clearBtn;
};


#endif //DLGSCREENMARK_H
