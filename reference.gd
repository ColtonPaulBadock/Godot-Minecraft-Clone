
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#Reference file for gd script systems will be stored here,
#this script will not be ran by the godot engine or Gratis-Exemptus
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------




#Mesh data tool and Surface tool utilites
#pulled from the "global_variables.gd"
#script. Here we can use them for
#editing the surface layer and other parts of the enviroment.
var mdt = global_variables.meshDataTool;
var st = global_variables.surfaceTool;


setPartOfArrayMeshToTexture {:

extends MeshInstance3D

func _ready():
    var mesh = ArrayMesh.new()
    var arrays = []

	#NOTE: WE ARE SKPPING THIS INE FOR NOW
	#IF THERES ISSUES, ITS PROBABLY THIS.
    arrays.resize(Mesh.ARRAY_MAX)

    # Define vertices for a quad (two triangles)
    var vertices = PoolVector3Array([
        Vector3(0, 0, 0), # Vertex A
        Vector3(1, 0, 0), # Vertex B
        Vector3(1, 0, 1), # Vertex C
        Vector3(0, 0, 0), # Vertex A (again for second triangle)
        Vector3(1, 0, 1), # Vertex C (again for second triangle)
        Vector3(0, 0, 1)  # Vertex D
    ])
    arrays[Mesh.ARRAY_VERTEX] = vertices

    # Define UV coordinates for the texture
    var uvs = PoolVector2Array([
        Vector2(0, 0), # UV for A
        Vector2(1, 0), # UV for B
        Vector2(1, 1), # UV for C
        Vector2(0, 0), # UV for A
        Vector2(1, 1), # UV for C
        Vector2(0, 1)  # UV for D
    ])
    arrays[Mesh.ARRAY_TEX_UV] = uvs

    # Add the surface to the ArrayMesh
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

    # Create and assign material with the texture
    var material = StandardMaterial3D.new()
    var texture = preload("res://your_texture.png") # Replace with your texture path
    material.albedo_texture = texture
    mesh.surface_set_material(0, material) # Assign to the first surface

    self.mesh = mesh

	pass;

}



#Updates the world layer for the surface,
#ground, etc.
func updateWorldLayer():
	
	#Plane mesh; Used to generate the ArrayMesh3D
	var plane = PlaneMesh.new();
	
	#Default plane size for each fragment
	#and the total subdivisions (vertices)
	#of the planes are set here.
	#------
	#These are set from global_variables
	#for easy, on the fly editing
	plane.size = global_variables.plane_size;
	plane.subdivide_width = global_variables.plane_subdivide_depth;
	plane.subdivide_depth = global_variables.plane_subdivide_depth;
	
	#Create a array "PackedVector3Array" type of
	#each individual vetice from the verticies of the
	#PlaneMesh, and from this array we can set height,
	#and move the vertices to create curvature, etc.
	var arrays := plane.surface_get_arrays(0)
	var vertices : PackedVector3Array = arrays[ArrayMesh.ARRAY_VERTEX];
	
	#Set the y height of the terrain at each
	#vertice, this will use noise_manager
	#for terrain noise!
	#-------
	#Loop through each vertice in the plane,
	#this will allow us to indivdually address each
	#y-corrdinate.
	for i in range(vertices.size()):
		
		#The current vertice will
		#be refered to as "v".
		#Here we can edit anything about
		#the vertice, including the y level.
		var v = vertices[i];
		
		#Generate the terrain height
		#using noise+utilities from
		#noise_manager.
		v.y = ((1 * (noise_manager.worldTerrainNoise_heightAmplifier * noise_manager.worldTerrainNoise.get_noise_2d(v.x + global_position.x , v.z + global_position.z))) + v.y);# + global_variables.medianWorldLayer;
		
		#Update the vertice in the array with the changes we made.
		#Including:
		#-Y-level for terrain generation/noise.
		vertices[i] = v
	
	#Update the array mesh with our changes to its
	#vertices?
	#Not entirely sure what this does, but it
	#is pivotal for vertice terrain generation.
	#Thanks for inspiration GOOGLE!
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	
	#Here we create a new mesh
	#using changes to the vertices of the old
	#one; "TopLayer" is updated with these
	#changes.
	var new_mesh := ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	$TopLayer.mesh = new_mesh;
	
	# Create collision shape from the mesh
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(new_mesh.surface_get_arrays(0)[ArrayMesh.ARRAY_INDEX])
	
	# Create or update a StaticBody3D for collision
	var static_body := StaticBody3D.new();
	static_body.shape = shape
	
	$TopLayer.add_child(static_body);
	
	pass;
