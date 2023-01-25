using System.Collections;
using System.Collections.Generic;
//using FlutterUnityIntegration;
using UnityEngine;

public class ColorChange : MonoBehaviour
{

    public GameObject Shape;
    Material ColorShifter;
    public Material[] Materials;
    // Start is called before the first frame update

    public void ColorFromFlutter(string Color) 
    {
        for (int i = 0; i < Materials.Length; i++)
        {
            if (Materials[i].name == Color)
            {
                ColorShifter = Materials[i];
                Shape.GetComponent<MeshRenderer>().material = ColorShifter;
                return;
            }
        }
     
    }

    public void DataFromFlutter(string message)
    {
        Debug.Log(Application.persistentDataPath);
        if (message == "start")
        {
            Debug.Log(Application.persistentDataPath);
           // UnityMessageManager.Instance.SendMessageToFlutter(Application.persistentDataPath);
        }
    }

    
}
