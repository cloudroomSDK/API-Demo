#include "stdafx.h"
#include "CustomRenderGLWidget.h"
#include "KeepAspectRatioDrawer.h"
#include "maindialog.h"

const int LOC_VERTEXIN = 0;
const int LOC_TEXTUREIN_Y = 1;
const int LOC_TEXTUREIN_U = 2;
CustomRenderGLWidget::CustomRenderGLWidget(QWidget *parent, CRVSDK_STREAM_VIEWTYPE viewType) : QOpenGLWidget(NULL), CRCustomRenderHandler(viewType)
{
	this->setAttribute(Qt::WA_OpaquePaintEvent);
	this->setAttribute(Qt::WA_NoSystemBackground);
	m_bLocMirror = false;
    m_textureU = m_textureV = m_textureY = nullptr;
    m_programYUV420p = nullptr;
	connect(this, SIGNAL(s_recvFrame(qint64)), this, SLOT(update()));
}

CustomRenderGLWidget::~CustomRenderGLWidget()
{
	releaseGL();
	g_sdkMain->getSDKMeeting().rmCustomRender(this);
}

CRVideoFrame CustomRenderGLWidget::getFrame()
{
	QMutexLocker locker(&m_frameLock);
	return m_frame;
}

int64_t CustomRenderGLWidget::getFrameTimestamp()
{
	QMutexLocker locker(&m_frameLock);
	return m_frame.getPts();
}

void CustomRenderGLWidget::clearFrame()
{
	{
		QMutexLocker locker(&m_frameLock);
		m_frame.clear();
	}
	update();
}

void CustomRenderGLWidget::setLocMirror(bool bMirror)
{
	m_bLocMirror = bMirror;
	update();
}

void CustomRenderGLWidget::setRenderEnabled(bool bEnable)
{
	m_bRenderEnable = bEnable;
	updateRenderHandler();
	if (!bEnable)
	{
		clearFrame();
		update();
	}
}

void CustomRenderGLWidget::updateRenderHandler()
{
	if (m_bRenderEnable && this->isVisible())
	{
		g_sdkMain->getSDKMeeting().addCustomRender(this);
	}
	else
	{
		g_sdkMain->getSDKMeeting().rmCustomRender(this);
	}
}

void CustomRenderGLWidget::onRenderFrameDat(const CRVideoFrame &frm)
{
	//m_recvFps.AddCount();
	//qDebug("recv fps:%d", int(m_recvFps.GetFPS()));
	{
		QMutexLocker locker(&m_frameLock);
		m_frame = frm;
	}
	emit s_recvFrame(frm.getPts());
}

void CustomRenderGLWidget::hideEvent(QHideEvent* event)
{
	QWidget::hideEvent(event);
	updateRenderHandler();
}

void CustomRenderGLWidget::showEvent(QShowEvent* event)
{
	QWidget::showEvent(event);
	updateRenderHandler();
}

void CustomRenderGLWidget::initializeGL()
{
    QOpenGLWidget::initializeGL();
    initializeOpenGLFunctions();
    if (!context()->isOpenGLES())
    {
        QMessageBox::information(g_mainDialog, tr("提示"), tr("启用OpenGL ES2.0失败！"));
        return;
    }

	if (m_programYUV420p)
	{
		releaseGL();
    }

	glEnable(GL_DEPTH_TEST);
	bool bRslt = false;

	m_programYUV420p = new QOpenGLShaderProgram(this);
 	bRslt = m_programYUV420p->addShaderFromSourceFile(QOpenGLShader::Vertex, ":/Resources/vertex.vsh");
	bRslt = m_programYUV420p->addShaderFromSourceFile(QOpenGLShader::Fragment, ":/Resources/fragment.fsh");
	m_programYUV420p->bindAttributeLocation("vertexIn", LOC_VERTEXIN);
	m_programYUV420p->bindAttributeLocation("textureYIn", LOC_TEXTUREIN_Y);
	m_programYUV420p->bindAttributeLocation("textureUIn", LOC_TEXTUREIN_U);
	m_programYUV420p->link();
	m_textureY = new QOpenGLTexture(QOpenGLTexture::Target2D);
	m_textureU = new QOpenGLTexture(QOpenGLTexture::Target2D);
	m_textureV = new QOpenGLTexture(QOpenGLTexture::Target2D);
	bRslt = m_textureY->create();
	bRslt = m_textureU->create();
	bRslt = m_textureV->create();
	m_textureY->setFormat(QOpenGLTexture::R8_UNorm);
	m_textureY->setMinMagFilters(QOpenGLTexture::Linear, QOpenGLTexture::Linear);
	m_textureY->setWrapMode(QOpenGLTexture::ClampToEdge);
	m_textureU->setFormat(QOpenGLTexture::R8_UNorm);
	m_textureU->setMinMagFilters(QOpenGLTexture::Linear, QOpenGLTexture::Linear);
	m_textureU->setWrapMode(QOpenGLTexture::ClampToEdge);
	m_textureV->setFormat(QOpenGLTexture::R8_UNorm);
	m_textureV->setMinMagFilters(QOpenGLTexture::Linear, QOpenGLTexture::Linear);
	m_textureV->setWrapMode(QOpenGLTexture::ClampToEdge);
}

void CustomRenderGLWidget::releaseGL()
{
	makeCurrent();
	if (m_programYUV420p)
	{
		delete m_programYUV420p;
		m_programYUV420p = nullptr;
	}
	// 释放纹理
	if (m_textureY)
	{
		m_textureY->destroy();
		delete m_textureY;
		m_textureY = nullptr;
	}
	if (m_textureU)
	{
		m_textureU->destroy();
		delete m_textureU;
		m_textureU = nullptr;
	}
	if (m_textureV)
	{
		m_textureV->destroy();
		delete m_textureV;
		m_textureV = nullptr;
	}
	doneCurrent();
}

void CustomRenderGLWidget::paintGL()
{
	if (!m_programYUV420p)
	{
		return;
	}
	clearColor(Qt::black);

	QPainter p(this);
	if (this->width() <= 16 && this->height() <= 16)
	{
		return;
	}

	p.setRenderHint(QPainter::SmoothPixmapTransform);
	p.beginNativePainting();
	CRVideoFrame frm = getFrame();
	QSize frmSize(frm.getWidth(), frm.getHeight());
	if (!frm.getFrameSize().isEmpty())
	{
		//确保为YUV420P格式（格式、尺寸相同时内部无开消）
		if (g_sdkMain->videoFrameCover(frm, CRVSDK_VFMT_YUV420P, frmSize.width(), frmSize.height()))
		{
			QRect drawRect = KeepAspectRatioDrawer::getContentRect(this, frmSize, CRVSDK_RENDERMD_FIT);
			fillLastColumnDate(frm);

			uint8_t *yuvDat[3];
			int yuvLineSize[3];
			frm.getRawDatPtr(yuvDat, yuvLineSize, 3);
			drawYuv420p(yuvDat, yuvLineSize, frmSize, drawRect);
		}
	}

	p.endNativePainting();

	//m_drawFps.AddCount();
	//qDebug("draw fps:%d", int(m_drawFps.GetFPS()));
}

void CustomRenderGLWidget::clearColor(const QColor &color)
{
	glClearColor(color.redF(), color.greenF(), color.blueF(), 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void CustomRenderGLWidget::fillLastColumnDate(CRVideoFrame &frm)
{
	//这里yuv三个平面，行为32字节对齐，当图像不是32倍数时，每行后面会有lineSize - width个无效数据；
	//uv分量在openg渲染时，最右边一列可能是Linear算法原因，会读到width后一列无效数据，导至图像最右则有一条绿色线条；
	//在此，将最右列数据复制到后一列上
	uint8_t *yuvDat[3];
	int yuvLineSize[3];
	frm.getRawDatPtr(yuvDat, yuvLineSize, 3);

	int width = frm.getWidth();
	int height = frm.getHeight();
	if (width < yuvLineSize[0])
	{
		const int lineSize = yuvLineSize[0];
		uint8_t *p = yuvDat[0] + width - 1;
		uint8_t *pEnd = p + height * lineSize;
		for (; p < pEnd; p += lineSize )
		{
			p[1] = p[0];
		}
	}

	width /= 2;
	height /= 2;
	if (width < yuvLineSize[1])
	{
		const int lineSize = yuvLineSize[1];
		uint8_t *p = yuvDat[1] + width - 1;
		uint8_t *pEnd = p + height * lineSize;
		for (; p < pEnd; p += lineSize)
		{
			p[1] = p[0];
		}
	}
	if (width < yuvLineSize[2])
	{
		const int lineSize = yuvLineSize[1];
		uint8_t *p = yuvDat[2] + width - 1;
		uint8_t *pEnd = p + height * lineSize;
		for (; p < pEnd; p += lineSize)
		{
			p[1] = p[0];
		}
	}
}


bool CustomRenderGLWidget::drawYuv420p(uint8_t *yuvDat[3], int yuvLineSize[3], const QSize &frmSize, const QRect &drawRt)
{
	QRect rt = !drawRt.isValid() ? rect() : drawRt;
	glViewport(rt.left(), rt.top(), rt.width(), rt.height());

	m_programYUV420p->bind();
	//视图矩阵
	static const GLfloat vertexVertices[] = {
		-1.0f, -1.0f,	// Bottom Left
		1.0f, -1.0f,	//Bottom Right
		-1.0f, 1.0f,	//Top Left  
		1.0f, 1.0f,		//Top Right
	};
	static const GLfloat vertexVertices_mirror[] = {
		1.0f, -1.0f,	//Bottom Right
		-1.0f, -1.0f,	//Bottom Left
		1.0f, 1.0f,		//Top Right
		-1.0f, 1.0f,	//Top Left  
	};
	m_programYUV420p->enableAttributeArray(LOC_VERTEXIN);
	m_programYUV420p->setAttributeArray(LOC_VERTEXIN, GL_FLOAT, m_bLocMirror ? vertexVertices_mirror:vertexVertices, 2);

	//y矩阵
	float validRight_y = (float)frmSize.width() / yuvLineSize[0];
	const GLfloat textureVertices_y[] = {
		0.0f, 1.0f,			//Bottom Left 
		validRight_y, 1.0f,	//Bottom Right
		0.0f, 0.0f,			//Top Left 
		validRight_y, 0.0f,	//Top Right 
	};
	m_programYUV420p->enableAttributeArray(LOC_TEXTUREIN_Y);
	m_programYUV420p->setAttributeArray(LOC_TEXTUREIN_Y, GL_FLOAT, textureVertices_y, 2);

	//uv矩阵
	float validRight_uv = (float)(frmSize.width() / 2) / yuvLineSize[1];
	const GLfloat textureVertices_u[] = {
		0.0f, 1.0f,				//Bottom Left 
		validRight_uv, 1.0f,	//Bottom Right
		0.0f, 0.0f,				//Top Left  
		validRight_uv, 0.0f,	//Top Right
	};
	m_programYUV420p->enableAttributeArray(LOC_TEXTUREIN_U);
	m_programYUV420p->setAttributeArray(LOC_TEXTUREIN_U, GL_FLOAT, textureVertices_u, 2);


	m_textureY->bind(0);//激活纹理单元GL_TEXTURE0
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, yuvLineSize[0], frmSize.height(), 0, GL_RED, GL_UNSIGNED_BYTE, yuvDat[0]);

	m_textureU->bind(1);//激活纹理单元GL_TEXTURE1
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, yuvLineSize[1], frmSize.height() / 2, 0, GL_RED, GL_UNSIGNED_BYTE, yuvDat[1]);

	m_textureV->bind(2);//激活纹理单元GL_TEXTURE2
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, yuvLineSize[2], frmSize.height() / 2, 0, GL_RED, GL_UNSIGNED_BYTE, yuvDat[2]);

	//绘制
	m_programYUV420p->setUniformValue("tex_y", 0);
	m_programYUV420p->setUniformValue("tex_u", 1);
	m_programYUV420p->setUniformValue("tex_v", 2);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	m_textureY->release();
	m_textureU->release();
	m_textureV->release();
	m_programYUV420p->release();
	return true;
}
