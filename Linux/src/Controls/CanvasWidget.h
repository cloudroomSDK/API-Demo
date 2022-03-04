#ifndef CANVASWIDGET_H
#define CANVASWIDGET_H

//视频引擎渲染对象
class VideoCanvasWidget : public QWidget, public CRCanvas
{
    Q_OBJECT
public:
	VideoCanvasWidget(QWidget *parent = Q_NULLPTR);
	~VideoCanvasWidget();

protected:
	void paintEvent(QPaintEvent *event);
};

#endif // CANVASWIDGET_H
