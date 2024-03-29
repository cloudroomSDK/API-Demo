#ifndef CRFPSStatistics_H
#define CRFPSStatistics_H

//计算设定时间内帧率
class CRFPSStatistics
{
public:
	CRFPSStatistics();
	~CRFPSStatistics(){;}

	//设置统计时长 
	void SetStaticMaxDuration(int nMS=1000);
	void Reinit();
	void AddCount();
	float GetFPS();

protected:
	void RemoveInvildDat(int64_t curTime);

protected:
	int64_t m_startTime;
	int64_t m_maxDuration;
	std::list<int64_t>	m_dats;
};


#endif