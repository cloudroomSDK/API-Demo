#ifndef _OBJSDEF_H_
#define _OBJSDEF_H_

#if defined(_MSC_VER) && (_MSC_VER >= 1600)    
# pragma execution_character_set("utf-8")    
#endif

#include "JsonHelper.h"

struct VideoCfg
{
	QSize		_size;
	int			_fps;		//视频帧率(1~60)
	int			_maxbps;	//视频码率
	int			_min_qp;	//质量范围_最小
	int			_max_qp;	//质量范围_最大(质量最差)
	VideoCfg()
	{
		_size = QSize(0, 0);
		_fps = -1;
		_maxbps = -1;
		_min_qp = -1;
		_max_qp = -1;
	}
};
void Struct_Cov(const QVariantMap &src, VideoCfg &dst);
void Struct_Cov(const VideoCfg &src, QVariantMap &dst);

struct VideoEffectsObj
{
	int _denoise = 1;
	int _mirror = 0;
};
void Struct_Cov(const QVariantMap &src, VideoEffectsObj &dst);
void Struct_Cov(const VideoEffectsObj &src, QVariantMap &dst);

enum BeautyFilterType
{
	//美颜
	BeautySmooth = 0,	//磨皮，0~1, 默认0
	BeautyWhiten,		//美白，0~1, 默认0
	BeautyLipstick,		//红唇，0~1, 默认0
	BeautyBlusher,		//腮红，0~1, 默认0
	BeautyThinFace,		//瘦脸，0~1, 默认0
	BeautyBigEye,		//大眼，0~1, 默认0

	BeautyFilterType_Butt
};
QString getBeautyFilterTypeName(BeautyFilterType type);

struct BeautyCfg {
	std::map<BeautyFilterType, float> filters;
};

void Struct_Cov(const QVariantMap &src, BeautyCfg &dst);
void Struct_Cov(const BeautyCfg &src, QVariantMap &dst);


enum VIRTUALBK_TYPE
{
	VBKTP_UNDEF = 0,	//未指定
	VBKTP_COLORKEY,		//绿幕
	VBKTP_HUMANSEG,		//人像
};
struct VirtualBkCfg
{
	VIRTUALBK_TYPE	_type{ VBKTP_UNDEF };
	QString			_colorKey;		//绿幕模式下的颜色值#RRGGBB
	QString			_bkImgFile;
	QString			_bkImgFromResID;
	bool operator==(const VirtualBkCfg &v)
	{
		return (_type == v._type && _colorKey == v._colorKey && _bkImgFile == v._bkImgFile && _bkImgFromResID == v._bkImgFromResID);
	}
	bool operator!=(const VirtualBkCfg &v)
	{
		return !(*this == v);
	}
};
void Struct_Cov(const QVariantMap &src, VirtualBkCfg &dst);
void Struct_Cov(const VirtualBkCfg &src, QVariantMap &dst);


#endif	//_OBJSDEF_H_
