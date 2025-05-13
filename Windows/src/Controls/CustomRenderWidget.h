#ifndef CUSTOMRENDERWIDGET_H
#define CUSTOMRENDERWIDGET_H

#include "CRFPSStatistics.h"

class CustomRenderWidget : public QWidget, public CRCustomRenderHandler
{
    Q_OBJECT
public:
	CustomRenderWidget(QWidget *parent, CRVSDK_STREAM_VIEWTYPE viewType);
	~CustomRenderWidget();

	void setVideoID(const CRUserVideoID &id, CRVSDK_VSTEAMLV_TYPE lv = CRVSDK_VSTP_LV0);

	CRVideoFrame getFrame();
	QSize getFrameSize();
	int64_t getFrameTimestamp();
	
	//清除缓存的图片
	void clearFrame();

	//本地图像镜像
	void setLocMirror(bool bMirror);
	bool getLocMirror() { return m_bLocMirror; }

	//是否启用render
	void setRenderEnabled(bool bEnable);

signals:
	void s_recvFrame(qint64 ts);

protected:
	void onRenderFrameDat(const CRVideoFrame &frm, const CRUserVideoID &realVideoID) override;
	void paintEvent(QPaintEvent *event) override;
	void hideEvent(QHideEvent* event) override;
	void showEvent(QShowEvent* event) override;
	void setDefaultBackground(const QColor &color);

private:
	void updateRenderHandler();

private:
	bool				m_bRenderEnable{ true };
	bool				m_bLocMirror{ false };
	CRVideoFrame		m_frame;
	QMutex				m_frameLock;
	QColor				m_defBkColor;

	//CRFPSStatistics	m_recvFps;
	//CRFPSStatistics	m_drawFps;
};

class CustomVideoView : public CustomRenderWidget
{
public:
	CustomVideoView(QWidget *parent) : CustomRenderWidget(parent, CRVSDK_VIEWTP_VIDEO) {}
};

#endif // CUSTOMRENDERWIDGET_H
