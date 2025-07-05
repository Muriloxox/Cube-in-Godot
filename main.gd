# algebra_linear_demo.gd
extends MeshInstance3D

# Constantes
const VELOCIDADE_ROTACAO = 1.0
const FATOR_ESCALA = 1.05
const VELOCIDADE_TRANSLACAO = 1.0

# Vértices Originais (imutáveis)
const VERTICES_ORIGINAIS = [
	Vector3(-0.5, 0.5, -0.5), Vector3(0.5, 0.5, -0.5),
	Vector3(0.5, -0.5, -0.5), Vector3(-0.5, -0.5, -0.5),
	Vector3(-0.5, 0.5, 0.5), Vector3(0.5, 0.5, 0.5),
	Vector3(0.5, -0.5, 0.5), Vector3(-0.5, -0.5, 0.5)
]

# Vértices que serão transformados
var vertices_atuais = []

# Variáveis para ajuda visual
var visual_helper_node: MeshInstance3D
var immediate_mesh_resource = ImmediateMesh.new()


# inico de cena
func _ready() -> void:
	vertices_atuais = VERTICES_ORIGINAIS.duplicate()
	criar_mesh_do_cubo(vertices_atuais)
	
	visual_helper_node = MeshInstance3D.new()
	visual_helper_node.mesh = immediate_mesh_resource
	add_child(visual_helper_node)
	
	# ATUALIZADO: Novas instruções no print
	print("Pressione '1' para Rotacionar, '2' para Escalonar.")
	print("Use as SETAS para Transladar.")
	print("Pressione 'R' para Resetar tudo.")


# executando a cada frame
func _process(delta: float) -> void:
	var transformacao_aplicada = false
	
	# --- TRANSFORMAÇÕES LINEARES (MULTIPLICAÇÃO DE MATRIZ) ---
	# Rotação
	if Input.is_key_pressed(KEY_1):
		var angulo = VELOCIDADE_ROTACAO * delta
		var matriz_rotacao = rotacionar_manual(angulo, "X")
		for i in vertices_atuais.size():
			vertices_atuais[i] = matriz_rotacao * vertices_atuais[i]
		transformacao_aplicada = true
	
	if Input.is_key_pressed(KEY_2):
		var angulo = VELOCIDADE_ROTACAO * delta
		var matriz_rotacao = rotacionar_manual(angulo, "Y")
		for i in vertices_atuais.size():
			vertices_atuais[i] = matriz_rotacao * vertices_atuais[i]
		transformacao_aplicada = true
	
	if Input.is_key_pressed(KEY_3):
		var angulo = VELOCIDADE_ROTACAO * delta
		var matriz_rotacao = rotacionar_manual(angulo, "Z")
		for i in vertices_atuais.size():
			vertices_atuais[i] = matriz_rotacao * vertices_atuais[i]
		transformacao_aplicada = true

	# Escala
	if Input.is_key_pressed(KEY_S):
		var fator = pow(FATOR_ESCALA, delta)
		var matriz_escala = escalar_manual(fator, 1, 1)
		for i in vertices_atuais.size():
			vertices_atuais[i] = matriz_escala * vertices_atuais[i]
		transformacao_aplicada = true
		
	if Input.is_key_pressed(KEY_D):
		var fator = pow(FATOR_ESCALA, delta)
		var matriz_escala = escalar_manual(1, fator, 1)
		for i in vertices_atuais.size():
			vertices_atuais[i] = matriz_escala * vertices_atuais[i]
		transformacao_aplicada = true
		
	if Input.is_key_pressed(KEY_W):
		var fator = pow(FATOR_ESCALA, delta)
		var matriz_escala = escalar_manual(1, 1, fator)
		for i in vertices_atuais.size():
			vertices_atuais[i] = matriz_escala * vertices_atuais[i]
		transformacao_aplicada = true
		
		
	# --- TRANSFORMAÇÃO AFIM (ADIÇÃO DE VETOR) ---
	var vetor_translacao = Vector3.ZERO
	if Input.is_key_pressed(KEY_UP):
		vetor_translacao.y += 1.0
	if Input.is_key_pressed(KEY_DOWN):
		vetor_translacao.y -= 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		vetor_translacao.x += 1.0
	if Input.is_key_pressed(KEY_LEFT):
		vetor_translacao.x -= 1.0

	if vetor_translacao != Vector3.ZERO:
		vetor_translacao = vetor_translacao.normalized() * VELOCIDADE_TRANSLACAO * delta
		print(vetor_translacao)

		for i in vertices_atuais.size():
			vertices_atuais[i] = vertices_atuais[i] + vetor_translacao
		transformacao_aplicada = true
		
	# --- RESET ---
	if Input.is_key_pressed(KEY_R):
		vertices_atuais = VERTICES_ORIGINAIS.duplicate()
		transformacao_aplicada = true
	
	if transformacao_aplicada:
		criar_mesh_do_cubo(vertices_atuais)
	
	desenhar_ajudas_visuais()

func rotacionar_manual(angulo: float, eixo: String) -> Basis:
	var cos_a = cos(angulo)
	var sin_a = sin(angulo)
	
	var matriz_rotacao_basis: Basis
	
	match eixo.to_upper():
		"X":
			matriz_rotacao_basis = Basis(
				Vector3(1, 0, 0),       
				Vector3(0, cos_a, sin_a), 
				Vector3(0, -sin_a, cos_a) 
			)
		"Y":
			matriz_rotacao_basis = Basis(
				Vector3(cos_a, 0, -sin_a), 
				Vector3(0, 1, 0),       
				Vector3(sin_a, 0, cos_a) 
			)
		"Z":
			matriz_rotacao_basis = Basis(
				Vector3(cos_a, sin_a, 0), 
				Vector3(-sin_a, cos_a, 0),
				Vector3(0, 0, 1)
			)
		_:
			push_error("Eixo de rotação inválido: " + eixo + ". Use 'X', 'Y' ou 'Z'.")
			
	return matriz_rotacao_basis

func escalar_manual(fator_x: float, fator_y: float, fator_z: float) -> Basis:
	var matriz_escala_basis = Basis(
		Vector3(fator_x, 0, 0),   # Coluna 0 (vetor base X)
		Vector3(0, fator_y, 0),   # Coluna 1 (vetor base Y)
		Vector3(0, 0, fator_z)    # Coluna 2 (vetor base Z)
	)

	return matriz_escala_basis 




func criar_mesh_do_cubo(vertices: Array) -> void:
	if not mesh: mesh = ArrayMesh.new()
	mesh.clear_surfaces()
	var triangulos = [
		vertices[1],vertices[0],vertices[3], vertices[1],vertices[3],vertices[2],
		vertices[4],vertices[5],vertices[6], vertices[4],vertices[6],vertices[7],
		vertices[0],vertices[4],vertices[7], vertices[0],vertices[7],vertices[3],
		vertices[5],vertices[1],vertices[2], vertices[5],vertices[2],vertices[6],
		vertices[0],vertices[1],vertices[5], vertices[0],vertices[5],vertices[4],
		vertices[7],vertices[6],vertices[2], vertices[7],vertices[2],vertices[3]
	]
	var arrays = []; arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(triangulos)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = mesh

func desenhar_ajudas_visuais() -> void:
	immediate_mesh_resource.clear_surfaces()
	immediate_mesh_resource.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate_mesh_resource.surface_set_color(Color.RED)
	var v = VERTICES_ORIGINAIS
	var arestas = [
		v[0],v[1], v[1],v[2], v[2],v[3], v[3],v[0], v[4],v[5], v[5],v[6], v[6],v[7], v[7],v[4],
		v[0],v[4], v[1],v[5], v[2],v[6], v[3],v[7]
	]
	for i in range(0, arestas.size(), 2):
		immediate_mesh_resource.surface_add_vertex(arestas[i])
		immediate_mesh_resource.surface_add_vertex(arestas[i+1])
	immediate_mesh_resource.surface_set_color(Color.RED); immediate_mesh_resource.surface_add_vertex(Vector3.ZERO); immediate_mesh_resource.surface_add_vertex(Vector3.RIGHT * 2)
	immediate_mesh_resource.surface_set_color(Color.GREEN); immediate_mesh_resource.surface_add_vertex(Vector3.ZERO); immediate_mesh_resource.surface_add_vertex(Vector3.UP * 2)
	immediate_mesh_resource.surface_set_color(Color.BLUE); immediate_mesh_resource.surface_add_vertex(Vector3.ZERO); immediate_mesh_resource.surface_add_vertex(Vector3.FORWARD * 2)
	immediate_mesh_resource.surface_end()
