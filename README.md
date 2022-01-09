## Zenn Shader100記事マラソン戦いの記録

Shaderの勉強記録です。  
100記事分くらい学べば私レベルの初心者でも  
まあまあ理解できるかなと思ってやりました。  

各記事とサンプルシーンを紐付けとくので参考にしたい方はどうぞお使いください。  

---

## バージョン情報
Unity 2019.4.8f1  
[DoTween](https://assetstore.unity.com/packages/tools/animation/dotween-hotween-v2-27676?locale=ja-JP) 1.2.632  

※DoTweenは各自でインポートが必要です。  

---

## 目次

<!-- TOC -->

- [Unite2017](#unite2017)
    - [キーワード - 基礎、フラグメントシェーダー、頂点シェーダー、ラスタライズ、プロパティ、半透明](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E5%9F%BA%E7%A4%8E%E3%83%95%E3%83%A9%E3%82%B0%E3%83%A1%E3%83%B3%E3%83%88%E3%82%B7%E3%82%A7%E3%83%BC%E3%83%80%E3%83%BC%E9%A0%82%E7%82%B9%E3%82%B7%E3%82%A7%E3%83%BC%E3%83%80%E3%83%BC%E3%83%A9%E3%82%B9%E3%82%BF%E3%83%A9%E3%82%A4%E3%82%BA%E3%83%97%E3%83%AD%E3%83%91%E3%83%86%E3%82%A3%E5%8D%8A%E9%80%8F%E6%98%8E)
- [Rotation2D](#rotation2d)
    - [キーワード - UV、回転、_Time、セマンティクス](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---uv%E5%9B%9E%E8%BB%A2_time%E3%82%BB%E3%83%9E%E3%83%B3%E3%83%86%E3%82%A3%E3%82%AF%E3%82%B9)
- [Mask](#mask)
    - [キーワード - マスク、clip、UV、回転、UV1、UV2](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%83%9E%E3%82%B9%E3%82%AFclipuv%E5%9B%9E%E8%BB%A2uv1uv2)
- [Slice](#slice)
    - [キーワード - スライス、mul、frac、appdata_base、ワールド座標、ローカル座標](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%82%B9%E3%83%A9%E3%82%A4%E3%82%B9mulfracappdata_base%E3%83%AF%E3%83%BC%E3%83%AB%E3%83%89%E5%BA%A7%E6%A8%99%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E5%BA%A7%E6%A8%99)
- [Scroll](#scroll)
    - [キーワード - UVスクロール、tex2D、step、lerp](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---uv%E3%82%B9%E3%82%AF%E3%83%AD%E3%83%BC%E3%83%ABtex2dsteplerp)
- [UseC](#usec)
    - [キーワード - C#連携、distance](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---c%E9%80%A3%E6%90%BAdistance)
- [CameraDistance](#cameradistance)
    - [キーワード - カメラとの距離、_WorldSpaceCameraPos、length](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%82%AB%E3%83%A1%E3%83%A9%E3%81%A8%E3%81%AE%E8%B7%9D%E9%9B%A2_worldspacecameraposlength)
- [Random](#random)
    - [キーワード - ランダム、シード値](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%83%A9%E3%83%B3%E3%83%80%E3%83%A0%E3%82%B7%E3%83%BC%E3%83%89%E5%80%A4)
- [Geometry](#geometry)
    - [キーワード - ジオメトリーシェーダー、inout、法線、外積、ベクトル、unroll、SV_PrimitiveID](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%82%B8%E3%82%AA%E3%83%A1%E3%83%88%E3%83%AA%E3%83%BC%E3%82%B7%E3%82%A7%E3%83%BC%E3%83%80%E3%83%BCinout%E6%B3%95%E7%B7%9A%E5%A4%96%E7%A9%8D%E3%83%99%E3%82%AF%E3%83%88%E3%83%ABunrollsv_primitiveid)
- [GeometryAnimation](#geometryanimation)
    - [キーワード - ジオメトリーシェーダー、Animation、Animator、C#連携](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%82%B8%E3%82%AA%E3%83%A1%E3%83%88%E3%83%AA%E3%83%BC%E3%82%B7%E3%82%A7%E3%83%BC%E3%83%80%E3%83%BCanimationanimatorc%E9%80%A3%E6%90%BA)
- [SunSky](#sunsky)
    - [キーワード - Skybox、内積、pow、ZWrite](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---skybox%E5%86%85%E7%A9%8Dpowzwrite)
- [SkyboxTest](#skyboxtest)
    - [キーワード - Skybox、歪み、atan2、asin](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---skybox%E6%AD%AA%E3%81%BFatan2asin)
- [GradationSky](#gradationsky)
    - [キーワード - Skybox、グラデーション](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---skybox%E3%82%B0%E3%83%A9%E3%83%87%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3)
- [NightSky](#nightsky)
    - [キーワード - Skybox、ボロノイ、星空](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---skybox%E3%83%9C%E3%83%AD%E3%83%8E%E3%82%A4%E6%98%9F%E7%A9%BA)
- [GradationNightSky](#gradationnightsky)
    - [キーワード - Skybox、星空、グラデーション、if文](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---skybox%E6%98%9F%E7%A9%BA%E3%82%B0%E3%83%A9%E3%83%87%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3if%E6%96%87)
- [D Ripple](#d-ripple)
    - [キーワード - 波動方程式、波紋、CustomRenderTexture](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E6%B3%A2%E5%8B%95%E6%96%B9%E7%A8%8B%E5%BC%8F%E6%B3%A2%E7%B4%8Bcustomrendertexture)
- [Tessellation](#tessellation)
    - [キーワード - 波紋、テッセレーション、ハルシェーダー、ドメインシェーダー](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E6%B3%A2%E7%B4%8B%E3%83%86%E3%83%83%E3%82%BB%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E3%83%8F%E3%83%AB%E3%82%B7%E3%82%A7%E3%83%BC%E3%83%80%E3%83%BC%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3%E3%82%B7%E3%82%A7%E3%83%BC%E3%83%80%E3%83%BC)
- [ClickRipple](#clickripple)
    - [キーワード - クリック、波紋、C#連携、CustomRenderTexture、UpdateZone](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%82%AF%E3%83%AA%E3%83%83%E3%82%AF%E6%B3%A2%E7%B4%8Bc%E9%80%A3%E6%90%BAcustomrendertextureupdatezone)
- [CollisionRipple](#collisionripple)
    - [キーワード - 衝突座標、UV、波紋](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E8%A1%9D%E7%AA%81%E5%BA%A7%E6%A8%99uv%E6%B3%A2%E7%B4%8B)
- [Dot](#dot)
    - [キーワード - 内積](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E5%86%85%E7%A9%8D)
- [Repeat](#repeat)
    - [キーワード - 繰り返し、fmod、step](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E7%B9%B0%E3%82%8A%E8%BF%94%E3%81%97fmodstep)
- [Scan](#scan)
    - [キーワード - スキャン、smoothstep、UNITY_MATRIX_V、カメラの向き、C#連携、Animator](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%82%B9%E3%82%AD%E3%83%A3%E3%83%B3smoothstepunity_matrix_v%E3%82%AB%E3%83%A1%E3%83%A9%E3%81%AE%E5%90%91%E3%81%8Dc%E9%80%A3%E6%90%BAanimator)
- [Normal](#normal)
    - [キーワード - 法線](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E6%B3%95%E7%B7%9A)
- [Diffuse](#diffuse)
    - [キーワード - 拡散反射、Diffuse、内積、Lighting.cginc、環境光](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E6%8B%A1%E6%95%A3%E5%8F%8D%E5%B0%84diffuse%E5%86%85%E7%A9%8Dlightingcginc%E7%92%B0%E5%A2%83%E5%85%89)
- [Shade](#shade)
    - [キーワード - 影、AutoLight.cginc、multi_compile_shadowcaster](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E5%BD%B1autolightcgincmulti_compile_shadowcaster)
- [Glitch](#glitch)
    - [キーワード - グリッチ、ポスタライズ、パーリンノイズ](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%82%B0%E3%83%AA%E3%83%83%E3%83%81%E3%83%9D%E3%82%B9%E3%82%BF%E3%83%A9%E3%82%A4%E3%82%BA%E3%83%91%E3%83%BC%E3%83%AA%E3%83%B3%E3%83%8E%E3%82%A4%E3%82%BA)
- [Holo](#holo)
    - [キーワード - ホログラム、RGBシフト、グリッチ、スクロール、透過](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%83%9B%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%A0rgb%E3%82%B7%E3%83%95%E3%83%88%E3%82%B0%E3%83%AA%E3%83%83%E3%83%81%E3%82%B9%E3%82%AF%E3%83%AD%E3%83%BC%E3%83%AB%E9%80%8F%E9%81%8E)
- [SwitchTexture](#switchtexture)
    - [キーワード - DoTween、Bool値、C#連携](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---dotweenbool%E5%80%A4c%E9%80%A3%E6%90%BA)
- [WorkOnImageComponent](#workonimagecomponent)
    - [キーワード - Image、頂点カラー](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---image%E9%A0%82%E7%82%B9%E3%82%AB%E3%83%A9%E3%83%BC)
- [Flag](#flag)
    - [キーワード - 旗、揺らぎ、パーリンノイズ、_Time、頂点シェーダー](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E6%97%97%E6%8F%BA%E3%82%89%E3%81%8E%E3%83%91%E3%83%BC%E3%83%AA%E3%83%B3%E3%83%8E%E3%82%A4%E3%82%BA_time%E9%A0%82%E7%82%B9%E3%82%B7%E3%82%A7%E3%83%BC%E3%83%80%E3%83%BC)
- [CellularNoise](#cellularnoise)
    - [キーワード - 水面、トゥーン調、セルラーノイズ](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E6%B0%B4%E9%9D%A2%E3%83%88%E3%82%A5%E3%83%BC%E3%83%B3%E8%AA%BF%E3%82%BB%E3%83%AB%E3%83%A9%E3%83%BC%E3%83%8E%E3%82%A4%E3%82%BA)
- [ToonWave](#toonwave)
    - [キーワード - 深度テクスチャ、_CameraDepthTexture、LinearEyeDepth](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E6%B7%B1%E5%BA%A6%E3%83%86%E3%82%AF%E3%82%B9%E3%83%81%E3%83%A3_cameradepthtexturelineareyedepth)
- [Cushion](#cushion)
    - [キーワード - 凹み、テッセレーション、CustomRenderTexture、C#連携、clamp](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E5%87%B9%E3%81%BF%E3%83%86%E3%83%83%E3%82%BB%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3customrendertexturec%E9%80%A3%E6%90%BAclamp)
- [Firework](#firework)
    - [キーワード - Particle、CustomVertexStreams](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---particlecustomvertexstreams)
- [Distortion](#distortion)
    - [キーワード - 歪み、GrabPass、深度テクスチャ、複数Pass](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E6%AD%AA%E3%81%BFgrabpass%E6%B7%B1%E5%BA%A6%E3%83%86%E3%82%AF%E3%82%B9%E3%83%81%E3%83%A3%E8%A4%87%E6%95%B0pass)
- [RichToonWave](#richtoonwave)
    - [キーワード - 歪み、GrabPass、深度テクスチャ、複数Pass、CGINCLUDEブロック、揺らぎ](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E6%AD%AA%E3%81%BFgrabpass%E6%B7%B1%E5%BA%A6%E3%83%86%E3%82%AF%E3%82%B9%E3%83%81%E3%83%A3%E8%A4%87%E6%95%B0passcginclude%E3%83%96%E3%83%AD%E3%83%83%E3%82%AF%E6%8F%BA%E3%82%89%E3%81%8E)
- [Rim](#rim)
    - [キーワード - リムライト、saturate、法線、内積](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E3%83%AA%E3%83%A0%E3%83%A9%E3%82%A4%E3%83%88saturate%E6%B3%95%E7%B7%9A%E5%86%85%E7%A9%8D)
- [HexFloor](#hexfloor)
    - [キーワード - 六角形、サイバー、カメラ、距離](#%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89---%E5%85%AD%E8%A7%92%E5%BD%A2%E3%82%B5%E3%82%A4%E3%83%90%E3%83%BC%E3%82%AB%E3%83%A1%E3%83%A9%E8%B7%9D%E9%9B%A2)

<!-- /TOC -->

---

### Unite2017

Unite2017の動画を見ながら基礎をおさらい。  

`Path：Assets/DemoScenes/Unite2017/Scenes/Unite2017`  

#### キーワード - 基礎、フラグメントシェーダー、頂点シェーダー、ラスタライズ、プロパティ、半透明  

【参考リンク】  
[そろそろShaderをやるパート1　Unite 2017の動画を見る(基礎知識～フラグメントシェーダーで色を変える)](https://zenn.dev/kento_o/articles/bc059ba41d447b65e0d1)  
[そろそろShaderをやるパート2　Unite 2017の動画を見る(頂点シェーダーで大きさを変える)](https://zenn.dev/kento_o/articles/4b3283a02475be3bfad9)  
[そろそろShaderをやるパート3　Unite 2017の動画を見る(ラスタライズ)](https://zenn.dev/kento_o/articles/ad7c061a10c966605ea3)  
[そろそろShaderをやるパート4　Unite 2017の動画を見る(プロパティ、透明度)](https://zenn.dev/kento_o/articles/23b6bd39bae86982b2a5)  

---

### Rotation2D

UVを回転。  

`Path：Assets/DemoScenes/Rotation/Scenes/Rotation2D`  

#### キーワード - UV、回転、_Time、セマンティクス  

【参考リンク】  
[そろそろShaderをやるパート5　UVを回転させる](https://zenn.dev/kento_o/articles/64c8d585924c60633342)  

---

### Mask

画像をマスク。おまけで回転も。  

`Path：Assets/DemoScenes/Mask/Scenes/Mask`  

#### キーワード - マスク、clip、UV、回転、UV1、UV2  

【参考リンク】  
[そろそろShaderをやるパート6　画像をマスクする](https://zenn.dev/kento_o/articles/6a6ebd5f70c54e43efb9)  
[そろそろShaderをやるパート7　マスクしてUVを回転させる](https://zenn.dev/kento_o/articles/580e0c58f8e3ccd67e1f)  

---

### Slice

スライスさせる。  

`Path：Assets/DemoScenes/Slice/Scenes/Slice`  

#### キーワード - スライス、mul、frac、appdata_base、ワールド座標、ローカル座標  

【参考リンク】  
[そろそろShaderをやるパート8　ピクセルのワールド座標を参照してスライスさせる](https://zenn.dev/kento_o/articles/7b0d9703928fea943882)  
[そろそろShaderをやるパート9　ピクセルのローカル座標を参照してスライスさせる](https://zenn.dev/kento_o/articles/9209e0289fa7cbc2dd16)  

---

### Scroll

スクロールさせる。  

`Path：Assets/DemoScenes/Scroll/Scenes/Scroll`  

#### キーワード - UVスクロール、tex2D、step、lerp  

【参考リンク】  
[そろそろShaderをやるパート10　UVスクロールでテクスチャをスクロールさせる](https://zenn.dev/kento_o/articles/3d11717d5ad270cfa7e9)  
[そろそろShaderをやるパート11　UVスクロールでテクスチャを用いずスクロールさせる](https://zenn.dev/kento_o/articles/03f39f49270885af6878)  
[そろそろShaderをやるパート12　線を描画してスクロールさせる](https://zenn.dev/kento_o/articles/4737b74069302045d520)  

---

### UseC#

C#のスクリプトからShaderにパラメータを渡す。  

`Path：Assets/DemoScenes/UseC#/Scenes/UseC#`  

#### キーワード - C#連携、distance  

【参考リンク】  
[そろそろShaderをやるパート13　マウスのRayの座標をC#からShaderで受け取る](https://zenn.dev/kento_o/articles/c189882b24150d5837dc)  

---

### CameraDistance

カメラとの距離を使う。  

`Path：Assets/DemoScenes/CameraDistance/Scenes/CameraDistance`  

#### キーワード - カメラとの距離、_WorldSpaceCameraPos、length  

【参考リンク】  
[そろそろShaderをやるパート14　カメラとの距離を測って使う](https://zenn.dev/kento_o/articles/d36c0f21f9197ef18ed1)  

---

### Random

ランダムな値を使う  

`Path：Assets/DemoScenes/Random/Scenes/Random`

#### キーワード - ランダム、シード値  

【参考リンク】  
[そろそろShaderをやるパート15　ランダムな値を使う](https://zenn.dev/kento_o/articles/b3465ecced630b894292)  

---

### Geometry

ジオメトリーシェーダー触ってみた。  

`Path：Assets/DemoScenes/Geometry/Scenes/Geometry`  

#### キーワード - ジオメトリーシェーダー、inout、法線、外積、ベクトル、unroll、SV_PrimitiveID  

【参考リンク】  
[そろそろShaderをやるパート16　ジオメトリーシェーダーで法線方向にポリゴンを移動させる](https://zenn.dev/kento_o/articles/c56d85a9de34238d5a6a)  
[そろそろShaderをやるパート17　ジオメトリーシェーダーでポリゴンの大きさを変える](https://zenn.dev/kento_o/articles/3f981920ed6f0450035c)  
[そろそろShaderをやるパート18　ジオメトリーシェーダーでポリゴンごとに色を変える](https://zenn.dev/kento_o/articles/8171d8eac403b981c3e8)  
[そろそろShaderをやるパート19　ジオメトリーシェーダーでポリゴンを回転させる](https://zenn.dev/kento_o/articles/33777ad34fce5fe9346f)  
[そろそろShaderをやるパート20　ジオメトリーシェーダーでポリゴンの操作を組み合わせる](https://zenn.dev/kento_o/articles/34690cda19c7e17ed660)  

---

### GeometryAnimation

ジオメトリーシェーダーをアニメーションで制御。  

`Path：Assets/DemoScenes/Geometry/Scenes/GeometryAnimation`  

#### キーワード - ジオメトリーシェーダー、Animation、Animator、C#連携  

【参考リンク】  
[そろそろShaderをやるパート21　Animator使ってジオメトリーシェーダーを制御](https://zenn.dev/kento_o/articles/44deff4b914f00eb213c)  

---

### SunSky
Skyboxで疑似的に太陽を表現。  

`Path：Assets/DemoScenes/Skybox/Scenes/SunSky`  

#### キーワード - Skybox、内積、pow、ZWrite  

【参考リンク】  
[そろそろShaderをやるパート22　Skyboxで疑似太陽](https://zenn.dev/kento_o/articles/1fa52e508edea7ad7648)  

---

### SkyboxTest
Skyboxの歪みに対応。  

`Path：Assets/DemoScenes/Skybox/Scenes/SkyboxTest`  

#### キーワード - Skybox、歪み、atan2、asin  

【参考リンク】  
[そろそろShaderをやるパート23　Skyboxの歪みに対応する](https://zenn.dev/kento_o/articles/0244a58ee2fc3821fd43)  

---

### GradationSky
Skyboxでグラデーション。  

`Path：Assets/DemoScenes/Skybox/Scenes/GradationSky`  

#### キーワード - Skybox、グラデーション  

【参考リンク】  
[そろそろShaderをやるパート24　Skyboxでグラデーション](https://zenn.dev/kento_o/articles/776c5f4a18096210c063)  

---

### NightSky
Skyboxとボロノイを組み合わせて星空を表現。  

`Path：Assets/DemoScenes/Skybox/Scenes/NightSky`  

#### キーワード - Skybox、ボロノイ、星空  

【参考リンク】  
[そろそろShaderをやるパート25　Skyboxで星空をちりばめる](https://zenn.dev/kento_o/articles/9657c594695954)  

---

### GradationNightSky
Skyboxに星をちりばめて良い感じにグラデーション。  

`Assets/DemoScenes/Skybox/Scenes/GradationNightSky`  

#### キーワード - Skybox、星空、グラデーション、if文  

【参考リンク】  
[そろそろShaderをやるパート26　Skyboxに星をちりばめて良い感じにグラデーション](https://zenn.dev/kento_o/articles/80606bbc0dc967)  

---

### 2D Ripple
波動方程式とCustomRenderTextureで波紋を描画。  

`Assets/DemoScenes/Ripple/Scenes/2DRipple`  

#### キーワード - 波動方程式、波紋、CustomRenderTexture  

【参考リンク】  
[そろそろShaderをやるパート27　波動方程式とCustomRenderTextureで波紋を描画](https://zenn.dev/kento_o/articles/300954cbd453da)  

---

### Tessellation
テッセレーションでポリゴンを自動で分割。  

`Assets/DemoScenes/Tessellation/Scenes/Tessellation`  

#### キーワード - 波紋、テッセレーション、ハルシェーダー、ドメインシェーダー  

【参考リンク】  
[そろそろShaderをやるパート28　テッセレーションで波紋表現](https://zenn.dev/kento_o/articles/730c368c3c29b2)  

---

### ClickRipple
クリックした箇所を起点に波紋を発生。  

`Assets/DemoScenes/Ripple/Scenes/ClickRipple`  

#### キーワード - クリック、波紋、C#連携、CustomRenderTexture、UpdateZone  

【参考リンク】  
[そろそろShaderをやるパート29　マウスクリックした箇所に波紋を発生させる](https://zenn.dev/kento_o/articles/4ea79fff0101a9)  

---

### CollisionRipple
オブジェクトが衝突した箇所から波紋を出す。  

`Assets/DemoScenes/Ripple/Scenes/CollisionRipple`  

#### キーワード - 衝突座標、UV、波紋  

【参考リンク】  
[そろそろShaderをやるパート30　衝突座標から波紋を発生させる](https://zenn.dev/kento_o/articles/64f758526a21a4)  

---

### Dot
内積を利用してテクスチャを塗分け。  

`Assets/DemoScenes/Dot/Scenes/Dot`  

#### キーワード - 内積  

【参考リンク】  
[そろそろShaderをやるパート31　内積を使う](https://zenn.dev/kento_o/articles/256861c7ca52ce)  

---

### Repeat
繰り返し処理を行う。  

`Assets/DemoScenes/Repeat/Scenes/Repeat`  

#### キーワード - 繰り返し、fmod、step  

【参考リンク】  
[そろそろShaderをやるパート32　繰り返し処理を行う](https://zenn.dev/kento_o/articles/5ae9f1909bf687)  

---

### Scan
空間をスキャンする表現。  

`Assets/DemoScenes/Scan/Scenes/Scan`  

#### キーワード - スキャン、smoothstep、UNITY_MATRIX_V、カメラの向き、C#連携、Animator  

【参考リンク】  
[そろそろShaderをやるパート33　空間スキャン表現](https://zenn.dev/kento_o/articles/9c9c5d61aa2829)  

---

### Normal
法線を利用して色を塗分ける。  

`Assets/DemoScenes/Normal/Scenes/Normal`  

#### キーワード - 法線  

【参考リンク】  
[そろそろShaderをやるパート34　法線を使う](https://zenn.dev/kento_o/articles/2fc138bf7b311d)  

---

### Diffuse
拡散反射。Directional Light、環境光も反映。  

`Assets/DemoScenes/Normal/Scenes/Diffuse`  

#### キーワード - 拡散反射、Diffuse、内積、Lighting.cginc、環境光  

【参考リンク】  
[そろそろShaderをやるパート35　Diffuse(拡散反射)](https://zenn.dev/kento_o/articles/b0c1b356e76adb)  

【参考リンク】  
[そろそろShaderをやるパート36　Directional Light、環境光を反映する](https://zenn.dev/kento_o/articles/185ce2b8b2895f)  

---

### Shade
影の表現。  

`Assets/DemoScenes/Normal/Scenes/Shade`  

#### キーワード - 影、AutoLight.cginc、multi_compile_shadowcaster  

【参考リンク】  
[そろそろShaderをやるパート37　影を落とす、受ける](https://zenn.dev/kento_o/articles/e858928f1c1d58)  

---

### Glitch
グリッチ表現。  

`Assets/DemoScenes/Normal/Scenes/Glitch`  

#### キーワード - グリッチ、ポスタライズ、パーリンノイズ  

【参考リンク】  
[そろそろShaderをやるパート38　グリッチ表現](https://zenn.dev/kento_o/articles/08ec03e29ed636)  

---

### Holo
ホログラム表現。  

`Assets/DemoScenes/Normal/Scenes/Holo`  

#### キーワード - ホログラム、RGBシフト、グリッチ、スクロール、透過  

【参考リンク】  
[そろそろShaderをやるパート39　グリッチによるホログラムっぽい表現](https://zenn.dev/kento_o/articles/95ffe7efa32c16)  

---

### SwitchTexture
Textureを切り替えたカードがめくれる表現。  

`Assets/DemoScenes/Normal/Scenes/SwitchTexture`  

#### キーワード - DoTween、Bool値、C#連携  

【参考リンク】  
[そろそろShaderをやるパート40　カードがめくれる表現をDoTweenと組み合わせて作る](https://zenn.dev/kento_o/articles/8574c37b80219b)  

---

### WorkOnImageComponent
Imageコンポーネント上で適切に動くShader。  

`Assets/DemoScenes/Normal/Scenes/WorkOnImageComponent`  

#### キーワード - Image、頂点カラー

【参考リンク】  
[そろそろShaderをやるパート41　Imageコンポーネントの色変更に対応したShader](https://zenn.dev/kento_o/articles/6fb06d0c1f64e5)  

---

### Flag
風でたなびく旗のような表現。  

`Assets/DemoScenes/Normal/Scenes/Flag`  

#### キーワード - 旗、揺らぎ、パーリンノイズ、_Time、頂点シェーダー

【参考リンク】  
[そろそろShaderをやるパート42　風でたなびく旗のような表現](https://zenn.dev/kento_o/articles/7acc5edcbb45cf)  

---

### CellularNoise
セルラーノイズで波打ち表現。  

`Assets/DemoScenes/Normal/Scenes/CellularNoise`  

#### キーワード - 水面、トゥーン調、セルラーノイズ

【参考リンク】  
[そろそろShaderをやるパート43　セルラーノイズでトゥーン調の波を作ってみる](https://zenn.dev/kento_o/articles/37799c671d7b0c)  

---

### ToonWave
波打ち際の表現。  

`Assets/DemoScenes/ToonWave/Scenes/ToonWave`  

#### キーワード - 深度テクスチャ、_CameraDepthTexture、LinearEyeDepth  

【参考リンク】  
[そろそろShaderをやるパート44　深度テクスチャで波打ち際の表現](https://zenn.dev/kento_o/articles/66eb17d31c2a4a)  

---

### Cushion
クッションのように凹む表現。  

`Assets/DemoScenes/Cushion/Scenes/Cushion`  

#### キーワード - 凹み、テッセレーション、CustomRenderTexture、C#連携、clamp  

【参考リンク】  
[そろそろShaderをやるパート45　クッションのような凹み表現](https://zenn.dev/kento_o/articles/2aa94236bb9b97)  

---

### Firework
ParticleからShaderへ値を渡すサンプル。花火。  

`Assets/DemoScenes/Firework/Scenes/Firework`  

#### キーワード - Particle、CustomVertexStreams  

【参考リンク】  
[そろそろShaderをやるパート46　ParticleからShaderへ値を渡す](https://zenn.dev/kento_o/articles/7dc0449b6577cd)  

---

### Distortion
水面の歪みのような表現。  

`Assets/DemoScenes/Distortion/Scenes/Distortion`  

#### キーワード - 歪み、GrabPass、深度テクスチャ、複数Pass  

【参考リンク】  
[そろそろShaderをやるパート47　水面の歪みのような表現](https://zenn.dev/kento_o/articles/6d8b80e235d099)  

---

### RichToonWave
トゥーン調の水面の表現。  

`Assets/DemoScenes/Distortion/Scenes/RichToonWave`  

#### キーワード - 歪み、GrabPass、深度テクスチャ、複数Pass、CGINCLUDEブロック、揺らぎ  


【参考リンク】  
[そろそろShaderをやるパート48　ちょっとだけリッチなトゥーン調の波を作る](https://zenn.dev/kento_o/articles/c7ec9522b3cabc)  

---

### Rim
リムライト表現。  

`Assets/DemoScenes/Rim/Scenes/Rim`  

#### キーワード - リムライト、saturate、法線、内積  

【参考リンク】  
[そろそろShaderをやるパート49　リムライト](https://zenn.dev/kento_o/articles/63ed1cb3fd069b)  

---

### HexFloor
六角形のサイバーな床の表現。  

`Assets/DemoScenes/Hex/Scenes/HexFloor`  

#### キーワード - 六角形、サイバー、カメラ、距離  

【参考リンク】  
[トそろそろShaderをやるパート50　サイバーな床の表現](https://zenn.dev/kento_o/articles/198d17395bf108)  

---