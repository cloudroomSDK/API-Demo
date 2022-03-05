#ifndef KVIDEOUI_H
#define KVIDEOUI_H

#include "CustomRenderWidget.h"

QT_BEGIN_NAMESPACE
namespace Ui { class KVideoUI; }
QT_END_NAMESPACE

class KVideoUI : public CustomRenderWidget
{
	Q_OBJECT

public:
	KVideoUI(QWidget* pParent = 0);
	virtual ~KVideoUI();

	//恢复初始值
	void clean();

	void updateNickname(const QString &nickname);
	void updateNetState(int level);
	void updateMicStatus(CRVSDK_ASTATUS aStatus);
	void updateMicEnergy(int level);
	void updateCamStatus(CRVSDK_VSTATUS vStatus);

	void setVideoInfo(const char* userID);
	void setVideoInfo(const CRVSDK::CRUserVideoID &cam);

	const CRVSDK::CRUserVideoID &getUsrCamID() const { return m_vId; }
	const CRBase::CRString &getUserId() const {	return m_vId._userID; }
	int getCameraId() const { return m_vId._videoID; }

	bool isRenderState() const;

protected:
    void paintEvent(QPaintEvent *event);
	void hideEvent(QHideEvent* event);
	void showEvent(QShowEvent* event);

private slots:
	void slot_btnMicClicked();
	void slot_btnCamClicked();
	void slot_btnMirrorClicked();
	void slot_btnRotateClicked();

private:
	void initAllPics();
	void updateBtnState(const CRBase::CRString &nickname, CRVSDK_ASTATUS aStatus, CRVSDK_VSTATUS vStatus);
	void updateRenderState();

private:
	Ui::KVideoUI	*ui;
	CRUserVideoID	m_vId;

	bool			m_mineVideo;
	int				m_videoRotate;
};


#endif // KVIDEOUI_H
