#ifndef CUSTOMRENDERWIDGET_H
#define CUSTOMRENDERWIDGET_H

class CustomRenderWidget : public QWidget, public CRCustomRenderHandler
{
    Q_OBJECT
public:
	CustomRenderWidget(QWidget *parent, CRVSDK_STREAM_VIEWTYPE viewType);
	~CustomRenderWidget();

	CRVideoFrame getFrame();
	int64_t getFrameTimestamp();
	
	//清除缓存的图片
	void clearFrame();

	//本地图像镜像
	void setLocMirror(bool bMirror);
	bool getLocMirror() { return m_bLocMirror; }

	//是否启用render
	void enabledRender(bool bEnale);
protected:
	void onRenderFrameDat(const CRVideoFrame &frm) override;

protected:
	void paintEvent(QPaintEvent *event) override;

signals:
	void s_recvFrame(qint64 timeStamp);

private:
	bool				m_bLocMirror;
	bool				m_enabledRender;
	CRVideoFrame		m_frame;
	QMutex				m_frameLock;

};

#endif // CUSTOMRENDERWIDGET_H
