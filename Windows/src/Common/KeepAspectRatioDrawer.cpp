#include "stdafx.h"
#include "KeepAspectRatioDrawer.h"

const static QColor defaultBkColor = QColor(0, 0, 0); //默认背景色



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
		if (diff < 0.06)
			return widgetRect;

		targetSize = imgSize.scaled(widgetRect.size(), Qt::KeepAspectRatio);
	}

	//居中显示
	QPoint topleft;
	topleft.setX((widgetRect.width() - targetSize.width()) / 2);
	topleft.setY((widgetRect.height() - targetSize.height()) / 2);
	return QRect(topleft, targetSize);
}

void KeepAspectRatioDrawer::Draw(const QImage &img, QWidget *p, const QRect &dstRt)
{
	QPainter painter(p);
	painter.setRenderHint(QPainter::SmoothPixmapTransform);

	QRect widgetRt = p->rect();
	if (img.isNull() || dstRt.width() < widgetRt.width() || dstRt.height() < widgetRt.height())
	{
		//图片有空白区域 ,填充默认背景色
		painter.fillRect(p->rect(), defaultBkColor);
	}

	painter.drawImage(dstRt, img);
	return;
}


void KeepAspectRatioDrawer::DrawImage(QWidget *p, const QImage &srcPic, CRVSDK_SCALE_MODE mode, bool bMirror)
{
	QRect dstRt = getContentRect(p, srcPic.size(), mode);
	//绘制
	QImage tmp(srcPic);
	if (bMirror)
	{
		tmp = tmp.mirrored(true, false);
	}
	Draw(tmp, p, dstRt);
}

void KeepAspectRatioDrawer::DrawImage(QWidget *p, const CRVideoFrame &frm, CRVSDK_SCALE_MODE mode, bool bMirror)
{
	CRVideoFrame tmp(frm);

	//生成img图像
	QRect dstRt;
	QImage img;
	if (frm.getFormat() != CRVSDK_VFMT_INVALID)
	{
		dstRt = getContentRect(p, QSize(frm.getWidth(), frm.getHeight()), mode);
		if (!dstRt.isEmpty())
		{
			//格式转换、缩小处理（这里只会缩小、不会放大）
			if (g_sdkMain->videoFrameCover(tmp, CRVSDK_VFMT_ARGB32, dstRt.width(), dstRt.height()))
			{
				//镜像处理
				if (bMirror)
				{
					g_sdkMain->mirrorVideoFrame(tmp);
				}

				//得到frm中原始指针
				uint8_t* rgb[1];
				int      linesize[1];
				tmp.getRawDatPtr(rgb, linesize, 1);

				//生成img
				img = QImage(rgb[0], tmp.getWidth(), tmp.getHeight(), linesize[0], QImage::Format_RGB32);
			}
		}
	}

	//绘制
	Draw(img, p, dstRt);
}

