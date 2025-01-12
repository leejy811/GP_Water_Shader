using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogController : MonoBehaviour
{
    public bool isFogOnOff = false;
    public Color fogColor;
    public float density;

    private void Start()
    {
        RenderSettings.fogMode = UnityEngine.FogMode.ExponentialSquared;
        RenderSettings.fogDensity = density;
    }

    private void Update()
    {
        RenderSettings.fog = isFogOnOff;
    }
}
