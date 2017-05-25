Shader"Unity Shaders Book/Chapter 8/Alpha Test Both Sided"
{
    Properties
    {
        _Color("Color Tint",Color)=(1,1,1,1)
        _MainTex("Mian Tex",2D)="white"{}
        _AlphaScale("Alpha Scale",Range(0,1))=0.5
    }
    SubShader
    {
        Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            Cull Front
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            //Preperties
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldnormal : TEXCOORD1;
                float3 worldlightdir : TEXCOORD2;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                o.worldnormal = UnityObjectToWorldNormal(v.vertex).xyz;
                o.worldlightdir = WorldSpaceLightDir(v.vertex).xyz;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldnormal);
                fixed3 worldLightDir = normalize(i.worldlightdir);
                fixed4 texColor = tex2D(_MainTex,i.uv);
                //clip(texColor.a - _AlphaScale);
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 halfLambert = 0.5*saturate(dot(worldNormal,worldLightDir))+0.5;
                fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;
                return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
            }
            ENDCG
        }
         Pass
        {
            Tags{"LightMode"="ForwardBase"}
            Cull Back
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            //Preperties
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldnormal : TEXCOORD1;
                float3 worldlightdir : TEXCOORD2;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                o.worldnormal = UnityObjectToWorldNormal(v.vertex).xyz;
                o.worldlightdir = WorldSpaceLightDir(v.vertex).xyz;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldnormal);
                fixed3 worldLightDir = normalize(i.worldlightdir);
                fixed4 texColor = tex2D(_MainTex,i.uv);
                //clip(texColor.a - _AlphaScale);
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 halfLambert = 0.5*saturate(dot(worldNormal,worldLightDir))+0.5;
                fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;
                return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
    FallBack"Transpatent/VertexLit"
}