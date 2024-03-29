#ifndef _KEEPASPECTRATIODRAWER_H_
#define _KEEPASPECTRATIODRAWER_H_

class KeepAspectRatioDrawer
{
public:
	static void DrawImage(QWidget *p, const CRVideoFrame &frm, CRVSDK_SCALE_MODE mode, bool bMirror=false);
	static void DrawImage(QWidget *p, const QImage &srcPic, CRVSDK_SCALE_MODE mode, bool bMirror = false);
	static QRect getContentRect(QWidget *p, const QSize& imgSize, CRVSDK_SCALE_MODE mode);

protected:
	static void Draw(const QImage &img, QWidget *p, const QRect &dstRt);
};

#endif // _KEEPASPECTRATIODRAWER_H_