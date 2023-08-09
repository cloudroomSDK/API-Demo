#ifndef _JSON_HELPER_H_
#define _JSON_HELPER_H_


QByteArray CoverJsonToString(const QVariant &JsonData);
QVariant CoverStringToJson(const QByteArray &JsonData);


template<typename T>
QByteArray StructToJson(const T &obj)
{
	QVariantMap var;
	Struct_Cov(obj, var);
	return CoverJsonToString(var);
}

template<typename T>
T JsonToStruct(const QByteArray &json)
{
	T s;
	QVariant var = CoverStringToJson(json);
	Struct_Cov(var.toMap(), s);
	return s;
}

template<typename ListType, typename ItemType>
QByteArray StructToJson(const ListType &list)
{
	QVariantList infos;
	for(const ItemType &item : list)
	{
		QVariantMap var;
		Struct_Cov(item, var);
		infos.append(var);
	}
	return CoverJsonToString(infos);
}

template<typename ListType, typename ItemType>
ListType JsonToStruct(const QByteArray &json)
{
	QVariantList varList = CoverStringToJson(json).toList();

	ListType list;
	for(const QVariant &var : varList)
	{
		ItemType item;
		Struct_Cov(var.toMap(), item);
		list.push_back(item);
	}
	return list;
}

#endif