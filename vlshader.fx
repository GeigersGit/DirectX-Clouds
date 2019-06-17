Texture2D txDiffuse : register(t0);
Texture2D txDepth : register(t1);
SamplerState samLinear : register(s0);

cbuffer ConstantBuffer : register(b0) {
	matrix World;
	matrix View;
	matrix Projection;
	float4 info;
	float4 CameraPos;
};

//--------------------------------------------------------------------------------------
struct VS_INPUT {
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
	float3 Norm : NORMAL0;
};

struct PS_INPUT {
	float4 Pos : SV_POSITION;
	float2 Tex : TEXCOORD0;
	float2 LightPos : TEXCOORD1;
	float4 Norm : Normal0;
};


PS_INPUT VS(VS_INPUT input) {
	PS_INPUT output = (PS_INPUT)0;
	float4 pos = input.Pos;
	float4 lpos = info;
	//lpos = mul(lpos, World);
	
	output.Pos = pos;
	output.LightPos = lpos.xy;
	output.Tex = input.Tex;
	//lighing:
	//also turn the light normals in case of a rotation:
	output.Norm.xyz = input.Norm;
	output.Norm.w = 1;

	
	//output.LightPos = pos.xy;
	output.Pos = input.Pos;
	return output;

	return output;
}

float4 PS(PS_INPUT input) : SV_Target{
	//float3 texture_color = txDiffuse.Sample(samLinear, input.LightPos);
	//return float4(texture_color, 1);

	float decay = 0.96815;
	float exposure = 0.2;
	float density = 0.5926;
	float weight = 0.158767;
	/// NUM_SAMPLES will describe the ray's quality, you can play with it
	int NUM_SAMPLES = 50;
	float2 tc = input.Tex;
	float2 tcscreen = tc * 2 - float2(1, 1);
	float2 deltaTexCoord = (tcscreen - input.LightPos.xy);
	deltaTexCoord *= 1.0 / float(NUM_SAMPLES) * density;
	float illuminationDecay = 1.0;
	float4 color = txDiffuse.Sample(samLinear, tc)*0.4;
	color.a = 1;

	float2 tc_hold = tc;
	for (int i = 0; i < NUM_SAMPLES; i++)
	{
		tc -= deltaTexCoord;
		float4 spl = txDiffuse.Sample(samLinear, tc)*0.4;
		spl *= illuminationDecay * weight;
		color += spl;
		illuminationDecay *= decay;
	}
	return color;
}



// File: lecture 8.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
/*Texture2D txVL : register(t0);
//Texture2D txHeight : register(t1);
SamplerState samLinear : register(s0);

cbuffer ConstantBuffer : register(b0) { // can I get this down to one variable (float2)? or maybe 2 float2s?
	matrix World;
	matrix View;
	matrix Projection;
	float4 info;
	float4 CameraPos;
};

//--------------------------------------------------------------------------------------
struct VS_INPUT {
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
	float3 Norm : NORMAL0;
};

struct PS_INPUT {
	float4 Pos: SV_POSITION;
	float2 Tex : TEXCOORD0;
	float2 LightPos : TEXCOORD0;
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------

PS_INPUT VS(VS_INPUT input) {
	PS_INPUT output = (PS_INPUT)0;
	output.Tex = input.Tex;
	float4 pos = info;
	//pos = mul(pos, World);
	pos = mul(pos, View);
	pos = mul(pos, Projection);
	pos = normalize(pos);
	output.LightPos = pos.xy;
	output.Pos = input.Pos;
	return output;
}

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------

float4 PS(PS_INPUT input) : SV_Target{
	return txVL.Sample(samLinear,input.Tex);
	
	float decay = 0.96815;
	float exposure = 0.2;
	float density = 0.926;
	float weight = 0.58767;
	/// NUM_SAMPLES will describe the ray's quality, you can play with it
	int NUM_SAMPLES = 100;
	float2 tc = input.Tex;
	float2 deltaTexCoord = (tc - info.xy);
	deltaTexCoord *= 1.0 / float(NUM_SAMPLES) * density;
	float illuminationDecay = 1.0;
	float4 color = txVL.Sample(samLinear, tc)*0.4;
	for (int i = 0; i < NUM_SAMPLES; i++)
	{
		tc -= deltaTexCoord;
		float4 spl = txVL.Sample(samLinear, tc)*0.4;
		spl *= illuminationDecay * weight;
		color += spl;
		illuminationDecay *= decay;
	}
	return color;
	
}*/