extends KinematicBody2D

var Velocidad = Vector2() #Velocidad actual de desplazamiento
export (float) var vel_desp
export (float) var vel_desp_b
enum direcciones {izquierda, derecha, arriba, abajo, diagabd,diagarrd, diababi, diabarri}
var direccion = derecha
var t_pelota #Si tiene o no pelota en pie


var moviendo = false;

var teclas = [false, false, false, false, false, false] #teclas[0] arriba, 1 abajo, 2 izquierda, 3 derecha, 4 patear, 5 pase

func _ready():
	pass

func _physics_process(delta):
	procesar_teclas()
	procesar_movimiento(delta)
	
func procesar_teclas():	
	if((teclas[4] || teclas[5]) && !moviendo): #Si patea o pasa
		Velocidad = Vector2(0,0)
		moviendo = true
		if(teclas[4]):
			patear(1)
		elif(teclas[5]):
			patear(0)
	elif(teclas[3] && !moviendo): #Si va hacia la derecha
		if(teclas[0]): #Si ademas va hacia arriba (SERIA DIAGONAL ARRIBA)
			Velocidad = Vector2(vel_desp/get_node("AnimationPlayer").get_animation("diarr").length, -vel_desp/get_node("AnimationPlayer").get_animation("diarr").length)
			get_node("AnimationPlayer").call_deferred("play","diarr")
			get_node("Sprite").flip_h = false
			direccion = diagarrd
			moviendo = true
		elif(teclas[1]): #Sino si ademas es abajo y derecha (DIAG ABAJO DERECHA)
			Velocidad = Vector2(vel_desp/get_node("AnimationPlayer").get_animation("diaba").length, vel_desp/get_node("AnimationPlayer").get_animation("diaba").length)
			get_node("AnimationPlayer").call_deferred("play","diaba")
			get_node("Sprite").flip_h = false
			direccion = diagabd
			moviendo = true
		else: #Si no va hacia arriba o abajo adicionalmente, entonces solo es derecha
			Velocidad = Vector2(vel_desp/get_node("AnimationPlayer").get_animation("der").length, 0)
			get_node("AnimationPlayer").call_deferred("play","der")
			direccion = derecha
			get_node("Sprite").flip_h = false
			moviendo = true
	elif(teclas[2] && !moviendo): #Si izquierda
		if(teclas[0]): #Si ademas arriba
			Velocidad = Vector2(-vel_desp/get_node("AnimationPlayer").get_animation("diarr").length, -vel_desp/get_node("AnimationPlayer").get_animation("diarr").length)
			get_node("AnimationPlayer").call_deferred("play","diarr")
			get_node("Sprite").flip_h = true
			direccion = diabarri
			moviendo = true
		elif(teclas[1]): #Si ademas abajo
			Velocidad = Vector2(-vel_desp/get_node("AnimationPlayer").get_animation("diaba").length, vel_desp/get_node("AnimationPlayer").get_animation("diaba").length)
			get_node("AnimationPlayer").call_deferred("play","diaba")
			get_node("Sprite").flip_h = true
			direccion = diababi
			moviendo = true
		else:
			Velocidad = Vector2(-vel_desp/get_node("AnimationPlayer").get_animation("der").length, 0)
			get_node("AnimationPlayer").call_deferred("play","der")
			direccion = izquierda
			get_node("Sprite").flip_h = true
			moviendo = true
	elif(teclas[0] && !moviendo):
		Velocidad = Vector2(0, -vel_desp/get_node("AnimationPlayer").get_animation("Arr").length)
		get_node("AnimationPlayer").call_deferred("play","Arr")
		direccion = arriba
		moviendo = true
	elif(teclas[1] && !moviendo):
		Velocidad = Vector2(0, vel_desp/get_node("AnimationPlayer").get_animation("Aba").length)
		get_node("AnimationPlayer").call_deferred("play","Aba")
		direccion = abajo
		moviendo = true
	

func procesar_movimiento(var delta_t):
	
	if(moviendo):
		var obj_colisionado = move_and_collide(Velocidad * delta_t)
		if(t_pelota != null && !t_pelota.get_node("AnimationPlayer").is_playing() && !t_pelota.pase): #Tengo pelota en pie
			if(abs($CollisionShape2D.position.distance_to(t_pelota.get_node("CollisionShape2D").position)) < 4): #Si estan proximos la pelota y el jugador
				if(check_direction_player(t_pelota.get_node("Area2D/CollisionShape2D").global_position) && $AnimationPlayer.current_animation_position <= 0.1):
					t_pelota.mover(Velocidad*get_node("AnimationPlayer").get_animation("Aba").length)
					t_pelota = null #Suelto la pelota
					var vel_provis = Velocidad
					Velocidad /= 4
					yield(get_tree().create_timer(1.5), "timeout") #Espero 1 segundo
					Velocidad = vel_provis
			else:
				t_pelota = null
			
			
		if(obj_colisionado != null && obj_colisionado.collider.is_in_group("pelota") && t_pelota == null):
			#Funciona de 10 hasta aca
			if(!obj_colisionado.collider.get_node("AnimationPlayer").is_playing()):
				t_pelota = obj_colisionado.collider #Asigno pelota como target
				

			
func restaurar_velocidad():
	pass
	
func check_direction_player(var ball_pos): #Testea direccion del player y posicion de la bola a ver si la mueve o no
	match(direccion):
		izquierda:
			if(ball_pos.x < $CollisionShape2D.global_position.x):
				return true
		derecha:
			if(ball_pos.x > $CollisionShape2D.global_position.x):
				return true
		arriba:
			if(ball_pos.y < $CollisionShape2D.global_position.y):
				return true
		abajo:
			if(ball_pos.y > $CollisionShape2D.global_position.y):
				return true
		diagabd:
			if(ball_pos.y > $CollisionShape2D.global_position.y):
				if(ball_pos.x > $CollisionShape2D.global_position.x):
					return true
		diagarrd:
			if(ball_pos.y < $CollisionShape2D.global_position.y):
				if(ball_pos.x > $CollisionShape2D.global_position.x):
					return true
		diababi:
			if(ball_pos.y > $CollisionShape2D.global_position.y):
				if(ball_pos.x < $CollisionShape2D.global_position.x):
					return true
		diabarri:
			if(ball_pos.y < $CollisionShape2D.global_position.y):
				if(ball_pos.x < $CollisionShape2D.global_position.x):
					return true
	return false

func _on_AnimationPlayer_animation_finished(anim_name):
	moviendo = false
	Velocidad = Vector2(0,0)
	
func patear(numero): #Numero 0 es pase, numero 1 es patear

	var velocidad_patear
	
	if(t_pelota != null): #Si no esta pateando el aire
		match(numero):
			0: #Pase
				velocidad_patear = t_pelota.vel_pas
			1: #Patear
				velocidad_patear = t_pelota.vel_shoot 

	match direccion:
		derecha:
			get_node("AnimationPlayer").call_deferred("play","pateard")
			if(t_pelota != null && !t_pelota.pase && !t_pelota.shoot):
				t_pelota.Velocidad = Vector2(velocidad_patear, 0)
		izquierda:
			get_node("AnimationPlayer").call_deferred("play","pateard")
			if(t_pelota != null && !t_pelota.pase && !t_pelota.shoot):
				t_pelota.Velocidad = Vector2(-velocidad_patear, 0)
		arriba:
			get_node("AnimationPlayer").call_deferred("play","pateararr")
			if(t_pelota != null && !t_pelota.pase && !t_pelota.shoot):
				t_pelota.Velocidad = Vector2(0, -velocidad_patear)
		abajo:
			get_node("AnimationPlayer").call_deferred("play","patearabaj")
			if(t_pelota != null && !t_pelota.pase && !t_pelota.shoot):
				t_pelota.Velocidad = Vector2(0, velocidad_patear)
		diagabd:
			get_node("AnimationPlayer").call_deferred("play","pateardaba")
			if(t_pelota != null && !t_pelota.pase && !t_pelota.shoot):
				t_pelota.Velocidad = Vector2(velocidad_patear, velocidad_patear)
		diagarrd:
			get_node("AnimationPlayer").call_deferred("play","pateardarr")
			if(t_pelota != null && !t_pelota.pase && !t_pelota.shoot):
				t_pelota.Velocidad = Vector2(velocidad_patear, -velocidad_patear)
		diababi:
			get_node("AnimationPlayer").call_deferred("play","pateardaba")
			if(t_pelota != null && !t_pelota.pase && !t_pelota.shoot):
				t_pelota.Velocidad = Vector2(-velocidad_patear, velocidad_patear)
		diabarri:
			get_node("AnimationPlayer").call_deferred("play","pateardarr")
			if(t_pelota != null && !t_pelota.pase && !t_pelota.shoot):
				t_pelota.Velocidad = Vector2(-velocidad_patear, -velocidad_patear)
			
	if(t_pelota != null): #Si esta en posesion del balon en ese momento
		match(numero):
			0:
				t_pelota.pase = true
			1:
				t_pelota.shoot = true
		t_pelota.get_node("AnimationPlayer").stop()
		t_pelota.mover(Velocidad*get_node("AnimationPlayer").get_animation("Aba").length)

			
	yield(get_tree().create_timer(0.5), "timeout")
	
	match direccion:
		derecha:
			get_node("AnimationPlayer").play("der")
		izquierda:
			get_node("AnimationPlayer").play("der")
		arriba:
			get_node("AnimationPlayer").play("Arr")
		abajo:
			get_node("AnimationPlayer").play("Aba")
		diagabd:
			get_node("AnimationPlayer").play("diaba")
		diagarrd:
			get_node("AnimationPlayer").play("diarr")
		diababi:
			get_node("AnimationPlayer").play("diaba")
		diabarri:
			get_node("AnimationPlayer").play("diarr")
	
func _on_Area2D_body_entered(body):	
	if body != self:
		pass

func _on_Area2D_body_exited(body):
	pass
	
