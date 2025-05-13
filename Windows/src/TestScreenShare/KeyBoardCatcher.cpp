#include "stdafx.h"
#include "KeyBoardCatcher.h"


//////////////////////////////////////////////////////////////////////////
KeyBoardCatcher::KeyBoardCatcher(QObject *parent) : QObject(parent)
{
	m_modifiers = Qt::NoModifier;
}

KeyBoardCatcher::~KeyBoardCatcher()
{
	if (m_targetWidget != nullptr)
	{
		setTargetWidget(nullptr);
	}
}

void KeyBoardCatcher::setTargetWidget(QWidget *forWidget)
{
	uninstallCatcher();
	clearKeyboardModifiers();
	m_targetWidget = forWidget;
	if (m_targetWidget != nullptr)
	{
		m_targetWidget->installEventFilter(this);
	}
	if (installCatcher())
	{
		initKeyboardModifiers();
	}
}

bool KeyBoardCatcher::installCatcher()
{
	if (m_targetWidget == nullptr)
		return false;
	if (qApp->focusWidget() != m_targetWidget)
		return false;
	return true;
}

void KeyBoardCatcher::uninstallCatcher()
{

}

void KeyBoardCatcher::sendKeyMsgToRemote(int vk, bool bKeyDown)
{
	m_modifiers = getNewKeyboardModifiers(m_modifiers, vk, bKeyDown);
	//send msg to remote;
	const char *strKeyType = bKeyDown ? "KeyDown" : "KeyUp";
	qDebug("%s, key:0x%x, modifiers:0x%x", strKeyType, vk, m_modifiers);
	g_sdkMain->getSDKMeeting().sendKeyCtrlMsg(bKeyDown ? CRVSDK::CRVSDK_KEYMSG_DWON : CRVSDK::CRVSDK_KEYMSG_UP, vk);
}


void KeyBoardCatcher::initKeyboardModifiers()
{
	Qt::KeyboardModifiers modifiers = QGuiApplication::queryKeyboardModifiers();
	updateModifiers(modifiers);
}

void KeyBoardCatcher::clearKeyboardModifiers()
{
	updateModifiers(Qt::NoModifier);
}

Qt::KeyboardModifiers KeyBoardCatcher::getNewKeyboardModifiers(Qt::KeyboardModifiers modifiers, int vk, bool bDown)
{
	if (bDown)
	{
		if (vk == VK_SHIFT || vk==VK_LSHIFT || vk==VK_RSHIFT ) modifiers |= Qt::ShiftModifier;
		else if (vk == VK_CONTROL || vk==VK_LCONTROL || vk==VK_RCONTROL) modifiers |= Qt::ControlModifier;
		else if (vk == VK_MENU || vk == VK_LMENU || vk == VK_RMENU) modifiers |= Qt::AltModifier;
		else if (vk == VK_LWIN || vk == VK_RWIN) modifiers |= Qt::MetaModifier;
	}
	else
	{
		if (vk == VK_SHIFT || vk == VK_LSHIFT || vk == VK_RSHIFT) modifiers &= ~Qt::ShiftModifier;
		else if (vk == VK_CONTROL || vk == VK_LCONTROL || vk == VK_RCONTROL) modifiers &= ~Qt::ControlModifier;
		else if (vk == VK_MENU || vk == VK_LMENU || vk == VK_RMENU)  modifiers &= ~Qt::AltModifier;
		else if (vk == VK_LWIN || vk == VK_RWIN) modifiers &= ~Qt::MetaModifier;
	}
	return modifiers;
}


void KeyBoardCatcher::updateModifiers(Qt::KeyboardModifiers modifiers)
{
	if ((modifiers & Qt::ShiftModifier) != (m_modifiers &Qt::ShiftModifier))
	{
		bool bKeyDown = (modifiers & Qt::ShiftModifier) ? true : false;
		sendKeyMsgToRemote(VK_SHIFT, bKeyDown);
	}
	if ((modifiers & Qt::AltModifier) != (m_modifiers &Qt::AltModifier))
	{
		bool bKeyDown = (modifiers & Qt::AltModifier) ? true : false;
		sendKeyMsgToRemote(VK_MENU, bKeyDown);
	}
	if ((modifiers & Qt::ControlModifier) != (m_modifiers &Qt::ControlModifier))
	{
		bool bKeyDown = (modifiers & Qt::ControlModifier) ? true : false;
		#ifdef MAC
			int key = VK_LWIN;
		#else
			int key = VK_CONTROL;
		#endif
			sendKeyMsgToRemote(key, bKeyDown);
	}
	if ((modifiers & Qt::MetaModifier) != (m_modifiers &Qt::MetaModifier))
	{
		bool bKeyDown = (modifiers & Qt::MetaModifier) ? true : false;
#ifdef MAC
		int key = VK_CONTROL;
#else
		int key = VK_LWIN;
#endif
		sendKeyMsgToRemote(key, bKeyDown);
	}
	m_modifiers = modifiers;
}

bool KeyBoardCatcher::eventFilter(QObject *obj, QEvent *event)
{
	if (obj == m_targetWidget)
	{
		if (event->type() == QEvent::FocusIn)
		{
			qDebug("focus in label");
			installCatcher();
			initKeyboardModifiers();
		}
		else if (event->type() == QEvent::FocusOut)
		{
			qDebug("focus out label");
			uninstallCatcher();
			clearKeyboardModifiers();
		}
		else if (event->type() == QEvent::KeyPress)
		{
			QKeyEvent *keyEvt = static_cast<QKeyEvent*>(event);
			int vk = qtKeyToVK(Qt::Key(keyEvt->key()));
			sendKeyMsgToRemote(vk, true);
			return true;
		}
		else if (event->type() == QEvent::KeyRelease)
		{
			QKeyEvent *keyEvt = static_cast<QKeyEvent*>(event);
			int vk = qtKeyToVK(Qt::Key(keyEvt->key()));
			sendKeyMsgToRemote(vk, false);
			return true;
		}
	}

	return false;
}


int KeyBoardCatcher::qtKeyToVK(Qt::Key key)
{
	switch (key)
	{
	case Qt::Key_Escape: return VK_ESCAPE;
	case Qt::Key_Tab: return VK_TAB;
	case Qt::Key_Backtab: return VK_TAB;
	case Qt::Key_Backspace: return VK_BACK;
	case Qt::Key_Return: return VK_RETURN;
	case Qt::Key_Enter: return VK_RETURN;
	case Qt::Key_Insert: return VK_INSERT;
	case Qt::Key_Delete: return VK_DELETE;
	case Qt::Key_Pause: return VK_PAUSE;
	case Qt::Key_Print: return VK_PRINT;
	case Qt::Key_SysReq: return VK_PRINT;
	case Qt::Key_Clear: return VK_CLEAR;
	case Qt::Key_Home: return VK_HOME;
	case Qt::Key_End: return VK_END;
	case Qt::Key_Left: return VK_LEFT;
	case Qt::Key_Up: return VK_UP;
	case Qt::Key_Right: return VK_RIGHT;
	case Qt::Key_Down: return VK_DOWN;
	case Qt::Key_PageUp: return VK_PRIOR;
	case Qt::Key_PageDown: return VK_NEXT;
	case Qt::Key_Shift: return VK_SHIFT;
#ifdef MAC
	case Qt::Key_Control: return VK_LWIN;
	case Qt::Key_Meta: return VK_CONTROL;
#else
	case Qt::Key_Control: return VK_CONTROL;
	case Qt::Key_Meta: return VK_LWIN;
#endif
	case Qt::Key_Alt: return VK_MENU;
	case Qt::Key_CapsLock: return VK_CAPITAL;
	case Qt::Key_NumLock: return VK_NUMLOCK;
	case Qt::Key_ScrollLock: return VK_SCROLL;
	case Qt::Key_F1: return VK_F1;
	case Qt::Key_F2: return VK_F2;
	case Qt::Key_F3: return VK_F3;
	case Qt::Key_F4: return VK_F4;
	case Qt::Key_F5: return VK_F5;
	case Qt::Key_F6: return VK_F6;
	case Qt::Key_F7: return VK_F7;
	case Qt::Key_F8: return VK_F8;
	case Qt::Key_F9: return VK_F9;
	case Qt::Key_F10: return VK_F10;
	case Qt::Key_F11: return VK_F11;
	case Qt::Key_F12: return VK_F12;
	case Qt::Key_F13: return VK_F13;
	case Qt::Key_F14: return VK_F14;
	case Qt::Key_F15: return VK_F15;
	case Qt::Key_F16: return VK_F16;
	case Qt::Key_F17: return VK_F17;
	case Qt::Key_F18: return VK_F18;
	case Qt::Key_F19: return VK_F19;
	case Qt::Key_F20: return VK_F20;
	case Qt::Key_F21: return VK_F21;
	case Qt::Key_F22: return VK_F22;
	case Qt::Key_F23: return VK_F23;
	case Qt::Key_F24: return VK_F24;
	case Qt::Key_Menu: return VK_APPS;
	case Qt::Key_Space: return VK_SPACE;
	case Qt::Key_Asterisk: return VK_MULTIPLY;
	case Qt::Key_Plus: return VK_ADD;
	case Qt::Key_Minus: return VK_SUBTRACT;
	case Qt::Key_Slash: return VK_DIVIDE;
	case Qt::Key_MediaNext: return VK_MEDIA_NEXT_TRACK;
	case Qt::Key_MediaPrevious:	return VK_MEDIA_PREV_TRACK;
	case Qt::Key_MediaPlay:	return VK_MEDIA_PLAY_PAUSE;
	case Qt::Key_MediaStop: return VK_MEDIA_STOP;
	case Qt::Key_VolumeDown: return VK_VOLUME_DOWN;
	case Qt::Key_VolumeUp: return VK_VOLUME_UP;
	case Qt::Key_VolumeMute: return VK_VOLUME_MUTE;
	case Qt::Key_0:
	case Qt::Key_1:
	case Qt::Key_2:
	case Qt::Key_3:
	case Qt::Key_4:
	case Qt::Key_5:
	case Qt::Key_6:
	case Qt::Key_7:
	case Qt::Key_8:
	case Qt::Key_9: return key;
	case Qt::Key_A:
	case Qt::Key_B:
	case Qt::Key_C:
	case Qt::Key_D:
	case Qt::Key_E:
	case Qt::Key_F:
	case Qt::Key_G:
	case Qt::Key_H:
	case Qt::Key_I:
	case Qt::Key_J:
	case Qt::Key_K:
	case Qt::Key_L:
	case Qt::Key_M:
	case Qt::Key_N:
	case Qt::Key_O:
	case Qt::Key_P:
	case Qt::Key_Q:
	case Qt::Key_R:
	case Qt::Key_S:
	case Qt::Key_T:
	case Qt::Key_U:
	case Qt::Key_V:
	case Qt::Key_W:
	case Qt::Key_X:
	case Qt::Key_Y:
	case Qt::Key_Z: return key;

	case Qt::Key_AsciiTilde:
	case Qt::Key_QuoteLeft: return VK_OEM_3; //`~
	case Qt::Key_Exclam: return '1'; //vk_1
	case Qt::Key_At: return '2';	 //vk_2
	case Qt::Key_NumberSign: return '3';
	case Qt::Key_Dollar: return '4';
	case Qt::Key_Percent: return '5';
	case Qt::Key_AsciiCircum: return '6';
	case Qt::Key_Ampersand: return '7';
	case Qt::Key_ParenLeft: return '9';
	case Qt::Key_ParenRight: return '0';
	case Qt::Key_Underscore: return VK_OEM_MINUS; //_
	case Qt::Key_Equal: return VK_OEM_PLUS; //=
	case Qt::Key_Backslash: return VK_OEM_5; //\ 
	case Qt::Key_Bar: return VK_OEM_5; //|
	case Qt::Key_BracketLeft: return VK_OEM_4; //[
	case Qt::Key_BracketRight: return VK_OEM_6; //]
	case Qt::Key_BraceLeft: return VK_OEM_4; //{
	case Qt::Key_BraceRight: return VK_OEM_6; //}
	case Qt::Key_Colon: return VK_OEM_1; //:
	case Qt::Key_Semicolon: return VK_OEM_1; //;
	case Qt::Key_QuoteDbl: return VK_OEM_7; //"
	case Qt::Key_Apostrophe: return VK_OEM_7; //'
	case Qt::Key_Less: return VK_OEM_COMMA; //<
	case Qt::Key_Comma: return VK_OEM_COMMA; //,
	case Qt::Key_Greater: return VK_OEM_PERIOD; //>
	case Qt::Key_Period: return VK_OEM_PERIOD; //.
	case Qt::Key_Question: return VK_OEM_2; //?
	//case Qt::Key_Slash: return VK_OEM_2; ///

	default: return 0;
	}
}


//////////////////////////////////////////////////////////////////////////
#ifdef WIN32
KeyBoardCatcher_WinHook* KeyBoardCatcher_WinHook::s_instance = nullptr;

KeyBoardCatcher_WinHook::KeyBoardCatcher_WinHook(QObject *parent) : KeyBoardCatcher(parent)
{
	m_hook = nullptr;
	s_instance = this;
}

KeyBoardCatcher_WinHook::~KeyBoardCatcher_WinHook()
{
	uninstallCatcher();
	s_instance = nullptr;
}

LRESULT CALLBACK KeyBoardCatcher_WinHook::KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam)
{
	if (s_instance->onKeyboardHookMsg(nCode, wParam, lParam))
		return 1;
	return CallNextHookEx(s_instance->m_hook, nCode, wParam, lParam);
}

bool KeyBoardCatcher_WinHook::onKeyboardHookMsg(int nCode, WPARAM wParam, LPARAM lParam)
{
	if (nCode >= 0) {
		PKBDLLHOOKSTRUCT p = (PKBDLLHOOKSTRUCT)lParam;
		if (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN)
		{
			if (p->vkCode != VK_NUMLOCK && p->vkCode != VK_CAPITAL && p->vkCode != VK_SCROLL)
			{
				sendKeyMsgToRemote(p->vkCode, true);
				return true;
			}
		}
		else if (wParam == WM_KEYUP || wParam == WM_SYSKEYUP)
		{
			if (p->vkCode != VK_NUMLOCK && p->vkCode != VK_CAPITAL && p->vkCode != VK_SCROLL)
			{
				sendKeyMsgToRemote(p->vkCode, false);
				return true;
			}
		}
	}

	return false;
}

bool KeyBoardCatcher_WinHook::installCatcher()
{
	if (!KeyBoardCatcher::installCatcher())
		return false;

	HINSTANCE hInstance = GetModuleHandle(NULL);
	m_hook = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, hInstance, 0);
	if (m_hook == nullptr)
	{
		qDebug("installKeyHook failed!, err:%d", GetLastError());
		KeyBoardCatcher::uninstallCatcher();
		return false;
	}
	return true;
}

void KeyBoardCatcher_WinHook::uninstallCatcher()
{
	if (m_hook != nullptr)
	{
		UnhookWindowsHookEx(m_hook);
		m_hook = nullptr;
	}
	KeyBoardCatcher::uninstallCatcher();
}

#endif
