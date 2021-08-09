using UnityEngine;

/// <summary>
/// オブジェクトが衝突した箇所を凹ませる
/// </summary>
public class SnowController : MonoBehaviour
{
    [SerializeField] private CustomRenderTexture _customRenderTexture;
    [SerializeField, Range(0.001f, 0.1f)] private float _size = 0.01f;
    [SerializeField] private int _iterationPerFrame = 5;

    private CustomRenderTextureUpdateZone _defaultZone;

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

        //シミュレート用のUpdateZone
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

    //Updateはダメ　ライフサイクル要参照
    private void FixedUpdate()
    {
        //UpdateZoneはリセット
        _customRenderTexture.ClearUpdateZones();
        //更新したいフレーム数を指定して更新
        _customRenderTexture.Update(_iterationPerFrame);
    }

    private void OnTriggerStay(Collider other)
    {
        //衝突座標(ワールド座標)
        var hitPos = other.ClosestPointOnBounds(transform.position);
        //ワールド座標からローカル座標に変換
        var hitLocalPos = transform.InverseTransformPoint(hitPos);
        //pをuvに変換して代入　成功したら実行
        if (LocalPointToUV(hitLocalPos, out var uv))
        {
            Debug.Log(uv.x);
            
            if(uv.x > 0.49)
            {
                uv.x += 0.05f;
            }
            else if(uv.x < 0.5)
            {
                uv.x -= 0.05f;
            }
            
            //衝突時に使用するUpdateZone
            //衝突した箇所を更新の原点とする
            //使用するパスも衝突用に変更
            var interactiveZone = new CustomRenderTextureUpdateZone
            {
                needSwap = true,
                passIndex = 1,
                rotation = 0f,
                updateZoneCenter = new Vector2(uv.x, 1 - uv.y),
                updateZoneSize = new Vector2(_size, _size)
            };

            _customRenderTexture.SetUpdateZones(new CustomRenderTextureUpdateZone[] {_defaultZone, interactiveZone});
        }
    }

    private void OnTriggerExit(Collider other)
    {
        //クリック時のUpdateZoneがクリック後も適応された状態にならないように一度消去する
        _customRenderTexture.ClearUpdateZones();
    }

    /// <summary>
    /// 受け取ったローカル座標をUV座標に変換
    /// </summary>
    /// <param name="localPoint">任意のローカル座標</param>
    /// <param name="uv">変換後のUV座標</param>
    /// <returns>変換に成功したらTrue</returns>
    private bool LocalPointToUV(Vector3 localPoint, out Vector2 uv)
    {
        //そこまで大差ないらしいけど一応for文の外で宣言
        int index0;
        int index1;
        int index2;
        Vector3 t1;
        Vector3 t2;
        Vector3 t3;

        //Mesh内に存在する三角形を調査
        //ある点pが与えられた3点において平面上に存在するか計算
        for (var i = 0; i < _meshTriangles.Length; i += 3)
        {
            index0 = i + 0;
            index1 = i + 1;
            index2 = i + 2;

            //三角形の各頂点
            t1 = _meshVertices[_meshTriangles[index0]];
            t2 = _meshVertices[_meshTriangles[index1]];
            t3 = _meshVertices[_meshTriangles[index2]];

            //同一平面上に任意の座標が定義されているかどうかチェック
            if (!CheckInPlane(localPoint, t1, t2, t3))
                continue;
            //三角形の内部に存在するかどうか　境界面(辺の上、頂点の真上)もチェック
            if (!CheckOnTriangleEdge(localPoint, t1, t2, t3) && !CheckInTriangle(localPoint, t1, t2, t3))
                continue;

            //三角形の各頂点のUVを取得
            var uv1 = _meshUV[_meshTriangles[index0]];
            var uv2 = _meshUV[_meshTriangles[index1]];
            var uv3 = _meshUV[_meshTriangles[index2]];
            //UV座標に変換
            uv = CalculateUV(localPoint, t1, uv1, t2, uv2, t3, uv3);
            return true;
        }

        uv = default(Vector3);
        return false;
    }

    /// <summary>
    /// 同一平面上に任意の座標が定義されているかどうか判定
    /// </summary>
    /// <param name="p">調査対象の座標</param>
    /// <param name="t1">三角形ポリゴンの頂点座標1</param>
    /// <param name="t2">三角形ポリゴンの頂点座標2</param>
    /// <param name="t3">三角形ポリゴンの頂点座標3</param>
    /// <returns>同一平面上に任意の座標が定義されていたらTrue</returns>
    private bool CheckInPlane(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
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
    /// <param name="t2">三角形ポリゴンの頂点座標2</param>
    /// <param name="t3">三角形ポリゴンの頂点座標3</param>
    /// <returns>同一平面上に存在する任意の座標が三角形内部に存在していたらTrue</returns>
    private bool CheckInTriangle(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
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
    /// <returns>UV座標</returns>
    private Vector2 CalculateUV(Vector3 p, Vector3 t1, Vector2 t1UV, Vector3 t2, Vector2 t2UV, Vector3 t3, Vector2 t3UV)
    {
        //メインカメラ取得
        var renderCamera = Camera.main;
        //プロジェクション変換一歩手前のMVP行列 = プロジェクション行列 * ビュー行列 * モデル行列
        Matrix4x4 mvp = renderCamera.projectionMatrix * renderCamera.worldToCameraMatrix * transform.localToWorldMatrix;
        //各点をプロジェクション空間へ変換
        Vector4 p1_p = mvp * new Vector4(t1.x, t1.y, t1.z, 1);
        Vector4 p2_p = mvp * new Vector4(t2.x, t2.y, t2.z, 1);
        Vector4 p3_p = mvp * new Vector4(t3.x, t3.y, t3.z, 1);
        Vector4 p_p = mvp * new Vector4(p.x, p.y, p.z, 1);
        //Wで除算することでプロジェクション座標変換は完了する
        //Shaderでは勝手にやってくれるらしいが、今回は自分でやる　透視変換というらしい
        //Z(深度)は破棄
        Vector2 p1_n = new Vector2(p1_p.x, p1_p.y) / p1_p.w;
        Vector2 p2_n = new Vector2(p2_p.x, p2_p.y) / p2_p.w;
        Vector2 p3_n = new Vector2(p3_p.x, p3_p.y) / p3_p.w;
        Vector2 p_n = new Vector2(p_p.x, p_p.y) / p_p.w;
        //頂点のなす三角形を点pにより3分割し、必要になる面積を計算
        //三角形を二分割して底辺×高さを計算した後に÷2してる
        var s = ((p2_n.x - p1_n.x) * (p3_n.y - p1_n.y) - (p2_n.y - p1_n.y) * (p3_n.x - p1_n.x)) / 2; //全体
        var s1 = ((p3_n.x - p_n.x) * (p1_n.y - p_n.y) - (p3_n.y - p_n.y) * (p1_n.x - p_n.x)) / 2; //分割した一部
        var s2 = ((p1_n.x - p_n.x) * (p2_n.y - p_n.y) - (p1_n.y - p_n.y) * (p2_n.x - p_n.x)) / 2; //分割した一部
        //面積比からuvを補間 
        var u = s1 / s;
        var v = s2 / s;
        //パースペクティブコレクトを適用しつつ、面積比で任意のUV座標を求める
        var areaRatio = (1 - u - v) * 1 / p1_p.w + u * 1 / p2_p.w + v * 1 / p3_p.w;
        return ((1 - u - v) * t1UV / p1_p.w + u * t2UV / p2_p.w + v * t3UV / p3_p.w) / areaRatio;
    }

    /// <summary>
    /// 三角形ポリゴンの各辺の上に座標があるかどうか判定
    /// </summary>
    /// <param name="p">Points to investigate.</param>
    /// <param name="t1">三角形ポリゴンの頂点座標1</param>
    /// <param name="t2">三角形ポリゴンの頂点座標2</param>
    /// <param name="t3">三角形ポリゴンの頂点座標3</param>
    /// <returns>三角形ポリゴンの各辺の上に座標があればTrue</returns>
    private bool CheckOnTriangleEdge(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
    {
        return CheckOnEdge(p, t1, t2) || CheckOnEdge(p, t2, t3) || CheckOnEdge(p, t3, t1);
    }

    /// <summary>
    /// 境界面(頂点)のチェック
    /// </summary>
    /// <param name="p">調査対象の座標</param>
    /// <param name="v1">頂点座標1</param>
    /// <param name="v2">頂点座標2</param>
    /// <returns>調査対象の座標が境界上にあればTrue</returns>
    private bool CheckOnEdge(Vector3 p, Vector3 v1, Vector3 v2)
    {
        return 1 - TOLERANCE < Vector3.Dot((v2 - p).normalized, (v2 - v1).normalized);
    }
}