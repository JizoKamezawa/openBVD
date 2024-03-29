﻿using System.IO;

namespace OpenBveApi.Math
{
	/// <summary>Represents a 4x4 double-precision matrix</summary>
	public struct Matrix4D
	{
		/// <summary>The top row of the matrix</summary>
		public Vector4 Row0;

		/// <summary>The first row of the matrix</summary>
		public Vector4 Row1;

		/// <summary>The second row of the matrix</summary>
		public Vector4 Row2;

		/// <summary>The third row of the matrix</summary>
		public Vector4 Row3;

		/// <summary>Creates a new Matrix4D</summary>
		/// <param name="topRow"></param>
		/// <param name="row1"></param>
		/// <param name="row2"></param>
		/// <param name="bottomRow"></param>
		public Matrix4D(Vector4 topRow, Vector4 row1, Vector4 row2, Vector4 bottomRow)
		{
			this.Row0 = topRow;
			this.Row1 = row1;
			this.Row2 = row2;
			this.Row3 = bottomRow;
		}

		/// <summary>Creates a new Matrix4D</summary>
		public Matrix4D(double[] matrixValues)
		{
			if (matrixValues.Length != 16)
			{
				throw new InvalidDataException("matrixValues must contain exactly 16 doubles");
			}
			Row0 = new Vector4(matrixValues[0], matrixValues[1], matrixValues[2], matrixValues[3]);
			Row1 = new Vector4(matrixValues[4], matrixValues[5], matrixValues[6], matrixValues[7]);
			Row2 = new Vector4(matrixValues[8], matrixValues[9], matrixValues[10], matrixValues[11]);
			Row3 = new Vector4(matrixValues[12], matrixValues[13], matrixValues[14], matrixValues[15]);
		}

		// --- comparisons ---
		
		/// <summary>Checks whether the two specified vectors are equal.</summary>
		/// <param name="a">The first vector.</param>
		/// <param name="b">The second vector.</param>
		/// <returns>Whether the two vectors are equal.</returns>
		public static bool operator ==(Matrix4D a, Matrix4D b)
		{
			if (a.Row0 != b.Row0) return false;
			if (a.Row1 != b.Row1) return false;
			if (a.Row2 != b.Row2) return false;
			if (a.Row3 != b.Row3) return false;
			return true;
		}

		/// <summary>Returns the hashcode for this instance.</summary>
		/// <returns>An integer representing the unique hashcode for this instance.</returns>
		public override int GetHashCode()
		{
			unchecked
			{
				var hashCode = this.Row0.GetHashCode();
				hashCode = (hashCode * 397) ^ this.Row1.GetHashCode();
				hashCode = (hashCode * 397) ^ this.Row2.GetHashCode();
				hashCode = (hashCode * 397) ^ this.Row3.GetHashCode();
				return hashCode;
			}
		}

		/// <summary>Indicates whether this instance and a specified object are equal.</summary>
		/// <param name="obj">The object to compare to.</param>
		/// <returns>True if the instances are equal; false otherwise.</returns>
		public override bool Equals(object obj)
		{
			if (!(obj is Vector4))
			{
				return false;
			}

			return this.Equals((Vector4)obj);
		}

		/// <summary>Checks whether the current vector is equal to the specified vector.</summary>
		/// <param name="b">The specified vector.</param>
		/// <returns>Whether the two vectors are equal.</returns>
		public bool Equals(Matrix4D b)
		{
			if (this.Row0 != b.Row0) return false;
			if (this.Row1 != b.Row1) return false;
			if (this.Row2 != b.Row2) return false;
			if (this.Row3 != b.Row3) return false;
			return true;
		}

		/// <summary>Checks whether the two specified vectors are unequal.</summary>
		/// <param name="a">The first vector.</param>
		/// <param name="b">The second vector.</param>
		/// <returns>Whether the two vectors are unequal.</returns>
		public static bool operator !=(Matrix4D a, Matrix4D b) {
			if (a.Row0 != b.Row0) return true;
			if (a.Row1 != b.Row1) return true;
			if (a.Row2 != b.Row2) return true;
			if (a.Row3 != b.Row3) return true;
			return false;
		}

		/// <summary>Multiplies two vectors.</summary>
		/// <param name="a">The first vector.</param>
		/// <param name="b">The second vector.</param>
		/// <returns>The product of the two vectors.</returns>
		public static Matrix4D operator *(Matrix4D a, Matrix4D b)
		{
			return Multiply(a, b);
		}

		private static Matrix4D Multiply(Matrix4D a, Matrix4D b)
		{
			Matrix4D result = new Matrix4D();
			result.Row0.X = (a.Row0.X * b.Row0.X) + (a.Row0.Y * b.Row1.X) + (a.Row0.Z * b.Row2.X) + (a.Row0.W * b.Row3.X);
			result.Row0.Y = (a.Row0.X * b.Row0.Y) + (a.Row0.Y * b.Row1.Y) + (a.Row0.Z * b.Row2.Y) + (a.Row0.W * b.Row3.Y);
			result.Row0.Z = (a.Row0.X * b.Row0.Z) + (a.Row0.Y * b.Row1.Z) + (a.Row0.Z * b.Row2.Z) + (a.Row0.W * b.Row3.Z);
			result.Row0.W = (a.Row0.X * b.Row0.W) + (a.Row0.Y * b.Row1.W) + (a.Row0.Z * b.Row2.W) + (a.Row0.W * b.Row3.W);
			result.Row1.X = (a.Row1.X * b.Row0.X) + (a.Row1.Y * b.Row1.X) + (a.Row1.Z * b.Row2.X) + (a.Row1.W * b.Row3.X);
			result.Row1.Y = (a.Row1.X * b.Row0.Y) + (a.Row1.Y * b.Row1.Y) + (a.Row1.Z * b.Row2.Y) + (a.Row1.W * b.Row3.Y);
			result.Row1.Z = (a.Row1.X * b.Row0.Z) + (a.Row1.Y * b.Row1.Z) + (a.Row1.Z * b.Row2.Z) + (a.Row1.W * b.Row3.Z);
			result.Row1.W = (a.Row1.X * b.Row0.W) + (a.Row1.Y * b.Row1.W) + (a.Row1.Z * b.Row2.W) + (a.Row1.W * b.Row3.W);
			result.Row2.X = (a.Row2.X * b.Row0.X) + (a.Row2.Y * b.Row1.X) + (a.Row2.Z * b.Row2.X) + (a.Row2.W * b.Row3.X);
			result.Row2.Y = (a.Row2.X * b.Row0.Y) + (a.Row2.Y * b.Row1.Y) + (a.Row2.Z * b.Row2.Y) + (a.Row2.W * b.Row3.Y);
			result.Row2.Z = (a.Row2.X * b.Row0.Z) + (a.Row2.Y * b.Row1.Z) + (a.Row2.Z * b.Row2.Z) + (a.Row2.W * b.Row3.Z);
			result.Row2.W = (a.Row2.X * b.Row0.W) + (a.Row2.Y * b.Row1.W) + (a.Row2.Z * b.Row2.W) + (a.Row2.W * b.Row3.W);
			result.Row3.X = (a.Row3.X * b.Row0.X) + (a.Row3.Y * b.Row1.X) + (a.Row3.Z * b.Row2.X) + (a.Row3.W * b.Row3.X);
			result.Row3.Y = (a.Row3.X * b.Row0.Y) + (a.Row3.Y * b.Row1.Y) + (a.Row3.Z * b.Row2.Y) + (a.Row3.W * b.Row3.Y);
			result.Row3.Z = (a.Row3.X * b.Row0.Z) + (a.Row3.Y * b.Row1.Z) + (a.Row3.Z * b.Row2.Z) + (a.Row3.W * b.Row3.Z);
			result.Row3.W = (a.Row3.X * b.Row0.W) + (a.Row3.Y * b.Row1.W) + (a.Row3.Z * b.Row2.W) + (a.Row3.W * b.Row3.W);
			return result;
		}
		

		/// <summary>Represents a zero matrix</summary>
		public static readonly Matrix4D Zero = new Matrix4D(Vector4.Zero, Vector4.Zero, Vector4.Zero, Vector4.Zero);

		/// <summary>Represents a matrix which performs no transformation</summary>
		public static readonly Matrix4D NoTransformation = new Matrix4D(new Vector4(1.0, 0.0, 0.0, 0.0),new Vector4(0.0, 1.0, 0.0, 0.0), new Vector4(0.0, 0.0, 1.0, 0.0), new Vector4(0.0, 0.0, 0.0, 1.0) );
	}
}
