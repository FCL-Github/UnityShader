Shader"Unity Shaders Book/Chapter 9/Shadow"
{
    Properties
    {
        //_Color("Color Iint",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20
    }
    SubShader
    {
         Tags { "RenderType"="Opaque" }
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include"Lighting.cginc"
             #include "AutoLight.cginc"
            //properties
            //fixed4 _Color;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;

            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldnormal : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
                SHADOW_COORDS(2)
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
                o.worldnormal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex).xyz;
                TRANSFER_SHADOW(o);
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldnormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0);
                fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                fixed shadow = SHADOW_ATTENUATION(i);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 halfBlinn = normalize(worldLightDir + worldViewDir);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldViewDir,worldLightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfBlinn)),_Gloss);
                fixed atten=1.0;
                return fixed4(ambient+(diffuse + specular)*atten * shadow,1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag

            #include"Lighting.cginc"
            #include "AutoLight.cginc"
          //properties
            //fixed4 _Color;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;

            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldnormal : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
            };
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
                o.worldnormal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex).xyz;
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldnormal);
                fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                //fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPosition.xyz);
                #endif

                fixed3 halfBlinn = normalize(worldLightDir + worldViewDir);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldViewDir,worldLightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfBlinn)),_Gloss);
               #ifdef USING_DIRECTIONAL_LIGHT
                    fixed atten = 1.0;
                #else
                    float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPosition,1)).xyz;
                    fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord)).UNITY_ATTEN_CHANNEL;
                #endif
                return fixed4((diffuse + specular)*atten,1.0);
            }
            ENDCG
        }
    }
    FallBack"Specular"
}