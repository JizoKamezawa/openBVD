﻿using System;
using OpenBveApi.Math;
using OpenBveApi.Textures;
using OpenBveApi.World;

namespace OpenBveApi.Objects
{
	// <summary>Represents a static (e.g. non-animated) object within the world</summary>
	/// <inheritdoc />
	public class StaticObject : UnifiedObject
	{
		/// <summary>The mesh of the object</summary>
		public Mesh Mesh;
		/// <summary>The index to the Renderer.Object array, plus 1. The value of zero represents that the object is not currently shown by the renderer.</summary>
		public int RendererIndex;
		/// <summary>The starting track position, for static objects only.</summary>
		public float StartingDistance;
		/// <summary>The ending track position, for static objects only.</summary>
		public float EndingDistance;
		/// <summary>The block mod group, for static objects only.</summary>
		public short GroupIndex;
		/// <summary>Whether the object is dynamic, i.e. not static.</summary>
		public bool Dynamic;
		/// <summary> Stores the author for this object.</summary>
		public string Author;
		/// <summary> Stores the copyright information for this object.</summary>
		public string Copyright;

		private readonly Hosts.HostInterface currentHost;

		/// <summary>Creates a new empty object</summary>
		public StaticObject(Hosts.HostInterface Host)
		{
			currentHost = Host;
			Mesh = new Mesh
			{
				Faces = new MeshFace[] { },
				Materials = new MeshMaterial[] { },
				Vertices = new VertexTemplate[] { }
			};
		}

		/// <summary>Creates a clone of this object.</summary>
		/// <param name="DaytimeTexture">The replacement daytime texture</param>
		/// <param name="NighttimeTexture">The replacement nighttime texture</param>
		/// <returns></returns>
		public StaticObject Clone(Textures.Texture DaytimeTexture, Textures.Texture NighttimeTexture) //Prefix is required or else MCS barfs
		{
			StaticObject Result = new StaticObject(currentHost)
			{
				StartingDistance = StartingDistance,
				EndingDistance = EndingDistance,
				Dynamic = Dynamic,
				Mesh = {Vertices = new VertexTemplate[Mesh.Vertices.Length]}
			};
			// vertices
			for (int j = 0; j < Mesh.Vertices.Length; j++)
			{
				if (Mesh.Vertices[j] is ColoredVertex)
				{
					Result.Mesh.Vertices[j] = new ColoredVertex((ColoredVertex) Mesh.Vertices[j]);
				}
				else
				{
					Result.Mesh.Vertices[j] = new Vertex((Vertex) Mesh.Vertices[j]);
				}
			}

			// faces
			Result.Mesh.Faces = new MeshFace[Mesh.Faces.Length];
			for (int j = 0; j < Mesh.Faces.Length; j++)
			{
				Result.Mesh.Faces[j].Flags = Mesh.Faces[j].Flags;
				Result.Mesh.Faces[j].Material = Mesh.Faces[j].Material;
				Result.Mesh.Faces[j].Vertices = new MeshFaceVertex[Mesh.Faces[j].Vertices.Length];
				for (int k = 0; k < Mesh.Faces[j].Vertices.Length; k++)
				{
					Result.Mesh.Faces[j].Vertices[k] = Mesh.Faces[j].Vertices[k];
				}
			}

			// materials
			Result.Mesh.Materials = new MeshMaterial[Mesh.Materials.Length];
			for (int j = 0; j < Mesh.Materials.Length; j++)
			{
				Result.Mesh.Materials[j] = Mesh.Materials[j];
				if (DaytimeTexture != null)
				{
					Result.Mesh.Materials[j].DaytimeTexture = DaytimeTexture;
				}
				else
				{
					Result.Mesh.Materials[j].DaytimeTexture = Mesh.Materials[j].DaytimeTexture;
				}

				if (NighttimeTexture != null)
				{
					Result.Mesh.Materials[j].NighttimeTexture = NighttimeTexture;
				}
				else
				{
					Result.Mesh.Materials[j].NighttimeTexture = Mesh.Materials[j].NighttimeTexture;
				}
			}

			return Result;
		}

		/// <summary>Creates a clone of this object.</summary>
		public override UnifiedObject Clone()
		{
			StaticObject Result = new StaticObject(currentHost)
			{
				StartingDistance = StartingDistance,
				EndingDistance = EndingDistance,
				Dynamic = Dynamic,
				Mesh = {Vertices = new VertexTemplate[Mesh.Vertices.Length]}
			};
			// vertices
			for (int j = 0; j < Mesh.Vertices.Length; j++)
			{
				if (Mesh.Vertices[j] is ColoredVertex)
				{
					Result.Mesh.Vertices[j] = new ColoredVertex((ColoredVertex) Mesh.Vertices[j]);
				}
				else
				{
					Result.Mesh.Vertices[j] = new Vertex((Vertex) Mesh.Vertices[j]);
				}
			}

			// faces
			Result.Mesh.Faces = new MeshFace[Mesh.Faces.Length];
			for (int j = 0; j < Mesh.Faces.Length; j++)
			{
				Result.Mesh.Faces[j].Flags = Mesh.Faces[j].Flags;
				Result.Mesh.Faces[j].Material = Mesh.Faces[j].Material;
				Result.Mesh.Faces[j].Vertices = new MeshFaceVertex[Mesh.Faces[j].Vertices.Length];
				for (int k = 0; k < Mesh.Faces[j].Vertices.Length; k++)
				{
					Result.Mesh.Faces[j].Vertices[k] = Mesh.Faces[j].Vertices[k];
				}
			}

			// materials
			Result.Mesh.Materials = new MeshMaterial[Mesh.Materials.Length];
			for (int j = 0; j < Mesh.Materials.Length; j++)
			{
				Result.Mesh.Materials[j] = Mesh.Materials[j];
			}

			return Result;
		}

		/// <summary>Joins two static objects</summary>
		/// <param name="Add">The static object to join</param>
		public void JoinObjects(StaticObject Add)
		{
			if (Add == null)
			{
				return;
			}

			int mf = Mesh.Faces.Length;
			int mm = Mesh.Materials.Length;
			int mv = Mesh.Vertices.Length;
			Array.Resize<MeshFace>(ref Mesh.Faces, mf + Add.Mesh.Faces.Length);
			Array.Resize<MeshMaterial>(ref Mesh.Materials, mm + Add.Mesh.Materials.Length);
			Array.Resize<VertexTemplate>(ref Mesh.Vertices, mv + Add.Mesh.Vertices.Length);
			for (int i = 0; i < Add.Mesh.Faces.Length; i++)
			{
				Mesh.Faces[mf + i] = Add.Mesh.Faces[i];
				for (int j = 0; j < Mesh.Faces[mf + i].Vertices.Length; j++)
				{
					Mesh.Faces[mf + i].Vertices[j].Index += (ushort) mv;
				}

				Mesh.Faces[mf + i].Material += (ushort) mm;
			}

			for (int i = 0; i < Add.Mesh.Materials.Length; i++)
			{
				Mesh.Materials[mm + i] = Add.Mesh.Materials[i];
			}

			for (int i = 0; i < Add.Mesh.Vertices.Length; i++)
			{
				if (Add.Mesh.Vertices[i] is ColoredVertex)
				{
					Mesh.Vertices[mv + i] = new ColoredVertex((ColoredVertex) Add.Mesh.Vertices[i]);
				}
				else
				{
					Mesh.Vertices[mv + i] = new Vertex((Vertex) Add.Mesh.Vertices[i]);
				}

			}
		}

		/// <summary>Applys scale</summary>
		public void ApplyScale(double x, double y, double z)
		{
			float rx = (float) (1.0 / x);
			float ry = (float) (1.0 / y);
			float rz = (float) (1.0 / z);
			float rx2 = rx * rx;
			float ry2 = ry * ry;
			float rz2 = rz * rz;
			bool reverse = x * y * z < 0.0;
			for (int j = 0; j < Mesh.Vertices.Length; j++)
			{
				Mesh.Vertices[j].Coordinates.X *= x;
				Mesh.Vertices[j].Coordinates.Y *= y;
				Mesh.Vertices[j].Coordinates.Z *= z;
			}

			for (int j = 0; j < Mesh.Faces.Length; j++)
			{
				for (int k = 0; k < Mesh.Faces[j].Vertices.Length; k++)
				{
					double nx2 = Mesh.Faces[j].Vertices[k].Normal.X * Mesh.Faces[j].Vertices[k].Normal.X;
					double ny2 = Mesh.Faces[j].Vertices[k].Normal.Y * Mesh.Faces[j].Vertices[k].Normal.Y;
					double nz2 = Mesh.Faces[j].Vertices[k].Normal.Z * Mesh.Faces[j].Vertices[k].Normal.Z;
					double u = nx2 * rx2 + ny2 * ry2 + nz2 * rz2;
					if (u != 0.0)
					{
						u = (float) System.Math.Sqrt((double) ((nx2 + ny2 + nz2) / u));
						Mesh.Faces[j].Vertices[k].Normal.X *= rx * u;
						Mesh.Faces[j].Vertices[k].Normal.Y *= ry * u;
						Mesh.Faces[j].Vertices[k].Normal.Z *= rz * u;
					}
				}
			}

			if (reverse)
			{
				for (int j = 0; j < Mesh.Faces.Length; j++)
				{
					Mesh.Faces[j].Flip();
				}
			}
		}

		/// <summary>Applys rotation</summary>
		/// <param name="Rotation">The rotation vector</param>
		/// <param name="Angle">The angle to rotate in degrees</param>
		public void ApplyRotation(Vector3 Rotation, double Angle)
		{
			double cosa = System.Math.Cos(Angle);
			double sina = System.Math.Sin(Angle);
			for (int j = 0; j < Mesh.Vertices.Length; j++)
			{
				Mesh.Vertices[j].Coordinates.Rotate(Rotation, cosa, sina);

			}

			for (int j = 0; j < Mesh.Faces.Length; j++)
			{
				for (int k = 0; k < Mesh.Faces[j].Vertices.Length; k++)
				{
					Mesh.Faces[j].Vertices[k].Normal.Rotate(Rotation, cosa, sina);
				}
			}
		}
		
		/// <summary>Applys translation</summary>
		public void ApplyTranslation(double x, double y, double z)
		{
			for (int i = 0; i < Mesh.Vertices.Length; i++)
			{
				Mesh.Vertices[i].Coordinates.X += x;
				Mesh.Vertices[i].Coordinates.Y += y;
				Mesh.Vertices[i].Coordinates.Z += z;
			}
		}

		/// <summary>Applies mirroring</summary>
		/// <param name="vX">Whether to mirror verticies in the X-axis</param>
		/// <param name="vY">Whether to mirror verticies in the Y-axis</param>
		/// <param name="vZ">Whether to mirror verticies in the Z-axis</param>
		/// <param name="nX">Whether to mirror normals in the X-axis</param>
		/// <param name="nY">Whether to mirror normals in the Y-axis</param>
		/// <param name="nZ">Whether to mirror normals in the Z-axis</param>
		public void ApplyMirror(bool vX, bool vY, bool vZ, bool nX, bool nY, bool nZ)
		{
			for (int i = 0; i < Mesh.Vertices.Length; i++)
			{
				if (vX)
				{
					Mesh.Vertices[i].Coordinates.X *= -1;
				}

				if (vY)
				{
					Mesh.Vertices[i].Coordinates.Y *= -1;
				}

				if (vZ)
				{
					Mesh.Vertices[i].Coordinates.Z *= -1;
				}
			}

			for (int i = 0; i < Mesh.Faces.Length; i++)
			{
				for (int j = 0; j < Mesh.Faces[i].Vertices.Length; j++)
				{
					if (nX)
					{
						Mesh.Faces[i].Vertices[j].Normal.X *= -1;
					}

					if (nY)
					{
						Mesh.Faces[i].Vertices[j].Normal.Y *= -1;
					}

					if (nZ)
					{
						Mesh.Faces[i].Vertices[j].Normal.X *= -1;
					}
				}
			}

			int numFlips = 0;
			if (vX)
			{
				numFlips++;
			}

			if (vY)
			{
				numFlips++;
			}

			if (vZ)
			{
				numFlips++;
			}

			if (numFlips % 2 != 0)
			{
				for (int i = 0; i < Mesh.Faces.Length; i++)
				{
					Array.Reverse(Mesh.Faces[i].Vertices);
				}
			}
		}

		/// <summary>Applies shear</summary>
		public void ApplyShear(Vector3 d, Vector3 s, double r)
		{
			for (int j = 0; j < Mesh.Vertices.Length; j++)
			{
				double n = r * (d.X * Mesh.Vertices[j].Coordinates.X + d.Y * Mesh.Vertices[j].Coordinates.Y + d.Z * Mesh.Vertices[j].Coordinates.Z);
				Mesh.Vertices[j].Coordinates.X += s.X * n;
				Mesh.Vertices[j].Coordinates.Y += s.Y * n;
				Mesh.Vertices[j].Coordinates.Z += s.Z * n;
			}

			for (int j = 0; j < Mesh.Faces.Length; j++)
			{
				for (int k = 0; k < Mesh.Faces[j].Vertices.Length; k++)
				{
					if (Mesh.Faces[j].Vertices[k].Normal.X != 0.0f | Mesh.Faces[j].Vertices[k].Normal.Y != 0.0f | Mesh.Faces[j].Vertices[k].Normal.Z != 0.0f)
					{
						double n = r * (s.X * Mesh.Faces[j].Vertices[k].Normal.X + s.Y * Mesh.Faces[j].Vertices[k].Normal.Y + s.Z * Mesh.Faces[j].Vertices[k].Normal.Z);
						Mesh.Faces[j].Vertices[k].Normal -= d * n;
						Mesh.Faces[j].Vertices[k].Normal.Normalize();
					}
				}
			}
		}

		/// <summary>Applies world data to create a transformed model</summary>
		public void ApplyData(StaticObject Prototype, Vector3 Position, Transformation BaseTransformation, Transformation AuxTransformation, bool AccurateObjectDisposal, double AccurateObjectDisposalZOffset, double startingDistance, double endingDistance, double BlockLength, double TrackPosition, double Brightness, double ViewingDistance)
		{
			StartingDistance = float.MaxValue;
			EndingDistance = float.MinValue;
			Mesh.Vertices = new VertexTemplate[Prototype.Mesh.Vertices.Length];
			// vertices
			for (int j = 0; j < Prototype.Mesh.Vertices.Length; j++)
			{
				if (Prototype.Mesh.Vertices[j] is ColoredVertex)
				{
					Mesh.Vertices[j] = new ColoredVertex((ColoredVertex) Prototype.Mesh.Vertices[j]);
				}
				else
				{
					Mesh.Vertices[j] = new Vertex((Vertex) Prototype.Mesh.Vertices[j]);
				}

				if (AccurateObjectDisposal)
				{
					Mesh.Vertices[j].Coordinates.Rotate(AuxTransformation);
					if (Mesh.Vertices[j].Coordinates.Z < StartingDistance)
					{
						StartingDistance = (float) Mesh.Vertices[j].Coordinates.Z;
					}

					if (Mesh.Vertices[j].Coordinates.Z > EndingDistance)
					{
						EndingDistance = (float) Mesh.Vertices[j].Coordinates.Z;
					}

					Mesh.Vertices[j].Coordinates = Prototype.Mesh.Vertices[j].Coordinates;
				}

				Mesh.Vertices[j].Coordinates.Rotate(AuxTransformation);
				Mesh.Vertices[j].Coordinates.Rotate(BaseTransformation);
				Mesh.Vertices[j].Coordinates += Position;
			}

			if (AccurateObjectDisposal)
			{
				StartingDistance += (float) AccurateObjectDisposalZOffset;
				EndingDistance += (float) AccurateObjectDisposalZOffset;
			}

			// faces
			Mesh.Faces = new MeshFace[Prototype.Mesh.Faces.Length];
			for (int j = 0; j < Prototype.Mesh.Faces.Length; j++)
			{
				Mesh.Faces[j].Flags = Prototype.Mesh.Faces[j].Flags;
				Mesh.Faces[j].Material = Prototype.Mesh.Faces[j].Material;
				Mesh.Faces[j].Vertices = new MeshFaceVertex[Prototype.Mesh.Faces[j].Vertices.Length];
				for (int k = 0; k < Prototype.Mesh.Faces[j].Vertices.Length; k++)
				{
					Mesh.Faces[j].Vertices[k] = Prototype.Mesh.Faces[j].Vertices[k];
					if (Mesh.Faces[j].Vertices[k].Normal.NormSquared() != 0.0)
					{
						Mesh.Faces[j].Vertices[k].Normal.Rotate(AuxTransformation);
						Mesh.Faces[j].Vertices[k].Normal.Rotate(BaseTransformation);
					}
				}
			}

			// materials
			Mesh.Materials = new MeshMaterial[Prototype.Mesh.Materials.Length];
			for (int j = 0; j < Prototype.Mesh.Materials.Length; j++)
			{
				Mesh.Materials[j] = Prototype.Mesh.Materials[j];
				Mesh.Materials[j].Color *= Brightness;
			}

			const double minBlockLength = 20.0;
			if (BlockLength < minBlockLength)
			{
				BlockLength = BlockLength * System.Math.Ceiling(minBlockLength / BlockLength);
			}

			if (AccurateObjectDisposal)
			{
				StartingDistance += (float) TrackPosition;
				EndingDistance += (float) TrackPosition;
				double z = BlockLength * System.Math.Floor(TrackPosition / BlockLength);
				startingDistance = System.Math.Min(z - BlockLength, (double) StartingDistance);
				endingDistance = System.Math.Max(z + 2.0 * BlockLength, (double) EndingDistance);
				StartingDistance = (float) (BlockLength * System.Math.Floor(startingDistance / BlockLength));
				EndingDistance = (float) (BlockLength * System.Math.Ceiling(endingDistance / BlockLength));
			}
			else
			{
				StartingDistance = (float) startingDistance;
				EndingDistance = (float) endingDistance;
			}

			if (BlockLength != 0.0)
			{
				checked
				{
					GroupIndex = (short) NumberFormats.Mod(System.Math.Floor(StartingDistance / BlockLength), System.Math.Ceiling(ViewingDistance / BlockLength));
				}
			}
		}

		/// <summary>Callback function to create the object within the world</summary>
		public override void CreateObject(Vector3 Position, Transformation BaseTransformation, Transformation AuxTransformation,
			int SectionIndex, bool AccurateObjectDisposal, double StartingDistance, double EndingDistance, double BlockLength,
			double TrackPosition, double Brightness, bool DuplicateMaterials)
		{
			currentHost.CreateStaticObject(this, Position, BaseTransformation, AuxTransformation, AccurateObjectDisposal, 0.0, StartingDistance, EndingDistance, BlockLength, TrackPosition, Brightness);
		}

		/// <inheritdoc />
		public override void OptimizeObject(bool PreserveVerticies, int Threshold, bool VertexCulling)
		{
			int v = Mesh.Vertices.Length;
			int m = Mesh.Materials.Length;
			int f = Mesh.Faces.Length;
			if (f >= Threshold)
			{
				return;
			}

			// eliminate invalid faces and reduce incomplete faces
			for (int i = 0; i < f; i++)
			{
				int type = Mesh.Faces[i].Flags & MeshFace.FaceTypeMask;
				bool keep;
				if (type == MeshFace.FaceTypeTriangles)
				{
					keep = Mesh.Faces[i].Vertices.Length >= 3;
					if (keep)
					{
						int n = (Mesh.Faces[i].Vertices.Length / 3) * 3;
						if (Mesh.Faces[i].Vertices.Length != n)
						{
							Array.Resize<MeshFaceVertex>(ref Mesh.Faces[i].Vertices, n);
						}
					}
				}
				else if (type == MeshFace.FaceTypeQuads)
				{
					keep = Mesh.Faces[i].Vertices.Length >= 4;
					if (keep)
					{
						int n = Mesh.Faces[i].Vertices.Length & ~3;
						if (Mesh.Faces[i].Vertices.Length != n)
						{
							Array.Resize<MeshFaceVertex>(ref Mesh.Faces[i].Vertices, n);
						}
					}
				}
				else if (type == MeshFace.FaceTypeQuadStrip)
				{
					keep = Mesh.Faces[i].Vertices.Length >= 4;
					if (keep)
					{
						int n = Mesh.Faces[i].Vertices.Length & ~1;
						if (Mesh.Faces[i].Vertices.Length != n)
						{
							Array.Resize<MeshFaceVertex>(ref Mesh.Faces[i].Vertices, n);
						}
					}
				}
				else
				{
					keep = Mesh.Faces[i].Vertices.Length >= 3;
				}

				if (!keep)
				{
					for (int j = i; j < f - 1; j++)
					{
						Mesh.Faces[j] = Mesh.Faces[j + 1];
					}

					f--;
					i--;
				}
			}

			// eliminate unused materials
			bool[] materialUsed = new bool[m];
			for (int i = 0; i < f; i++)
			{
				materialUsed[Mesh.Faces[i].Material] = true;
			}

			for (int i = 0; i < m; i++)
			{
				if (!materialUsed[i])
				{
					for (int j = 0; j < f; j++)
					{
						if (Mesh.Faces[j].Material > i)
						{
							Mesh.Faces[j].Material--;
						}
					}

					for (int j = i; j < m - 1; j++)
					{
						Mesh.Materials[j] = Mesh.Materials[j + 1];
						materialUsed[j] = materialUsed[j + 1];
					}

					m--;
					i--;
				}
			}

			// eliminate duplicate materials
			for (int i = 0; i < m - 1; i++)
			{
				for (int j = i + 1; j < m; j++)
				{
					if (Mesh.Materials[i] == Mesh.Materials[j])
					{
						for (int k = 0; k < f; k++)
						{
							if (Mesh.Faces[k].Material == j)
							{
								Mesh.Faces[k].Material = (ushort) i;
							}
							else if (Mesh.Faces[k].Material > j)
							{
								Mesh.Faces[k].Material--;
							}
						}

						for (int k = j; k < m - 1; k++)
						{
							Mesh.Materials[k] = Mesh.Materials[k + 1];
						}

						m--;
						j--;
					}
				}
			}

			/* TODO:
			 * Use a hash based technique
			 */
			// Cull vertices based on hidden option.
			// This is disabled by default because it adds a lot of time to the loading process.
			if (!PreserveVerticies && VertexCulling)
			{
				// eliminate unused vertices
				for (int i = 0; i < v; i++)
				{
					bool keep = false;
					for (int j = 0; j < f; j++)
					{
						for (int k = 0; k < Mesh.Faces[j].Vertices.Length; k++)
						{
							if (Mesh.Faces[j].Vertices[k].Index == i)
							{
								keep = true;
								break;
							}
						}

						if (keep)
						{
							break;
						}
					}

					if (!keep)
					{
						for (int j = 0; j < f; j++)
						{
							for (int k = 0; k < Mesh.Faces[j].Vertices.Length; k++)
							{
								if (Mesh.Faces[j].Vertices[k].Index > i)
								{
									Mesh.Faces[j].Vertices[k].Index--;
								}
							}
						}

						for (int j = i; j < v - 1; j++)
						{
							Mesh.Vertices[j] = Mesh.Vertices[j + 1];
						}

						v--;
						i--;
					}
				}

				// eliminate duplicate vertices
				for (int i = 0; i < v - 1; i++)
				{
					for (int j = i + 1; j < v; j++)
					{
						if (Mesh.Vertices[i] == Mesh.Vertices[j])
						{
							for (int k = 0; k < f; k++)
							{
								for (int h = 0; h < Mesh.Faces[k].Vertices.Length; h++)
								{
									if (Mesh.Faces[k].Vertices[h].Index == j)
									{
										Mesh.Faces[k].Vertices[h].Index = (ushort) i;
									}
									else if (Mesh.Faces[k].Vertices[h].Index > j)
									{
										Mesh.Faces[k].Vertices[h].Index--;
									}
								}
							}

							for (int k = j; k < v - 1; k++)
							{
								Mesh.Vertices[k] = Mesh.Vertices[k + 1];
							}

							v--;
							j--;
						}
					}
				}
			}

			// structure optimization
			// Trangularize all polygons and quads into triangles
			for (int i = 0; i < f; ++i)
			{
				byte type = (byte) (Mesh.Faces[i].Flags & MeshFace.FaceTypeMask);
				// Only transform quads and polygons
				if (type == MeshFace.FaceTypeQuads || type == MeshFace.FaceTypePolygon)
				{
					int staring_vertex_count = Mesh.Faces[i].Vertices.Length;

					// One triange for the first three points, then one for each vertex
					// Wind order is maintained.
					// Ex: 0, 1, 2; 0, 2, 3; 0, 3, 4; 0, 4, 5; 
					int tri_count = (staring_vertex_count - 2);
					int vertex_count = tri_count * 3;

					// Copy old array for use as we work
					MeshFaceVertex[] original_poly = (MeshFaceVertex[]) Mesh.Faces[i].Vertices.Clone();

					// Resize new array
					Array.Resize(ref Mesh.Faces[i].Vertices, vertex_count);

					// Reference to output vertices
					MeshFaceVertex[] out_verts = Mesh.Faces[i].Vertices;

					// Triangularize
					for (int tri_index = 0, vert_index = 0, old_vert = 2; tri_index < tri_count; ++tri_index, ++old_vert)
					{
						// First vertex is always the 0th
						out_verts[vert_index] = original_poly[0];
						vert_index += 1;

						// Second vertex is one behind the current working vertex
						out_verts[vert_index] = original_poly[old_vert - 1];
						vert_index += 1;

						// Third vertex is current working vertex
						out_verts[vert_index] = original_poly[old_vert];
						vert_index += 1;
					}

					// Mark as triangle
					unchecked
					{
						Mesh.Faces[i].Flags &= (byte) ~MeshFace.FaceTypeMask;
						Mesh.Faces[i].Flags |= MeshFace.FaceTypeTriangles;
					}
				}
			}

			// decomposit TRIANGLES and QUADS
			for (int i = 0; i < f; i++)
			{
				int type = Mesh.Faces[i].Flags & MeshFace.FaceTypeMask;
				int face_count = 0;
				byte face_bit = 0;
				if (type == MeshFace.FaceTypeTriangles)
				{
					face_count = 3;
					face_bit = MeshFace.FaceTypeTriangles;
				}
				else if (type == MeshFace.FaceTypeQuads)
				{
					face_count = 4;
					face_bit = MeshFace.FaceTypeQuads;
				}

				if (face_count == 3 || face_count == 4)
				{
					if (Mesh.Faces[i].Vertices.Length > face_count)
					{
						int n = (Mesh.Faces[i].Vertices.Length - face_count) / face_count;
						while (f + n > Mesh.Faces.Length)
						{
							Array.Resize<MeshFace>(ref Mesh.Faces, Mesh.Faces.Length << 1);
						}

						for (int j = 0; j < n; j++)
						{
							Mesh.Faces[f + j].Vertices = new MeshFaceVertex[face_count];
							for (int k = 0; k < face_count; k++)
							{
								Mesh.Faces[f + j].Vertices[k] = Mesh.Faces[i].Vertices[face_count + face_count * j + k];
							}

							Mesh.Faces[f + j].Material = Mesh.Faces[i].Material;
							Mesh.Faces[f + j].Flags = Mesh.Faces[i].Flags;
							unchecked
							{
								Mesh.Faces[i].Flags &= (byte) ~MeshFace.FaceTypeMask;
								Mesh.Faces[i].Flags |= face_bit;
							}
						}

						Array.Resize<MeshFaceVertex>(ref Mesh.Faces[i].Vertices, face_count);
						f += n;
					}
				}
			}

			// Squish faces that have the same material.
			{
				bool[] can_merge = new bool[f];
				for (int i = 0; i < f - 1; ++i)
				{
					int merge_vertices = 0;

					// Type of current face
					int type = Mesh.Faces[i].Flags & MeshFace.FaceTypeMask;
					int face = Mesh.Faces[i].Flags & MeshFace.Face2Mask;

					// Find faces that can be merged
					for (int j = i + 1; j < f; ++j)
					{
						int type2 = Mesh.Faces[j].Flags & MeshFace.FaceTypeMask;
						int face2 = Mesh.Faces[j].Flags & MeshFace.Face2Mask;

						// Conditions for face merger
						bool mergeable = (type == MeshFace.FaceTypeTriangles) &&
						                 (type == type2) &&
						                 (face == face2) &&
						                 (Mesh.Faces[i].Material == Mesh.Faces[j].Material);

						can_merge[j] = mergeable;
						merge_vertices += mergeable ? Mesh.Faces[j].Vertices.Length : 0;
					}

					if (merge_vertices == 0)
					{
						continue;
					}

					// Current end of array index
					int last_vertex_it = Mesh.Faces[i].Vertices.Length;

					// Resize current face's vertices to have enough room
					Array.Resize(ref Mesh.Faces[i].Vertices, last_vertex_it + merge_vertices);

					// Merge faces
					for (int j = i + 1; j < f; ++j)
					{
						if (can_merge[j])
						{
							// Copy vertices
							Mesh.Faces[j].Vertices.CopyTo(Mesh.Faces[i].Vertices, last_vertex_it);

							// Adjust index
							last_vertex_it += Mesh.Faces[j].Vertices.Length;
						}
					}

					// Remove now unused faces
					int jump = 0;
					for (int j = i + 1; j < f; ++j)
					{
						if (can_merge[j])
						{
							jump += 1;
						}
						else if (jump > 0)
						{
							Mesh.Faces[j - jump] = Mesh.Faces[j];
						}
					}

					// Remove faces removed from face count
					f -= jump;
				}
			}
			// finalize arrays
			if (v != Mesh.Vertices.Length)
			{
				Array.Resize<VertexTemplate>(ref Mesh.Vertices, v);
			}

			if (m != Mesh.Materials.Length)
			{
				Array.Resize<MeshMaterial>(ref Mesh.Materials, m);
			}

			if (f != Mesh.Faces.Length)
			{
				Array.Resize<MeshFace>(ref Mesh.Faces, f);
			}
		}
	}
}


