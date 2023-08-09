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


#endif	//_OBJSDEF_H_
