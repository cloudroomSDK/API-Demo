#include "stdafx.h"
#include "KeepAspectRatioDrawer.h"

QRect KeepAspectRatioDrawer::getContentRect(QWidget *p, const QSize& imgSize, CRVSDK_SCALE_MODE mode)
{
	QRect widgetRect = p->rect();
	if (imgSize.isEmpty() || widgetRect.isEmpty())
		return widgetRect;

	//铺满
	if (mode == CRVSDK_RENDERMD_FILL)
		return widgetRect;

	QSize targetSize;
	//裁剪方式
	if (mode == CRVSDK_RENDERMD_HIDDEN)
	{
		targetSize = imgSize.scaled(widgetRect.size(), Qt::KeepAspectRatioByExpanding);
	}
	else
	{
		//等比完整显示
		float diff = qAbs(imgSize.width() / float(imgSize.height()) - widgetRect.width() / float(widgetRect.height()));
		//如果变形比例在6%以内，按拉伸模式显示，效果更好
// 		if (diff < 0.06)
// 			return widgetRect;

		targetSize = imgSize.scaled(widgetRect.size(), Qt::KeepAspectRatio);
	}

	//居中显示
	QPoint topleft;
	topleft.setX((widgetRect.width() - targetSize.width()) / 2);
	topleft.setY((widgetRect.height() - targetSize.height()) / 2);
	return QRect(topleft, targetSize);
}

void KeepAspectRatioDrawer::Draw(const QImage &img, QWidget *p, const QRect &dstRt, const QColor &bkColr)
{
	QPainter painter(p);
	painter.setRenderHint(QPainter::SmoothPixmapTransform);

	QRect widgetRt = p->rect();
	if (img.isNull() || dstRt.width() < widgetRt.width() || dstRt.height() < widgetRt.height())
	{
		//图片有空白区域 ,填充默认背景色
		painter.fillRect(p->rect(), bkColr);
	}

	painter.drawImage(dstRt, img);
	return;
}


void KeepAspectRatioDrawer::DrawImage(QWidget *p, const QImage &srcPic, CRVSDK_SCALE_MODE mode, bool bMirror, const QColor &bkColr)
{
	QRect dstRt = getContentRect(p, srcPic.size(), mode);
	//绘制
	QImage tmp(srcPic);
	if (bMirror)
	{
		tmp = tmp.mirrored(true, false);
	}
	Draw(tmp, p, dstRt, bkColr);
}

void KeepAspectRatioDrawer::DrawImage(QWidget *p, const CRVideoFrame &frm, CRVSDK_SCALE_MODE mode, bool bMirror, const QColor &bkColr)
{
	CRVideoFrame tmp(frm);

	//生成img图像
	QRect dstRt;
	QImage img;
	CRVSDK_VIDEO_FORMAT frmFmt = frm.getFormat();
	if (frmFmt != CRVSDK_VFMT_INVALID)
	{
		dstRt = getContentRect(p, QSize(frm.getWidth(), frm.getHeight()), mode);
		if (!dstRt.isEmpty())
		{
			bool bHaveAlpha = (frmFmt == CRVSDK_VFMT_ARGB32) || (frmFmt == CRVSDK_VFMT_RGBA32) || (frmFmt == CRVSDK_VFMT_BGRA32) || (frmFmt == CRVSDK_VFMT_ABGR32);
			//格式转换、缩小处理（这里只会缩小、不会放大）
			if (g_sdkMain->videoFrameCover(tmp, (bHaveAlpha ? CRVSDK_VFMT_ARGB32 : CRVSDK_VFMT_0RGB32), dstRt.width(), dstRt.height()))
			{
				//得到frm中原始指针
				uint8_t* rgb[1];
				int      linesize[1];
				tmp.getRawDatPtr(rgb, linesize, 1);

				//生成img
				img = QImage(rgb[0], tmp.getWidth(), tmp.getHeight(), linesize[0], (bHaveAlpha ? QImage::Format_ARGB32 : QImage::Format_RGB32));
			}
		}
	}

	//绘制
	if (bMirror)
	{
		img = img.mirrored(true, false);
	}

	//绘制
	Draw(img, p, dstRt, bkColr);
}

