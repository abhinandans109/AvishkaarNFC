using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlutterManager : MonoBehaviour
{
    GameManager gameManager;


    void Start()
    {
        gameManager = FindObjectOfType<GameManager>();

    }

    // Update is called once per frame
    void Update()
    {
    
    }

    public void FindShape()
    {
        gameManager.FindShapeInScene();
    }

    public void SpawnObject(string name)
    {
        gameManager.SpawnObjectFromBundle(name);
    }

    public void LoadScene(string name)
    {
        gameManager.LoadSceneFromBundle(name);
    }

    public void ChangeColorShape(string color)
    {
        gameManager.ChangeColor(color);
    }

    public void SetRotationSpeed(string value)
    {
        gameManager.SetrotationS(value);
    }

}
