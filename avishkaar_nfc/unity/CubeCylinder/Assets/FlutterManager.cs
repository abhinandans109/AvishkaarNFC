using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlutterManager : MonoBehaviour
{
    public GameObject Shape;
    Rotate rotate;
    ColorChange colorChange;
    LoadFromDisk loadFromDisk;
    // Start is called before the first frame update
    void Start()
    {
        rotate = FindObjectOfType<Rotate>();
        colorChange = FindObjectOfType<ColorChange>();
        loadFromDisk = FindObjectOfType<LoadFromDisk>();
    }

    // Update is called once per frame
    void Update()
    {
        if(Shape == null)
        {
            FindShape();
        }
    }

    public void FindShape()
    {
        Shape = GameObject.FindGameObjectWithTag("shape");
        colorChange.Shape = Shape;
        rotate.Shape = Shape;
    }

    public void _SpawnObject(string name)
    {
        Debug.Log("SpawnObject Start");
        GameObject SceneObect = GameObject.FindGameObjectWithTag("shape");

        if (SceneObect == null)
        {
            Debug.Log("SpawnObject with null started");
            loadFromDisk.SpawObject(name);
            Debug.Log("SpawnObject with null finished");

        }
        if(SceneObect != null)
        {
            Debug.Log("SpawnObject without null start");
            Destroy(SceneObect.gameObject);
            loadFromDisk.SpawObject(name);
            Debug.Log("SpawnObject without null start");
        }
        Debug.Log("SpawnObject Finished");
    }
    public void clearObject(string name)
    {
     
        GameObject SceneObect = GameObject.FindGameObjectWithTag("shape");
        if(SceneObect != null)
        {
            Destroy(SceneObect.gameObject);
            rotate.SetRotationSpeed("0.0");

        }
    }
}
