﻿using System;
using LibRender;
using OpenBveApi.Colors;
using OpenBveApi.Graphics;
using OpenBveApi.Runtime;
using OpenBveApi.Textures;
using OpenTK.Graphics.OpenGL;

namespace OpenBve
{
	internal static partial class Renderer
	{
		/* --------------------------------------------------------------
		 * This file contains the base drawing routines for screen overlays
		 * -------------------------------------------------------------- */
		
		/// <summary>Is called once by the main renderer loop, in order to render all overlays shown on the screen</summary>
		/// <param name="TimeElapsed">The time elapsed since the last call to this function</param>
		private static void RenderOverlays(double TimeElapsed)
		{
			//Initialize openGL
			GL.BlendFunc(BlendingFactor.SrcAlpha, BlendingFactor.OneMinusSrcAlpha);
			GL.Enable(EnableCap.Blend); LibRender.Renderer.BlendEnabled = true;
			GL.MatrixMode(MatrixMode.Projection);
			GL.PushMatrix();
			GL.LoadIdentity();
			GL.Ortho(0.0, (double)LibRender.Screen.Width, (double)LibRender.Screen.Height, 0.0, -1.0, 1.0);
			GL.MatrixMode(MatrixMode.Modelview);
			GL.PushMatrix();
			GL.LoadIdentity();
			//Check which overlays to show
			switch (LibRender.Renderer.CurrentOutputMode)
			{
				case OutputMode.Default:
					
						//Route info overlay (if selected)
						Game.routeInfoOverlay.Show();
						//HUD
						for (int i = 0; i < HUD.CurrentHudElements.Length; i++)
						{
							string Command = HUD.CurrentHudElements[i].Subject.ToLowerInvariant();
							switch (Command)
							{
								case "messages":
									{
										RenderGameMessages(HUD.CurrentHudElements[i], TimeElapsed);
									}
									break;
								case "scoremessages":
									{
										RenderScoreMessages(HUD.CurrentHudElements[i], TimeElapsed);
									}
									break;
								case "ats":
									{
										RenderATSLamps(HUD.CurrentHudElements[i], TimeElapsed);
									}
									break;
								default:
									{
										RenderHUDElement(HUD.CurrentHudElements[i], TimeElapsed);
									}
									break;
							}
						}
						//Marker textures
						if (Interface.CurrentOptions.GameMode != Interface.GameMode.Expert)
						{
							double y = 8.0;
							for (int i = 0; i < Game.MarkerTextures.Length; i++)
							{
								if (Program.CurrentHost.LoadTexture(Game.MarkerTextures[i], OpenGlTextureWrapMode.ClampClamp))
								{
									double w = (double)Game.MarkerTextures[i].Width;
									double h = (double)Game.MarkerTextures[i].Height;
									GL.Color4(1.0f, 1.0f, 1.0f, 1.0f);
									LibRender.Renderer.RenderOverlayTexture(Game.MarkerTextures[i], (double)LibRender.Screen.Width - w - 8.0, y, (double)LibRender.Screen.Width - 8.0, y + h);
									y += h + 8.0;
								}
							}
						}
						//Timetable overlay
						//NOTE: Only affects auto-generated timetable, possibly change this inconsistant behaviour
						if (Timetable.CurrentTimetable == Timetable.TimetableState.Default)
						{
							// default
							if (Program.CurrentHost.LoadTexture(Timetable.DefaultTimetableTexture, OpenGlTextureWrapMode.ClampClamp))
							{
								int w = Timetable.DefaultTimetableTexture.Width;
								int h = Timetable.DefaultTimetableTexture.Height;
								GL.Color4(1.0f, 1.0f, 1.0f, 1.0f);
								LibRender.Renderer.RenderOverlayTexture(Timetable.DefaultTimetableTexture, (double)(LibRender.Screen.Width - w), Timetable.DefaultTimetablePosition, (double)LibRender.Screen.Width, (double)h + Timetable.DefaultTimetablePosition);
							}
						}
						else if (Timetable.CurrentTimetable == Timetable.TimetableState.Custom & Timetable.CustomObjectsUsed == 0)
					{
						// custom
						if (Program.CurrentHost.LoadTexture(Timetable.CurrentCustomTimetableDaytimeTexture, OpenGlTextureWrapMode.ClampClamp))
						{
							int w = Timetable.CurrentCustomTimetableDaytimeTexture.Width;
							int h = Timetable.CurrentCustomTimetableDaytimeTexture.Height;
							GL.Color4(1.0f, 1.0f, 1.0f, 1.0f);
							LibRender.Renderer.RenderOverlayTexture(Timetable.CurrentCustomTimetableDaytimeTexture, (double) (LibRender.Screen.Width - w), Timetable.CustomTimetablePosition, (double) LibRender.Screen.Width, (double) h + Timetable.CustomTimetablePosition);
						}

						if (Program.CurrentHost.LoadTexture(Timetable.CurrentCustomTimetableDaytimeTexture, OpenGlTextureWrapMode.ClampClamp))
						{
							int w = Timetable.CurrentCustomTimetableDaytimeTexture.Width;
							int h = Timetable.CurrentCustomTimetableDaytimeTexture.Height;
							float alpha;
							if (Timetable.CurrentCustomTimetableDaytimeTexture != null)
							{
								double t = (TrainManager.PlayerTrain.Cars[TrainManager.PlayerTrain.DriverCar].FrontAxle.Follower.TrackPosition - TrainManager.PlayerTrain.Cars[TrainManager.PlayerTrain.DriverCar].Brightness.PreviousTrackPosition) / (TrainManager.PlayerTrain.Cars[TrainManager.PlayerTrain.DriverCar].Brightness.NextTrackPosition - TrainManager.PlayerTrain.Cars[TrainManager.PlayerTrain.DriverCar].Brightness.PreviousTrackPosition);
								alpha = (float) ((1.0 - t) * TrainManager.PlayerTrain.Cars[TrainManager.PlayerTrain.DriverCar].Brightness.PreviousBrightness + t * TrainManager.PlayerTrain.Cars[TrainManager.PlayerTrain.DriverCar].Brightness.NextBrightness);
							}
							else
							{
								alpha = 1.0f;
							}

							GL.Color4(1.0f, 1.0f, 1.0f, alpha);
							LibRender.Renderer.RenderOverlayTexture(Timetable.CurrentCustomTimetableDaytimeTexture, (double) (LibRender.Screen.Width - w), Timetable.CustomTimetablePosition, (double) LibRender.Screen.Width, (double) h + Timetable.CustomTimetablePosition);
						}
					}
					break;
				case OutputMode.Debug:
					RenderDebugOverlays();
					break;
				case OutputMode.DebugATS:
					RenderATSDebugOverlay();
					break;
			}
			// air brake debug output
			if (Interface.CurrentOptions.GameMode != Interface.GameMode.Expert & OptionBrakeSystems)
			{
				RenderBrakeSystemDebug();
			}
			//If paused, fade out the screen & write PAUSE
			if (Game.CurrentInterface == Game.InterfaceType.Pause)
			{
				// pause
				GL.Color4(0.0f, 0.0f, 0.0f, 0.5f);
				LibRender.Renderer.RenderOverlaySolid(0.0, 0.0, (double)LibRender.Screen.Width, (double)LibRender.Screen.Height);
				GL.Color4(1.0f, 1.0f, 1.0f, 1.0f);
				LibRender.Renderer.DrawString(Fonts.VeryLargeFont, "PAUSE", new System.Drawing.Point(LibRender.Screen.Width / 2, LibRender.Screen.Height / 2), TextAlignment.CenterMiddle, Color128.White, true);
			}
			else if (Game.CurrentInterface == Game.InterfaceType.Menu)
				Game.Menu.Draw();
			//Fade to black on change ends
			if (TrainManager.PlayerTrain.Station >= 0 && Game.Stations[TrainManager.PlayerTrain.Station].Type == StationType.ChangeEnds && TrainManager.PlayerTrain.StationState == TrainManager.TrainStopState.Boarding)
			{
				double time = TrainManager.PlayerTrain.StationDepartureTime - Game.SecondsSinceMidnight;
				if (time < 1.0)
				{
					FadeToBlackDueToChangeEnds = Math.Max(0.0, 1.0 - time);
				}
				else if (FadeToBlackDueToChangeEnds > 0.0)
				{
					FadeToBlackDueToChangeEnds -= TimeElapsed;
					if (FadeToBlackDueToChangeEnds < 0.0)
					{
						FadeToBlackDueToChangeEnds = 0.0;
					}
				}
			}
			else if (FadeToBlackDueToChangeEnds > 0.0)
			{
				FadeToBlackDueToChangeEnds -= TimeElapsed;
				if (FadeToBlackDueToChangeEnds < 0.0)
				{
					FadeToBlackDueToChangeEnds = 0.0;
				}
			}
			if (FadeToBlackDueToChangeEnds > 0.0 & (World.CameraMode == CameraViewMode.Interior | World.CameraMode == CameraViewMode.InteriorLookAhead))
			{
				GL.Color4(0.0, 0.0, 0.0, FadeToBlackDueToChangeEnds);
				LibRender.Renderer.RenderOverlaySolid(0.0, 0.0, (double)LibRender.Screen.Width, (double)LibRender.Screen.Height);
			}
			// finalize
			GL.PopMatrix();
			GL.MatrixMode(MatrixMode.Projection);
			GL.PopMatrix();
			GL.MatrixMode(MatrixMode.Modelview);
			GL.Disable(EnableCap.Blend);
		}	
	}
}
