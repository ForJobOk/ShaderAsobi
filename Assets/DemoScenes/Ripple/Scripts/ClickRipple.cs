﻿using UnityEngine;

public class ClickRipple : MonoBehaviour
{
    [SerializeField] CustomRenderTexture texture;

    [SerializeField] int iterationPerFrame = 5;

    void Start()
    {
        texture.Initialize();
    }

    void Update()
    {
        texture.ClearUpdateZones();
        UpdateZones();
        texture.Update(iterationPerFrame);
    }

    void UpdateZones()
    {
        bool leftClick = Input.GetMouseButton(0);
        if (!leftClick) return;

        RaycastHit hit;
        var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Physics.Raycast(ray, out hit))
        {
            var defaultZone = new CustomRenderTextureUpdateZone();
            defaultZone.needSwap = true;
            defaultZone.passIndex = 0;
            defaultZone.rotation = 0f;
            defaultZone.updateZoneCenter = new Vector2(0.5f, 0.5f);
            defaultZone.updateZoneSize = new Vector2(1f, 1f);


            Debug.Log("hit");
            var clickZone = new CustomRenderTextureUpdateZone();
            clickZone.needSwap = true;
            clickZone.passIndex = 1;
            clickZone.rotation = 0f;
            clickZone.updateZoneCenter = new Vector2(hit.textureCoord.x, 1f - hit.textureCoord.y);
            clickZone.updateZoneSize = new Vector2(0.01f, 0.01f);

            texture.SetUpdateZones(new CustomRenderTextureUpdateZone[] {defaultZone, clickZone});
        }
    }
}