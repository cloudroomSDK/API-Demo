using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ButtonHandler : MonoBehaviour
{
    public void OnButtonClicked(Button btn)
    {
        GameObject go = GameObject.Find("MainControl");
        if (null == go)
            return;
        LoginPage mainControl = go.GetComponent<LoginPage>();
        if (null == mainControl)
            return;

        if (btn.name == "CreateBtn")
        {
            mainControl.OnCreateBtnClicked();
        }
        else if (btn.name == "JoinBtn")
        {
            mainControl.OnJoinBtnClicked();
        }
        else if (btn.name == "SettingBtn")
        {
            mainControl.OnSettingBtnClicked();
        }
        else if (btn.name == "CancelSetBtn")
        {
            mainControl.OnCancelSetBtnClicked();
        }
        else if (btn.name == "ResetSetBtn")
        {
            mainControl.OnResetSetBtnClicked();
        }
        else if (btn.name == "SaveSetBtn")
        {
            mainControl.OnSaveSetBtnClicked();
        }
        else if (btn.name == "TipOkBtn")
        {
            mainControl.OnTipOkBtnClicked();
        }
    }
}
