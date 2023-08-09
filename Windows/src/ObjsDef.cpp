#include "stdafx.h"
#include "ObjsDef.h"


void Struct_Cov(const QVariantMap &src, VideoCfg &dst)
{
	if (src.empty())
	{
		return;
	}

	QStringList varLst = src.value("size").toString().split('*');
	if (varLst.size() > 1)
	{
		dst._size.setWidth(varLst[0].toInt());
		dst._size.setHeight(varLst[1].toInt());
	}
	dst._fps = src.value("fps", dst._fps).toInt();
	dst._maxbps = src.value("maxbps", dst._maxbps).toInt();
	dst._min_qp = src.value("qp_min", dst._min_qp).toInt();
	dst._max_qp = src.value("qp_max", dst._max_qp).toInt();
}

void Struct_Cov(const VideoCfg &src, QVariantMap &dst)
{
	dst["fps"] = src._fps;
	dst["maxbps"] = src._maxbps;
	dst["qp_min"] = src._min_qp;
	dst["qp_max"] = src._max_qp;
	if (!src._size.isEmpty())
	{
		dst["size"] = QString("%1*%2").arg(src._size.width()).arg(src._size.height());
	}
}



