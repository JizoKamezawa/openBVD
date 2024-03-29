﻿namespace OpenBveApi.Trains
{
	/// <summary>An abstract train</summary>
	public abstract class AbstractTrain
	{
		/// <summary>The current state of the train</summary>
		public TrainState State;
		/// <summary>The car in which the driver's cab is located</summary>
		public int DriverCar;
		/// <summary>The next user-set destination</summary>
		public int Destination;

		/// <summary>Gets the track position of the front car</summary>
		public abstract double FrontCarTrackPosition();

		/// <summary>Gets the track position of the rear car</summary>
		public abstract double RearCarTrackPosition();
	}
}
