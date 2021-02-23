using System;
using UnityEngine;

/// <summary>
/// オブジェクトが衝突した箇所に波紋を発生させる
/// </summary>
public class CollisionRipple : MonoBehaviour
{
    [SerializeField] private CustomRenderTexture _customRenderTexture;
    [SerializeField, Range(0.01f, 0.05f)] private float _ripppleSize = 0.01f;
    [SerializeField] private int iterationPerFrame = 5;
    
    private CustomRenderTextureUpdateZone _defaultZone;
    private Texture2D _texture2D;
    
    private const float TOLERANCE = 1E-2f;
    private int[] _meshTriangles;
    private Vector3[] _meshVertices;
    private Vector2[] _meshUV;
    private MeshFilter _meshFilter;

    private void Start()
    {
        _meshFilter = GetComponent<MeshFilter>();
        _meshTriangles = _meshFilter.mesh.triangles;
        _meshVertices = _meshFilter.mesh.vertices;
        _meshUV = _meshFilter.mesh.uv;
        
        //初期化
        _customRenderTexture.Initialize();

        //波動方程式のシミュレート用のUpdateZone
        //全体の更新用
        _defaultZone = new CustomRenderTextureUpdateZone
        {
            needSwap = true,
            passIndex = 0,
            rotation = 0f,
            updateZoneCenter = new Vector2(0.5f, 0.5f),
            updateZoneSize = new Vector2(1f, 1f)
        };
    }

    private void Update()
    {
        //更新したいフレーム数を指定して更新
        _customRenderTexture.Update(iterationPerFrame);
    }

    /// <summary>
    /// Convert local-space point to texture coordinates.
    /// </summary>
    /// <param name="localPoint">Local-Space Point</param>
    /// <param name="matrixMVP">World-View-Projection Transformation matrix.</param>
    /// <param name="uv">UV coordinates after conversion.</param>
    /// <returns>Whether the conversion was successful.</returns>
    private bool LocalPointToUV(Vector3 localPoint, Matrix4x4 matrixMVP, out Vector2 uv)
    {
        int index0;
        int index1;
        int index2;
        Vector3 t1;
        Vector3 t2;
        Vector3 t3;
        Vector3 p = localPoint;
        
        for(var i = 0; i < _meshTriangles.Length; i += 3)
        {
            //ある点pが与えられた3点において平面上に存在するか
            index0 = i + 0;
            index1 = i + 1;
            index2 = i + 2;

            t1 = _meshVertices[_meshTriangles[index0]];
            t2 = _meshVertices[_meshTriangles[index1]];
            t3 = _meshVertices[_meshTriangles[index2]];

            //同一平面上に任意の座標が定義されているかどうかチェック
            if(!ExistPointInPlane(p, t1, t2, t3))
                continue;
            //境界面(辺の上、頂点の真上)もチェック
            if(!ExistPointOnTriangleEdge(p, t1, t2, t3) && !ExistPointInTriangle(p, t1, t2, t3))
                continue;

            var uv1 = _meshUV[_meshTriangles[index0]];
            var uv2 = _meshUV[_meshTriangles[index1]];
            var uv3 = _meshUV[_meshTriangles[index2]];
            uv = TextureCoordinateCalculation(p, t1, uv1, t2, uv2, t3, uv3, matrixMVP);
            Debug.Log(uv);
            return true;
        }
        uv = default(Vector3);
        return false;
    }

    /// <summary>
    /// 同一平面上に任意の座標が定義されているかどうか判定
    /// 与えられるメッシュが三角形ポリゴンの集合で表現されていることを仮定
    /// </summary>
    /// <param name="p">調査対象の座標</param>
    /// <param name="t1">三角形ポリゴンの頂点座標1</param>
    /// <param name="t2">三角形ポリゴンの頂点座標1</param>
    /// <param name="t3">三角形ポリゴンの頂点座標1</param>
    /// <returns>同一平面上に任意の座標が定義されていたらTrue</returns>
    private bool ExistPointInPlane(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
    {
        //各点同士の成すベクトルを計算
        var v1 = t2 - t1;
        var v2 = t3 - t1;
        var vp = p - t1;

        //外積により三角形ポリゴンの頂点の法線方向を算出
        var nv = Vector3.Cross(v1, v2);
        //内積による判定　同一平面である場合、計算結果は0
        var val = Vector3.Dot(nv.normalized, vp.normalized);
        //計算の誤差を許容するための判定
        if (-TOLERANCE < val && val < TOLERANCE)
        {
            return true;
        }
         
        return false;
    }
    
    /// <summary>
    /// 同一平面上に存在する任意の座標が三角形内部に存在するかどうか
    /// 境界面(辺の上、頂点の真上)は判定外
    /// </summary>
    /// <param name="p">調査対象の座標</param>
    /// <param name="t1">三角形ポリゴンの頂点座標1</param>
    /// <param name="t2">三角形ポリゴンの頂点座標1</param>
    /// <param name="t3">三角形ポリゴンの頂点座標1</param>
    /// <returns>同一平面上に存在する任意の座標が三角形内部に存在していたらTrue</returns>
    private bool ExistPointInTriangle(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
    {
        //外積により三角形ポリゴンの各頂点の法線方向を算出
        var a = Vector3.Cross(t1 - t3, p - t1).normalized;
        var b = Vector3.Cross(t2 - t1, p - t2).normalized;
        var c = Vector3.Cross(t3 - t2, p - t3).normalized;

        //内積を利用して法線方向が同じ向きかどうか計算　同じ向きなら1
        var d_ab = Vector3.Dot(a, b);
        var d_bc = Vector3.Dot(b, c);
        
        //計算の誤差を許容するための判定
        if (1 - TOLERANCE < d_ab && 1 - TOLERANCE < d_bc)
        {
            return true;
        }
           
        return false;
    }
    
    /// <summary>
    /// 座標の情報からUV座標を算出する
    /// </summary>
    /// <param name="p">調査対象の座標</param>
    /// <param name="t1">三角形ポリゴンの頂点座標1</param>
    /// <param name="t1UV">三角形ポリゴンの頂点のUV座標1</param>
    /// <param name="t2">三角形ポリゴンの頂点座標2</param>
    /// <param name="t2UV">三角形ポリゴンの頂点のUV座標2</param>
    /// <param name="t3">三角形ポリゴンの頂点座標3</param>
    /// <param name="t3UV">三角形ポリゴンの頂点のUV座標3</param>
    /// <param name="transformMatrix">MVP transformation matrix.</param>
    /// <returns>UV coordinates of the point to be investigated.</returns>
    private Vector2 TextureCoordinateCalculation(Vector3 p, Vector3 t1, Vector2 t1UV, Vector3 t2, Vector2 t2UV, Vector3 t3, Vector2 t3UV, Matrix4x4 transformMatrix)
    {
        //各点をProjectionSpaceへの変換
        Vector4 p1_p = transformMatrix * new Vector4(t1.x, t1.y, t1.z, 1);
        Vector4 p2_p = transformMatrix * new Vector4(t2.x, t2.y, t2.z, 1);
        Vector4 p3_p = transformMatrix * new Vector4(t3.x, t3.y, t3.z, 1);
        Vector4 p_p = transformMatrix * new Vector4(p.x, p.y, p.z, 1);
        //通常座標への変換(ProjectionSpace)
        Vector2 p1_n = new Vector2(p1_p.x, p1_p.y) / p1_p.w;
        Vector2 p2_n = new Vector2(p2_p.x, p2_p.y) / p2_p.w;
        Vector2 p3_n = new Vector2(p3_p.x, p3_p.y) / p3_p.w;
        Vector2 p_n = new Vector2(p_p.x, p_p.y) / p_p.w;
        //頂点のなす三角形を点pにより3分割し、必要になる面積を計算
        var s = 0.5f * ((p2_n.x - p1_n.x) * (p3_n.y - p1_n.y) - (p2_n.y - p1_n.y) * (p3_n.x - p1_n.x));
        var s1 = 0.5f * ((p3_n.x - p_n.x) * (p1_n.y - p_n.y) - (p3_n.y - p_n.y) * (p1_n.x - p_n.x));
        var s2 = 0.5f * ((p1_n.x - p_n.x) * (p2_n.y - p_n.y) - (p1_n.y - p_n.y) * (p2_n.x - p_n.x));
        //面積比からuvを補間
        var u = s1 / s;
        var v = s2 / s;
        var w = 1 / ((1 - u - v) * 1 / p1_p.w + u * 1 / p2_p.w + v * 1 / p3_p.w);
        
        return w * ((1 - u - v) * t1UV / p1_p.w + u * t2UV / p2_p.w + v * t3UV / p3_p.w);
    }
    
   
    
    /// <summary>
    /// 三角形ポリゴンの各辺の上に座標があるかどうか判定
    /// </summary>
    /// <param name="p">Points to investigate.</param>
    /// <param name="t1">Vertex of triangle.</param>
    /// <param name="t2">Vertex of triangle.</param>
    /// <param name="t3">Vertex of triangle.</param>
    /// <returns>Whether points lie on the sides of the triangle.</returns>
    private bool ExistPointOnTriangleEdge(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
    {
        return ExistPointOnEdge(p, t1, t2) || ExistPointOnEdge(p, t2, t3) || ExistPointOnEdge(p, t3, t1);
    }
    
    /// <summary>
    /// 境界面(頂点)のチェック
    /// </summary>
    /// <param name="p">調査対象の座標</param>
    /// <param name="v1">三角形ポリゴンの頂点座標1</param>
    /// <param name="v2">三角形ポリゴンの頂点座標1</param>
    /// <returns>調査対象の座標が境界上にあればTrue</returns>
    private bool ExistPointOnEdge(Vector3 p, Vector3 v1, Vector3 v2)
    {
        return 1 - TOLERANCE < Vector3.Dot((v2 - p).normalized, (v2 - v1).normalized);
    }

    private void OnTriggerStay(Collider other)
    {
        //UpdateZoneがクリック後も適応された状態にならないように一度消去する
        _customRenderTexture.ClearUpdateZones();
        
        var hitPos = other.ClosestPointOnBounds(this.transform.position);
        var renderCamera = Camera.main;
        
        Vector3 p = transform.InverseTransformPoint(hitPos);
        Matrix4x4 mvp = renderCamera.projectionMatrix * renderCamera.worldToCameraMatrix * transform.localToWorldMatrix;
        LocalPointToUV(p, mvp, out var uv);
        
        //クリック時に使用するUpdateZone
        //クリックした箇所を更新の原点とする
        //使用するパスもクリック用に変更
        var clickZone = new CustomRenderTextureUpdateZone
        {
            needSwap = true,
            passIndex = 1,
            rotation = 0f,
            updateZoneCenter = new Vector2(uv.x,1- uv.y),
            updateZoneSize = new Vector2(_ripppleSize, _ripppleSize)
        };

        _customRenderTexture.SetUpdateZones(new CustomRenderTextureUpdateZone[] {_defaultZone, clickZone});
    }
    
    private void OnTriggerExit(Collider other)
    {
        //クリック時のUpdateZoneがクリック後も適応された状態にならないように一度消去する
        _customRenderTexture.ClearUpdateZones();
    }
}