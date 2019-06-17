//--------------------------------------------------------------------------------------
// File: lecture 8.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------
//o
//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
Texture2D txDiffuse : register(t0);
Texture2D txHeight : register(t1);
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
	float3 WorldPos : TEXCOORD1;
	float4 Norm : Normal0;
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------

PS_INPUT VS(VS_INPUT input) {
	PS_INPUT output = (PS_INPUT)0;
	float4 pos = input.Pos;
	if (info.y == 1) {
		pos.y += 100 * txHeight.SampleLevel(samLinear, input.Tex, 0).r;
		float step = 1;
		float h = 100 * txHeight.SampleLevel(samLinear, input.Tex, 0).r;
		float hNE = 100 * txHeight.SampleLevel(samLinear, input.Tex, float2(step, step), 0).r;
		float hNN = 100 * txHeight.SampleLevel(samLinear, input.Tex, float2(0, step), 0).r;
		float hNW = 100 * txHeight.SampleLevel(samLinear, input.Tex, float2(-step, step), 0).r;
		float hWW = 100 * txHeight.SampleLevel(samLinear, input.Tex, float2(-step, 0), 0).r;
		float hSW = 100 * txHeight.SampleLevel(samLinear, input.Tex, float2(-step, -step), 0).r;
		float hSS = 100 * txHeight.SampleLevel(samLinear, input.Tex, float2(0, -step), 0).r;
		float hSE = 100 * txHeight.SampleLevel(samLinear, input.Tex, float2(step, -step), 0).r;
		float hEE = 100 * txHeight.SampleLevel(samLinear, input.Tex, float2(step, 0), 0).r;
		float3 N;
		N.x = 500 * -(hSE - hSW + 2 * (hEE - hWW) + hNE - hNW); // x
		N.y = 400;
		N.z = 500 * -(hNW - hSW + 2 * (hNN - hSS) + hNE - hSE); // z
		N = normalize(N);
		output.Norm = (N, 1);
	}
	else output.Norm = float4(input.Norm,1);

	pos = mul(pos, World);
	output.Pos = mul(pos, View);
	output.Pos = mul(output.Pos, Projection);
	output.Tex = input.Tex;
	output.WorldPos = pos;

	return output;
}

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------

float4 PSscene(PS_INPUT input) : SV_Target
{
	float4 color = txDiffuse.Sample(samLinear, input.Tex);
	color.rgb = float3(0, 0, 0);
	color.a = pow(color.a, 0.4);
	return color;

}

float4 PSsun(PS_INPUT input) : SV_Target
	{
	float4 color = txDiffuse.Sample(samLinear, input.Tex);
	color.a = color.r;
	return color;
	}
