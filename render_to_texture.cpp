#include "render_to_texture.h"



bool RenderTextureClass::Initialize_depth(ID3D11Device* device, HWND hwnd, int width, int height)
	{
	if (m_renderTargetTexture) return TRUE;


	RECT rc;
	GetClientRect(hwnd, &rc);
	UINT textureWidth = rc.right - rc.left;
	UINT textureHeight = rc.bottom - rc.top;
	if (width >= 0)			textureWidth = width;
	if (height >= 0)		textureHeight = height;

	D3D11_TEXTURE2D_DESC texDesc;
	HRESULT result;
	D3D11_RENDER_TARGET_VIEW_DESC renderTargetViewDesc;



	// Initialize the render target texture description.
	ZeroMemory(&texDesc, sizeof(texDesc));

	// Setup the render target texture description.
	texDesc.ArraySize = 1;
	texDesc.BindFlags = D3D11_BIND_DEPTH_STENCIL | D3D11_BIND_SHADER_RESOURCE;
	texDesc.CPUAccessFlags = NULL;
	texDesc.Format = DXGI_FORMAT_R32_TYPELESS;
	texDesc.Width = textureWidth;
	texDesc.Height = textureHeight;
	texDesc.MipLevels = 1;
	texDesc.MiscFlags = NULL;
	texDesc.SampleDesc.Count = 1;
	texDesc.SampleDesc.Quality = 0;
	texDesc.Usage = D3D11_USAGE_DYNAMIC;

	// Create the render target texture.
	result = device->CreateTexture2D(&texDesc, NULL, &m_renderTargetTexture);
	if (FAILED(result))
		{
		return false;
		}

	// Setup the description of the shader resource view.

	D3D11_SHADER_RESOURCE_VIEW_DESC srvDesc;
	srvDesc.Format = DXGI_FORMAT_R32_FLOAT;
	srvDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
	srvDesc.Texture2D.MostDetailedMip = 0;
	srvDesc.Texture2D.MipLevels = 1;
	
	// Create the shader resource view.
	result = device->CreateShaderResourceView(m_renderTargetTexture, &srvDesc, &m_shaderResourceView);
	if (FAILED(result))
		{
		return false;
		}
	D3D11_DEPTH_STENCIL_VIEW_DESC dsvDesc;
	dsvDesc.Format = DXGI_FORMAT_D32_FLOAT;
	dsvDesc.ViewDimension = D3D11_DSV_DIMENSION_TEXTURE2DMS;
	dsvDesc.Texture2D.MipSlice = 0;
	dsvDesc.Flags = 0;
	result = device->CreateDepthStencilView(m_renderTargetTexture, &dsvDesc, &m_DepthStencilView);
	if (FAILED(result))
		{
		return false;
		}

	return true;
	}
//------------------------------------------------------------------------
bool RenderTextureClass::Initialize_3DTex(ID3D11Device* device, int width, int height, int depth, bool uav_, DXGI_FORMAT format, bool mipmaps)
	{
	if (m_renderTargetTexture3D) return TRUE;

	HRESULT result;

	uav = uav_;

	D3D11_TEXTURE3D_DESC texDesc;

	D3D11_RENDER_TARGET_VIEW_DESC renderTargetViewDesc;



	// Initialize the render target texture description.
	ZeroMemory(&texDesc, sizeof(texDesc));

	// Setup the render target texture description.
	texDesc.Depth = depth;
	if (uav)
		texDesc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_UNORDERED_ACCESS | D3D11_BIND_SHADER_RESOURCE;
	else
		texDesc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
	texDesc.CPUAccessFlags = NULL;
	texDesc.Format = format;
	texDesc.Width = width;
	texDesc.Height = height;
	texDesc.MipLevels = 1;
	texDesc.MiscFlags = NULL;
	texDesc.Usage = D3D11_USAGE_DEFAULT;
	if (mipmaps)
		{
		texDesc.MipLevels = 0;
		texDesc.MiscFlags = D3D11_RESOURCE_MISC_GENERATE_MIPS;
		}
	// Create the render target texture.
	result = device->CreateTexture3D(&texDesc, NULL, &m_renderTargetTexture3D);
	if (FAILED(result))		return false;

	if (!uav_)
		{
		// Setup the description of the render target view.
		renderTargetViewDesc.Format = format;
		renderTargetViewDesc.ViewDimension = D3D11_RTV_DIMENSION_TEXTURE3D;
		renderTargetViewDesc.Texture3D.MipSlice = 0;

		// Create the render target view.
		result = device->CreateRenderTargetView(m_renderTargetTexture, &renderTargetViewDesc, &m_renderTargetView);
		if (FAILED(result))			return false;
		}
	D3D11_SHADER_RESOURCE_VIEW_DESC shaderResourceViewDesc;
	// Setup the description of the shader resource view.
	shaderResourceViewDesc.Format = format;
	shaderResourceViewDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE3D;
	shaderResourceViewDesc.Texture3D.MostDetailedMip = 0;
	shaderResourceViewDesc.Texture3D.MipLevels = 1;
	if (mipmaps)
		shaderResourceViewDesc.Texture2D.MipLevels = 8;
	if (mipmaps)
		shaderResourceViewDesc.Texture3D.MipLevels = 8;

	// Create the shader resource view.
	result = device->CreateShaderResourceView(m_renderTargetTexture3D, &shaderResourceViewDesc, &m_shaderResourceView);
	if (FAILED(result))
		return false;


	if (uav)
		{
		// create the unordered access view
		D3D11_UNORDERED_ACCESS_VIEW_DESC descUAV;
		ZeroMemory(&descUAV, sizeof(descUAV));
		descUAV.Format = format;
		descUAV.ViewDimension = D3D11_UAV_DIMENSION_TEXTURE3D;
		descUAV.Texture3D.MipSlice = 0;
		descUAV.Texture3D.FirstWSlice = 0;
		descUAV.Texture3D.WSize = depth;
		result = device->CreateUnorderedAccessView(m_renderTargetTexture3D, &descUAV, &m_pUAVs);
		if (FAILED(result))			return false;
		}

	return true;
	}
//------------------------------------
bool RenderTextureClass::Initialize(ID3D11Device* device, HWND hwnd, int width, int height, bool uav_, DXGI_FORMAT format, bool mipmaps)
	{
	if (m_renderTargetView) return TRUE;

	RECT rc;
	UINT textureWidth;
	UINT textureHeight;
	if (hwnd)
		{
		GetClientRect(hwnd, &rc);
		textureWidth = rc.right - rc.left;
		textureHeight = rc.bottom - rc.top;
		}
	if (width >= 0)			textureWidth = width;
	if (height >= 0)		textureHeight = height;
	w = textureWidth;
	h = textureHeight;
	D3D11_TEXTURE2D_DESC textureDesc;
	HRESULT result;
	D3D11_RENDER_TARGET_VIEW_DESC renderTargetViewDesc;
	D3D11_SHADER_RESOURCE_VIEW_DESC shaderResourceViewDesc;


	// Initialize the render target texture description.
	ZeroMemory(&textureDesc, sizeof(textureDesc));

	// Setup the render target texture description.
	textureDesc.Width = textureWidth;
	textureDesc.Height = textureHeight;
	textureDesc.MipLevels = 1;
	textureDesc.ArraySize = 1;
	textureDesc.Format = format;
	textureDesc.SampleDesc.Count = 1;
	textureDesc.Usage = D3D11_USAGE_DEFAULT;
	textureDesc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
	textureDesc.CPUAccessFlags = 0;
	textureDesc.MiscFlags = 0;
	/*if (mipmaps)
		{
		textureDesc.MipLevels = 0;
		textureDesc.ArraySize = 1;
		textureDesc.MiscFlags = D3D11_RESOURCE_MISC_GENERATE_MIPS;
		}*/
	// Create the render target texture.
	result = device->CreateTexture2D(&textureDesc, NULL, &m_renderTargetTexture);
	if (FAILED(result))
		{
		return false;
		}

	// Setup the description of the render target view.
	renderTargetViewDesc.Format = textureDesc.Format;
	renderTargetViewDesc.ViewDimension = D3D11_RTV_DIMENSION_TEXTURE2D;
	renderTargetViewDesc.Texture2D.MipSlice = 0;

	// Create the render target view.
	result = device->CreateRenderTargetView(m_renderTargetTexture, &renderTargetViewDesc, &m_renderTargetView);
	if (FAILED(result))
		{
		return false;
		}

	// Setup the description of the shader resource view.
	shaderResourceViewDesc.Format = textureDesc.Format;
	shaderResourceViewDesc.ViewDimension = D3D11_SRV_DIMENSION_TEXTURE2D;
	shaderResourceViewDesc.Texture2D.MostDetailedMip = 0;
	shaderResourceViewDesc.Texture2D.MipLevels = 1;
	//if (mipmaps)
		//shaderResourceViewDesc.Texture2D.MipLevels = 8;



	// Create the shader resource view.
	result = device->CreateShaderResourceView(m_renderTargetTexture, &shaderResourceViewDesc, &m_shaderResourceView);
	if (FAILED(result))
		{
		return false;
		}

	uav = uav_;
	if (uav)
		{
		// create the unordered access view
		D3D11_UNORDERED_ACCESS_VIEW_DESC descUAV;
		descUAV.Format = format;
		descUAV.ViewDimension = D3D11_UAV_DIMENSION_TEXTURE2D;
		descUAV.Texture2DArray.ArraySize = 1;
		descUAV.Texture2DArray.FirstArraySlice = 0;
		descUAV.Texture2DArray.MipSlice = 0;
		result = device->CreateUnorderedAccessView(m_renderTargetTexture, &descUAV, &m_pUAVs);
		if (FAILED(result))
			return false;

		}
	return true;
	}
bool RenderTextureClass::InitializeStaging(ID3D11Device* device, HWND hwnd, int width, int height, bool uav_, DXGI_FORMAT format, bool mipmaps)
	{
	if (m_renderTargetTexture) return TRUE;

	RECT rc;
	UINT textureWidth;
	UINT textureHeight;
	if (hwnd)
		{
		GetClientRect(hwnd, &rc);
		textureWidth = rc.right - rc.left;
		textureHeight = rc.bottom - rc.top;
		}
	if (width >= 0)			textureWidth = width;
	if (height >= 0)		textureHeight = height;
	w = textureWidth;
	h = textureHeight;
	D3D11_TEXTURE2D_DESC textureDesc;
	HRESULT result;
	D3D11_RENDER_TARGET_VIEW_DESC renderTargetViewDesc;
	D3D11_SHADER_RESOURCE_VIEW_DESC shaderResourceViewDesc;


	// Initialize the render target texture description.
	ZeroMemory(&textureDesc, sizeof(textureDesc));

	// Setup the render target texture description.
	textureDesc.Width = textureWidth;
	textureDesc.Height = textureHeight;
	textureDesc.MipLevels = 1;
	textureDesc.ArraySize = 1;
	textureDesc.Format = format;
	textureDesc.SampleDesc.Count = 1;
	textureDesc.Usage = D3D11_USAGE_STAGING;
	textureDesc.BindFlags = 0;
	textureDesc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
	textureDesc.MiscFlags = 0;
	/*if (mipmaps)
	{
	textureDesc.MipLevels = 0;
	textureDesc.ArraySize = 1;
	textureDesc.MiscFlags = D3D11_RESOURCE_MISC_GENERATE_MIPS;
	}*/
	// Create the render target texture.
	result = device->CreateTexture2D(&textureDesc, NULL, &m_renderTargetTexture);
	if (FAILED(result))
		{
		return false;
		}


	return true;
	}
/////////////////////////////////////////////////////////////////////////
ID3D11ShaderResourceView* RenderTextureClass::GetShaderResourceView()
	{
	return m_shaderResourceView;
	}
///////////////////////////////////////////////////////////
void RenderTextureClass::Shutdown()
	{
	if (m_shaderResourceView)
		{
		m_shaderResourceView->Release();
		m_shaderResourceView = 0;
		}

	if (m_renderTargetView)
		{
		m_renderTargetView->Release();
		m_renderTargetView = 0;
		}

	if (m_renderTargetTexture)
		{
		m_renderTargetTexture->Release();
		m_renderTargetTexture = 0;
		}
	if (m_DepthStencilView)			m_DepthStencilView->Release();
	if (m_pUAVs)					m_pUAVs->Release();
	if (m_renderTargetTexture3D)	m_renderTargetTexture3D->Release();

	m_DepthStencilView = NULL;
	m_renderTargetTexture3D = NULL;
	m_pUAVs = NULL;
	return;
	}