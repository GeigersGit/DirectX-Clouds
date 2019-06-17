//--------------------------------------------------------------------------------------
// File: lecture 8.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
Texture2D txDiffuse : register( t0 );
Texture2D txnormal : register(t1);
SamplerState samLinear : register( s0 );

cbuffer ConstantBuffer : register( b0 )
{
matrix World;
matrix View;
matrix Projection;
float4 info;
float4 CameraPos;
};



//--------------------------------------------------------------------------------------
struct VS_INPUT
{
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
	float3 Norm : NORMAL0;//here
};

struct PS_INPUT
{
    float4 Pos : SV_POSITION;
    float2 Tex : TEXCOORD0;
	float3 WorldPos : TEXCOORD1;
	float4 Norm : Normal0;

};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT input )
{
    PS_INPUT output = (PS_INPUT)0;
    //output.Pos = mul( input.Pos, World );
	output.Pos = input.Pos;
	//output.WorldPos = output.Pos;
	//output.Pos = mul( output.Pos, View );
    //output.Pos = mul( output.Pos, Projection );
    output.Tex = input.Tex;
    
    return output;
}

float4 PS_bright(PS_INPUT input) : SV_Target{
	float4 glowsum = float4(0, 0, 0, 0);
	glowsum = txDiffuse.SampleLevel(samLinear, input.Tex, 0);
	glowsum *= sqrt(glowsum.x * glowsum.x + glowsum.y * glowsum.y + glowsum.z * glowsum.z);
	glowsum.a = 1;
	glowsum = saturate(glowsum);
	return glowsum;
}

float4 PS_bloom(PS_INPUT input) : SV_Target
{
	float4 texture_color = txDiffuse.Sample(samLinear, input.Tex);
	float3 color = texture_color.rgb;

	/*float pixelLuminance = max(dot(color, float3(0.299f, 0.587f, 0.114f)), 0.0001f);
	float toneMappedLuminance = log10(1 + pixelLuminance) / log10(1 + 5.0);
	color = toneMappedLuminance * pow(color / pixelLuminance, 1);
	float4 tonemap = float4(color.r, color.g, color.b, 1); */

	float pixelLuminance = max(dot(color, float3(0.299f, 0.587f, 0.114f)), 0.0001f);
	float toneMappedLuminance = pixelLuminance / (pixelLuminance + 1);
	color = toneMappedLuminance * pow(color / pixelLuminance, 1);
	float4 tonemap = float4(color.r, color.g, color.b, 1);
		//return tonemap;
		tonemap /= 4;
		float4 total = float4(0, 0, 0, 0);
		//float BlurWeights[25];
		float weight = 20;
	float t = 0.002;

	for (int i = -2; i <= 2; i++) {
		for (int j = -2; j <= 2; j++) {
			float power = pow(i, 2) + pow(j, 2);
			power = power / (2.0 * pow(weight, 2));
			float constant = 1.0 / (2.0 * 3.14159265 * pow(weight, 2));
			float gaussian = constant * exp(-power);

			total += (gaussian * txnormal.SampleLevel(samLinear, input.Tex + float2(j * t, i * t), 0));
			total += (gaussian * txnormal.SampleLevel(samLinear, input.Tex + float2(j * t, i * t), 1));
			total += (gaussian * txnormal.SampleLevel(samLinear, input.Tex + float2(j * t, i * t), 2));
			total += (gaussian * txnormal.SampleLevel(samLinear, input.Tex + float2(j * t, i * t), 3));
		}
	}
	total.a = 1;
	//return float4(0, 0, 0, 1);
	return (total * weight) + tonemap;
}
