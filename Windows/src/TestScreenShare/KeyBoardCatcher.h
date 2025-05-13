#ifndef _KeyBoardCatcher_H_
#define _KeyBoardCatcher_H_

/*
处理qt的KeyEvent方式；
此方式，跨平台通用；
但一些系统键、快捷键无法捕获；
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
//处理使用Windows键盘钩子方式；
//此方式，仅windows平台有效；
//capsLock, numLock, scroolLock不hook；（避免对应指示灯不工作）
//除了:Win+L, Ctrl+Alt+Del 之外， 其它系统键、其它程序的热键都将失效，并被捕获；
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
