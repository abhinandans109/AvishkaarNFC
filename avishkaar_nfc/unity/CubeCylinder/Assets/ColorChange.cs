using System.Collections;
using System.Collections.Generic;
using FlutterUnityIntegration;
using UnityEngine;

public class ColorChange : MonoBehaviour
{

    public GameObject Shape;
    [SerializeField] Material Red;
    [SerializeField] Material Blue;
    [SerializeField] Material Green;
    [SerializeField] Material Yellow;
    // Start is called before the first frame update
    void Start()
    {
       
    }

    public void FindShape()
    {
        Shape = GameObject.FindWithTag("shape").gameObject;
    }

   public void ChangeToRed()
    {
        Shape.GetComponent<MeshRenderer>().material = Red;
    }

    public void ChangeTOBlue()
    {
        Shape.GetComponent<MeshRenderer>().material = Blue;
    }

    public void ColorFromFlutter(string Color) 
    {
        if(Color == "red")
        {
            Shape.GetComponent<MeshRenderer>().material = Red;

        }
       else if (Color == "blue")
        {
            Shape.GetComponent<MeshRenderer>().material = Blue;

        }
      else if (Color == "green")
        {
            Shape.GetComponent<MeshRenderer>().material = Green;

        }
       else if (Color == "yellow")
        {
            Shape.GetComponent<MeshRenderer>().material = Yellow;

        }
        Debug.Log("Color changed" + Color);
    }

    public void DataFromFlutter(string message)
    {
        Debug.Log(Application.persistentDataPath);
        if (message == "start")
        {
            Debug.Log(Application.persistentDataPath);
            UnityMessageManager.Instance.SendMessageToFlutter(Application.persistentDataPath);
        }
    }

    
}
