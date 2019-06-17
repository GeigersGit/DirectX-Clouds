//--------------------------------------------------------------------------------------
// File: Tutorial07.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------

SamplerState Sampler : register(s0);
SamplerState SamplerNone : register(s1);

Texture3D Vocel_GI : register(t5);


cbuffer ConstantBuffer : register(b0)
{
	matrix World;
	matrix View;
	matrix Projection;
	float4 info;
};



//--------------------------------------------------------------------------------------
// Structs fuer Geometry Shader
//--------------------------------------------------------------------------------------
//define the vertex shader input struct 

struct VS_INPUT
{
	float4 Position : POSITION;
	float2 Tex : TEXCOORD0;
	float3 Norm : NORMAL0;//here
};


//define the vertex shader output struct 
struct VS_OUTPUT
{
	float4 Position : SV_POSITION;
	float4 color   : COLOR;
};
//--------------
// VERTEX SHADER 
//------------
VS_OUTPUT VS(VS_INPUT vsInput)
{
	VS_OUTPUT vsOutput = (VS_OUTPUT)0;
	vsOutput.Position = vsInput.Position;
	vsOutput.color.r = 1;
	vsOutput.color.g = 0;
	vsOutput.color.b = 0;
	vsOutput.color.a = 1;
	return vsOutput;
}
//---------
// GEOMETRY SHADER
//---------
//  input topology    size of input array           comments
//  point             1                             a single vertex of input geometry
//  line              2                             two adjacent vertices
//  triangle          3                             three vertices of a triangle
//  lineadj           4                             two vertices defining a line segment, as well as vertices adjacent to the segment end points
//  triangleadj       6                             describes a triangle as well as 3 surrounding triangles

//  output topology        comments
//  PointStream            output is interpreted as a series of disconnected points
//  LineStream             each vertex in the list is connected with the next by a line segment
//  TriangleStream         the first 3 vertices in the stream will become the first triangle; any additional vertices become additional triangles (when combined with the previous 2)
float3 re_voxelspace(float3 worldpos)
	{
	float f = 20. / 128;
	float3 pos = worldpos;
	pos.xyz *= f;
	pos.xyz -= float3(10, 10, 10);
	return pos;
	}
[maxvertexcount(36)]   // produce a maximum of 3 output vertices
void GS(point VS_OUTPUT input[1], inout TriangleStream<VS_OUTPUT> triStream)
{
	
	float4x4 proj = Projection;
	float4x4 view = View;
	float4x4 world = World;
	float4 tri[36];
	float f = 20. / 256.;
	float4 pos = input[0].Position;

	world._42 = 0;
	world._41 = 0;
	world._43 = 0;
	world._44 = 1;

	tri[0] = float4(0, 0, 0, 1);
	tri[1] = float4(0, 1, 0, 1);
	tri[2] = float4(1, 1, 0, 1);
	tri[3] = float4(0, 0, 0, 1);
	tri[4] = float4(1, 1, 0, 1);
	tri[5] = float4(1, 0, 0, 1);

	tri[7] = float4(0, 0, 1, 1);
	tri[6] = float4(0, 1, 1, 1);
	tri[8] = float4(1, 1, 1, 1);
	tri[9] = float4(0, 0, 1, 1);
	tri[11] = float4(1, 1, 1, 1);
	tri[10] = float4(1, 0, 1, 1);

	//ou
	tri[12] = float4(0, 1, 0, 1);
	tri[13] = float4(0, 1, 1, 1);
	tri[14] = float4(1, 1, 1, 1);
	tri[15] = float4(0, 1, 0, 1);
	tri[16] = float4(1, 1, 1, 1);
	tri[17] = float4(1, 1, 0, 1);

	tri[18] = float4(0, 0, 0, 1);
	tri[19] = float4(1, 0, 1, 1);
	tri[20] = float4(0, 0, 1, 1);
	tri[21] = float4(0, 0, 0, 1);
	tri[22] = float4(1, 0, 0, 1);
	tri[23] = float4(1, 0, 1, 1);

	//lr
	tri[24] = float4(0, 0, 0, 1);
	tri[25] = float4(0, 0, 1, 1);
	tri[26] = float4(0, 1, 1, 1);
	tri[27] = float4(0, 0, 0, 1);
	tri[28] = float4(0, 1, 1, 1);
	tri[29] = float4(0, 1, 0, 1);

	tri[31] = float4(1, 0, 0, 1);
	tri[30] = float4(1, 0, 1, 1);
	tri[32] = float4(1, 1, 1, 1);
	tri[33] = float4(1, 0, 0, 1);
	tri[35] = float4(1, 1, 1, 1);
	tri[34] = float4(1, 1, 0, 1);


	int4 vgi = float4(pos.x + 0.0001, pos.y+ 0.0001, pos.z  + 0.0001, 0);

	float4 col = Vocel_GI.Load(vgi);
	//col= Vocel_GI.Sample(Sampler, float3(vgi.x/255., vgi.y / 255., vgi.z / 255.));

	VS_OUTPUT psInput = (VS_OUTPUT)0;
	//f /= 5.;
	if (col.a>0.01)
		for (uint i = 0; i < 36; i++)
		{
			pos = tri[i] +input[0].Position;
			pos.w = 1;
			
			
			pos.xyz=re_voxelspace(pos.xyz);

			//pos.xyz *= 0.1;
			pos = mul(pos,View);
			pos = mul(pos, Projection);

			psInput.Position = pos;
			
			float4 acol = col;

			if (i >= 28) acol.rgb *= 0.5;
			else if (i >= 22) acol.rgb *= 0.6;
			else if (i >= 16) acol.rgb *= 0.7;
			else if (i >= 10) acol.rgb *= 0.8;
			else if (i >= 4) acol.rgb*=0.9;
			else if (i >= 1) acol.rgb *= 0.95;
			
			
			
			
			
			psInput.color = float4(acol.rgb, 1);

			triStream.Append(psInput);
			if (i == 2 || i == 5 || i == 8 || i == 11 || i == 14 || i == 17 || i == 20 || i == 23 || i == 26 || i == 29 || i == 32)
				triStream.RestartStrip();
		}
	triStream.RestartStrip();
}
//---------------
// Pixel Shader
//-----------------

float4 PS(VS_OUTPUT dataIn) : SV_TARGET
{
	
	float4 col = dataIn.color;
	col.a = 1;
	return col;
}
