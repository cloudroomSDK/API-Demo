#ifndef _KeyBoardCatcher_H_
#define _KeyBoardCatcher_H_

/*
����qt��KeyEvent��ʽ��
�˷�ʽ����ƽ̨ͨ�ã�
��һЩϵͳ������ݼ��޷�����
*/

class KeyBoardCatcher : public QObject
{
	Q_OBJECT
public:
	KeyBoardCatcher(QObject *parent = nullptr);
	~KeyBoardCatcher();

	void setTargetWidget(QWidget *forWidget);
	void sendKeyMsgToRemote(int vk, bool bKeyDown);

protected:
	bool eventFilter(QObject *obj, QEvent *event) override;
	virtual bool installCatcher();
	virtual void uninstallCatcher();
	void initKeyboardModifiers();
	void clearKeyboardModifiers();
	Qt::KeyboardModifiers getNewKeyboardModifiers(Qt::KeyboardModifiers modifiers, int vk, bool bDown);
	void updateModifiers(Qt::KeyboardModifiers modifiers);
	int qtKeyToVK(Qt::Key key);

protected:
	QWidget*	m_targetWidget{ nullptr };
	Qt::KeyboardModifiers m_modifiers;

};

#ifdef WIN32
//����ʹ��Windows���̹��ӷ�ʽ��
//�˷�ʽ����windowsƽ̨��Ч��
//capsLock, numLock, scroolLock��hook���������Ӧָʾ�Ʋ�������
//����:Win+L, Ctrl+Alt+Del ֮�⣬ ����ϵͳ��������������ȼ�����ʧЧ����������
class KeyBoardCatcher_WinHook : public KeyBoardCatcher
{
public:
	KeyBoardCatcher_WinHook(QObject *parent);
	~KeyBoardCatcher_WinHook();

protected:
	bool installCatcher() override;
	void uninstallCatcher() override;

	bool onKeyboardHookMsg(int nCode, WPARAM wParam, LPARAM lParam);
private:
	static KeyBoardCatcher_WinHook* s_instance;
	static LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam);
	HHOOK	m_hook{ nullptr };
};
#endif

#endif // _KeyBoardCatcher_H_
