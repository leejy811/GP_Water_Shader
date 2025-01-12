using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderDepth : MonoBehaviour
{
    public Shader curShader;

    [Range(0.0f, 1.0f)]
    public float refractionPower = 0.05f;

    [Range(0.0f, 1.0f)]
    public float refractionSpeed = 0.1f;

    [Range(0.0f, 1.0f)]
    public float depthPower = 0.2f;

    public Color waterColor;
    public Texture2D refractionTex;

    private Material screenMat;
    public Material ScreenMat
    {
        get
        {
            if (screenMat == null)
            {
                screenMat = new Material(curShader);
                screenMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return screenMat;
        }
    }

    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }
        if (!curShader && !curShader.isSupported)
        {
            enabled = false;
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (curShader != null)
        {
            ScreenMat.SetFloat("_RefractionPower", refractionPower);
            ScreenMat.SetFloat("_RefractionSpeed", refractionSpeed);
            ScreenMat.SetFloat("_DepthPower", depthPower);
            ScreenMat.SetColor("_WaterColor", waterColor);
            ScreenMat.SetTexture("_RefractionTex", refractionTex);
            Graphics.Blit(sourceTexture, destTexture, ScreenMat);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }

    void Update()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        depthPower = Mathf.Clamp(depthPower, 0, 1);
    }
}
