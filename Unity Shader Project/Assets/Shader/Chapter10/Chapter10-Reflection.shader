﻿Shader "Unity Shaders Book/Chapter 10/Reflection"
{
	Properties
	{
	    _Color("Color Tint",Color)=(1,1,1,1)
	    _ReflectColor("Reflection Color",Color)=(1,1,1,1)
	    _ReflectAmount("Reflect Amount",Range(0,1))=1
		_Cubemap ("Reflect Cubemap", Cube) = "_Skybox" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		Pass
		{
		    Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				//float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float3 worldRefl : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				float3 worldViewDir : TEXCOORD3;
				SHADOW_COORDS(4) 
			};

			samplerCUBE _Cubemap;
			fixed4 _Color;
			fixed4 _ReflectColor;
			fixed _ReflectAmount;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldRefl = reflect(-o.worldViewDir,o.worldNormal);
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldViewDir = normalize(i.worldViewDir);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal,worldLightDir));

				fixed3 reflection = texCUBE(_Cubemap,i.worldRefl).rgb * _ReflectColor.rgb;
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				fixed3 color = ambient + lerp(diffuse,reflection,_ReflectAmount) * atten;
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
	FallBack "Reflective/VertexLit"
}