#pragma once

#include "groundwork.h"

#ifndef _XBOX_CONTROLLER_H_
#define _XBOX_CONTROLLER_H_

// No MFC
#define WIN32_LEAN_AND_MEAN

// We need the Windows Header and the XInput Header
#include <windows.h>
#include <XInput.h>

#pragma comment(lib, "XInput.lib")
/*
//			!!!!!!!!!!!!!!!!!!!!!!!			USAGE:			!!!!!!!!!!!!!!!!!!!!!!!!!

//this goes into the global variables:
CXBOXController *gamepad = new CXBOXController(1); //1 would be the only one or the fist one of max 4 controller

//put this in the render function:
if (gamepad->IsConnected())
		{
		if (gamepad->GetState().Gamepad.wButtons & XINPUT_GAMEPAD_Y)
			cam.w = 1;
		else
			cam.w = 0;
		if (gamepad->GetState().Gamepad.wButtons & XINPUT_GAMEPAD_A)
			{
			
			cam.s = 1;
			}
		else
			cam.s = 0;

		}
	SHORT lx = gamepad->GetState().Gamepad.sThumbLX;
	SHORT ly = gamepad->GetState().Gamepad.sThumbLY;

	if (abs(ly) > 3000)
		{
		float angle_x = (float)ly / 32000.0;
		angle_x *= 0.05;
		cam.rotation.x -= angle_x;
		}
	if (abs(lx) > 3000)
		{
		float angle_y = (float)lx / 32000.0;
		angle_y *= 0.05;
		cam.rotation.y -= angle_y;
		}
		*/

// XBOX Controller Class Definition
class CXBOXController
	{
	private:
		XINPUT_STATE _controllerState;
		int _controllerNum;
	public:
		CXBOXController(int playerNumber)
			{
			// Set the Controller Number
			_controllerNum = playerNumber - 1;
			}

		XINPUT_STATE GetState()
			{
			// Zeroise the state
			ZeroMemory(&_controllerState, sizeof(XINPUT_STATE));

			// Get the state
			XInputGetState(_controllerNum, &_controllerState);

			return _controllerState;
			}

		bool IsConnected()
			{
			// Zeroise the state
			ZeroMemory(&_controllerState, sizeof(XINPUT_STATE));

			// Get the state
			DWORD Result = XInputGetState(_controllerNum, &_controllerState);

			if (Result == ERROR_SUCCESS)
				{
				return true;
				}
			else
				{
				return false;
				}
			}

		void Vibrate(int leftVal=0, int rightVal=0)
			{
			// Create a Vibraton State
			XINPUT_VIBRATION Vibration;

			// Zeroise the Vibration
			ZeroMemory(&Vibration, sizeof(XINPUT_VIBRATION));

			// Set the Vibration Values
			Vibration.wLeftMotorSpeed = leftVal;
			Vibration.wRightMotorSpeed = rightVal;

			// Vibrate the controller
			XInputSetState(_controllerNum, &Vibration);
			}


	};

#endif