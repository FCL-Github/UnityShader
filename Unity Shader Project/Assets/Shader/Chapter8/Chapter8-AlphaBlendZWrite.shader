Shader"Unity Shaders Book/Chapter 8/Alpha Blend"
{
    Properties
    {
        _Color("Main Tint",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
        _AlphaScale("Alpha Scale",Range(0,1))=1
    }
    SubShader
    {
       Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
       Pass
       {
           
           ZWrite On
           ColorMask 0
       }
       Pass
       {
           Tags{"LightMode"="ForwardBase"}
           //Cull Off
           ZWrite Off
           Blend SrcAlpha OneMinusSrcAlpha
           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag

           #include"Lighting.cginc"

           //properties
           fixed4 _Color;
           sampler2D _MainTex;
           float4 _MainTex_ST;
           fixed _AlphaScale;
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

               fixed3 albedo = texColor.rgb * _Color.rgb;
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
               fixed3 halfLambert = 0.5 * saturate(dot(worldNormal,worldLightDir)) + 0.5;
               fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;

               return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
           }
           ENDCG
       } 
    }
    FallBack "Diffuse"
}