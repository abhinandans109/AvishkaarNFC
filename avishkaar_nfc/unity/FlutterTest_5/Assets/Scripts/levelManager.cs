using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class levelManager : MonoBehaviour
{
    public GameObject Player;

    GameManager gameManager;

    // Start is called before the first frame update

    private void Start()
    {
        gameManager = FindObjectOfType<GameManager>();
    }

    public void SetupScene()
    {
       
      //  Player = null; 
        StartCoroutine(SceneSetup());
    }

    IEnumerator SceneSetup()
    {
        Player = null;
       // Debug.Log("Setting Scene");
            while(Player == null)
            {
                FindPayer();
                yield return null;
            }
      //  Debug.Log("Setting Scene DONE");
    }

    public void FindPayer()
    {
        Player = GameObject.FindGameObjectWithTag("Shapes");
        gameManager.SetPlayer(Player);
        //Debug.Log("Player found" + Player.name);
            
    }

    void AddScriptsToPlayer(GameObject go)
    {
        go.AddComponent<ColorChange>();
        go.AddComponent<Rotate>();

    }



}
