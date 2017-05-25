Shader"Unity Shaders Book/Chapter 8/Alpha Text"
{
    Properties
    {
        _Color("Main Tint",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
        _Cutoff("Alpha Cutoff",Range(0,1))=0.5
    }
    SubShader
    {
       Tags{"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
       Pass
       {
           Tags{"LightMode"="ForwardBase"}
           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag

           #include"Lighting.cginc"

           //properties
           fixed4 _Color;
           sampler2D _MainTex;
           float4 _MainTex_ST;
           fixed _Cutoff;
           struct a2v
           {
               float4 vertex : POSITION;
               float3 normal : NORMAL;
               float4 texcoord : TEXCOORD0;
           };
           struct v2f
           {
               float4 pos : SV_POSITION;
               float3 worldNormal : TEXCOORD0;
               float3 worldLightDir : TEXCOORD1;
               float2 uv : TEXCOORD2;
           };
           v2f vert(a2v v)
           {
               v2f o;
               o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
               o.worldNormal = UnityObjectToWorldNormal(v.normal);
               o.worldLightDir = WorldSpaceLightDir(v.vertex).xyz;
               o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
               return o;
           }
           fixed4 frag(v2f i) : SV_Target
           {
               fixed3 worldNormal = normalize(i.worldNormal);
               fixed3 worldLightDir = normalize(i.worldLightDir);
               fixed4 texColor = tex2D(_MainTex,i.uv);

               clip(texColor.a - _Cutoff);

               fixed3 albedo = texColor.rgb * _Color.rgb;
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
               fixed3 halfLambert = 0.5 * saturate(dot(worldNormal,worldLightDir)) + 0.5;
               fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;

               return fixed4(ambient + diffuse,1.0);
           }
           ENDCG
       } 
    }
    FallBack "Transparent/Cutout/VertexLit"
}