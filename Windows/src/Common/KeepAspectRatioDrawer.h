#ifndef _KEEPASPECTRATIODRAWER_H_
#define _KEEPASPECTRATIODRAWER_H_

class KeepAspectRatioDrawer
{
public:
	static void DrawImage(QWidget *p, const CRVideoFrame &frm, CRVSDK_SCALE_MODE mode, bool bMirror=false, const QColor &bkColr=QColor(0,0,0));
	static void DrawImage(QWidget *p, const QImage &srcPic, CRVSDK_SCALE_MODE mode, bool bMirror = false, const QColor &bkColr = QColor(0, 0, 0));
	static QRect getContentRect(QWidget *p, const QSize& imgSize, CRVSDK_SCALE_MODE mode);

protected:
	static void Draw(const QImage &img, QWidget *p, const QRect &dstRt, const QColor &bkColr);
};

#endif // _KEEPASPECTRATIODRAWER_H_