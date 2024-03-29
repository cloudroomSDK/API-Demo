#include "stdafx.h"
#include "CRFPSStatistics.h"


CRFPSStatistics::CRFPSStatistics()
{
	m_maxDuration = 1000;
	Reinit();
}

void CRFPSStatistics::SetStaticMaxDuration(int nMS)
{
	m_maxDuration = nMS;
}

void CRFPSStatistics::Reinit()
{
	m_dats.clear();
	m_startTime = 0;
}

void CRFPSStatistics::AddCount()
{
	int64_t curTm = QDateTime::currentMSecsSinceEpoch();
	if ( m_startTime==0 )
	{
		m_startTime = curTm;
	}

	//移除超时的
	RemoveInvildDat(curTm);
	m_dats.push_back(curTm);
}

void CRFPSStatistics::RemoveInvildDat(int64_t curTime)
{
	for (auto pos = m_dats.begin(); pos != m_dats.end();)
	{
		int64_t timeDuration = curTime - *pos;
		if ( timeDuration<m_maxDuration )
		{
			break;
		}
		//pos指向下一个元素
		pos = m_dats.erase(pos);
	}
}

float CRFPSStatistics::GetFPS()
{
	int64_t curTime = QDateTime::currentMSecsSinceEpoch();
	RemoveInvildDat(curTime);

	int64_t calculateDuration = curTime - m_startTime;
	if (calculateDuration>m_maxDuration)
	{
		calculateDuration = m_maxDuration;
	}
	
	if (calculateDuration < 100)
	{
		return 0.0;
	}

	auto lastfps = (m_dats.size()*1000.0) / calculateDuration;
	return float(lastfps);
}
