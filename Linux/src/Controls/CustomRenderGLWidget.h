#ifndef CUSTOMRENDERGLWIDGET_H
#define CUSTOMRENDERGLWIDGET_H

#include "CRFPSStatistics.h"

class CustomRenderGLWidget : public QOpenGLWidget, public QOpenGLFunctions, public CRCustomRenderHandler
{
    Q_OBJECT
public:
	CustomRenderGLWidget(QWidget *parent, CRVSDK_STREAM_VIEWTYPE viewType);
	~CustomRenderGLWidget();

	CRVideoFrame getFrame();
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
	void onRenderFrameDat(const CRVideoFrame &frm) override;
	void hideEvent(QHideEvent* event) override;
	void showEvent(QShowEvent* event) override;

protected:
    void initializeGL() Q_DECL_OVERRIDE;
    void paintGL() Q_DECL_OVERRIDE;
	void releaseGL();
	void clearColor(const QColor &color);
	void fillLastColumnDate(CRVideoFrame &frm);
	bool drawYuv420p(uint8_t *yuvDat[3], int yuvLineSize[3], const QSize &frmSize, const QRect &drawRt = QRect(-1, -1, -1, -1));

private:
	void updateRenderHandler();

private:
	bool				m_bRenderEnable{ true };
	bool				m_bLocMirror{ false };
	CRVideoFrame		m_frame;
	QMutex				m_frameLock;

	QOpenGLShaderProgram* m_programYUV420p{ nullptr };
	QOpenGLTexture* m_textureY{ nullptr };
	QOpenGLTexture* m_textureU{ nullptr };
	QOpenGLTexture* m_textureV{ nullptr };
	//CRFPSStatistics	m_recvFps;
	//CRFPSStatistics	m_drawFps;
};

#endif // CUSTOMRENDERGLWIDGET_H
