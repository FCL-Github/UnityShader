Shader "Unity Shaders Book/Chapter 9/AlphaTestWithShadow"
{
	Properties
	{
	    _Color("Color Tint",Color)=(1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Diffuse",Color)=(1,1,1,1)
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8,256))=20
		_Cutoff("Alpha Cutoff",Range(0,1))=0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
		   Tags{"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include"Lighting.cginc"
			#include"AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			float _Cutoff;
			struct appdata
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
				float4 pos : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			    fixed3 worldNormal = normalize(i.worldNormal);
			    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			    fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				// sample the texture
				fixed4 texColor = tex2D(_MainTex, i.uv);
			    clip(texColor.a - _Cutoff);

			    fixed3 albedo = texColor.rgb * _Color.rgb;
			    UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

			    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
			    fixed3 halfBlinn = normalize(worldLightDir + worldViewDir);
			    fixed3 specular= _LightColor0.rgb * albedo * pow(saturate(dot(worldNormal,halfBlinn)),_Gloss);
				return fixed4(ambient+(diffuse + specular)*atten,1.0);
			}
			ENDCG
		}
	}
	Fallback "Transparent/Cutout/VertexLit"
}
