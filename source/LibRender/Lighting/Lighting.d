﻿using System;
using OpenBveApi.Colors;
using OpenBveApi.Math;
using OpenTK.Graphics.OpenGL;

namespace LibRender
{
	public static partial class Renderer
	{
		/// <summary>Whether dynamic lighting is currently enabled</summary>
		public static bool DynamicLighting = false;
		/// <summary>The current dynamic cab brightness</summary>
		public static double DynamicCabBrightness = 255;
		/// <summary>The list of dynamic light definitions</summary>
		public static LightDefinition[] LightDefinitions;
		/// <summary>The current ambient light color</summary>
		public static Color24 OptionAmbientColor = new Color24(160, 160, 160);
		/// <summary>The current diffuse light color</summary>
		public static Color24 OptionDiffuseColor = new Color24(160, 160, 160);
		/// <summary>The current ambient light position</summary>
		public static Vector3 OptionLightPosition = new Vector3(0.223606797749979f, 0.86602540378444f, -0.447213595499958f);

		/// <summary>Initializes the lighting model</summary>
		public static void InitializeLighting()
		{
			GL.Light(LightName.Light0, LightParameter.Ambient, new float[] { inv255 * (float) OptionAmbientColor.R, inv255 * (float) OptionAmbientColor.G, inv255 * (float) OptionAmbientColor.B, 1.0f });
			GL.Light(LightName.Light0, LightParameter.Diffuse, new float[] { inv255 * (float) OptionDiffuseColor.R, inv255 * (float) OptionDiffuseColor.G, inv255 * (float) OptionDiffuseColor.B, 1.0f });
			GL.LightModel(LightModelParameter.LightModelAmbient, new float[] { 0.0f, 0.0f, 0.0f, 1.0f });
			GL.CullFace(CullFaceMode.Front); CullEnabled = true; // possibly undocumented, but required for correct lighting
			GL.Enable(EnableCap.Light0);
			GL.Enable(EnableCap.ColorMaterial);
			GL.ColorMaterial(MaterialFace.FrontAndBack, ColorMaterialParameter.AmbientAndDiffuse);
			GL.ShadeModel(ShadingModel.Smooth);
			float x = (float) OptionAmbientColor.R + (float) OptionAmbientColor.G + (float) OptionAmbientColor.B;
			float y = (float) OptionDiffuseColor.R + (float) OptionDiffuseColor.G + (float) OptionDiffuseColor.B;
			if (x < y) x = y;
			OptionLightingResultingAmount = 0.00208333333333333f * x;
			if (OptionLightingResultingAmount > 1.0f) OptionLightingResultingAmount = 1.0f;
			GL.Enable(EnableCap.Lighting); LightingEnabled = true;
			GL.DepthFunc(DepthFunction.Lequal);
		}

		/// <summary>Updates the lighting model on a per frame basis</summary>
		public static void UpdateLighting(double Time)
		{
			//Check that we have more than one light definition & that the array is not null
			if (DynamicLighting == false || LightDefinitions == null || LightDefinitions.Length < 2)
			{
				return;
			}
			//Convert to absolute time of day
			//Use a while loop as it's possible to run through two days
			while (Time > 86400)
			{
				Time -= 86400;
			}
			//Run through the array
			int j = 0;
			for (int i = j; i < LightDefinitions.Length; i++)
			{
				
				if (Time < LightDefinitions[i].Time)
				{
					break;
				}
				j = i;

			}

			//We now know that our light definition is between the values defined in j and j + 1 (Or 0 if this is the end of the array)
			int k;

			if (j == 0)
			{
				//Our NEW light is to be the first entry in the array
				//This means the OLD light is the last entry, but j and k do not need reversing
				k = 0;
				j = LightDefinitions.Length - 1;
			}
			else if (j == LightDefinitions.Length - 1)
			{
				//We are wrapping around to the end of the array
				//Reverse j and k, as we have not yet passed the time for the first array entry
				j = 0;
				k = LightDefinitions.Length - 1;
			}
			else
			{
				//Somewhere in the middle, so the NEW light is simply one greater
				k = j + 1;
			}
			int t1 = LightDefinitions[j].Time, t2 = LightDefinitions[k].Time;
			
			double cb1 = LightDefinitions[j].CabBrightness, cb2 = LightDefinitions[k].Time;
			//Calculate, inverting if necessary

			//Ensure we're not about to divide by zero
			if (t2 == 0)
			{
				t2 = 1;
			}
			if (t1 == 0)
			{
				t1 = 1;
			}
			//Calculate the percentage
			double mu;
			if (k == LightDefinitions.Length - 1)
			{
				//Wrapping around
				mu = (86400 - Time + t1) / (86400 - t2 + t1);
				
			}
			else
			{
				mu = (Time - t1) / (t2 - t1);
			}
			//Calculate the final colors and positions
			OptionDiffuseColor = Color24.CosineInterpolate(LightDefinitions[j].DiffuseColor, LightDefinitions[k].DiffuseColor, mu);
			OptionAmbientColor = Color24.CosineInterpolate(LightDefinitions[j].AmbientColor, LightDefinitions[k].AmbientColor, mu);
			OptionLightPosition = Vector3.CosineInterpolate(LightDefinitions[j].LightPosition, LightDefinitions[k].LightPosition, mu);

			//Interpolate the cab brightness value
			var mu2 = (1 - Math.Cos(mu * Math.PI)) / 2;
			DynamicCabBrightness = (cb1 * (1 - mu2) + cb2 * mu2);
			//Reinitialize the lighting model with the new information
			InitializeLighting();
			//NOTE: This does not refresh the display lists
			//If we sit in place with extreme time acceleration (1000x) lighting for faces may appear a little inconsistant
		}
	}
}
