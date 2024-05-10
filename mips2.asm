.data
	buffer: .asciiz "87,67"
	.align 2
    	vector: .space 1024
    	.align 2
    	separador: .asciiz ","

.text
	
	la $t0, separador						# Cargar la direccion del separador.
	lw $s1, ($t0)							# Cargamos el separador para usarlo luego.
	la $t0, buffer							# Apuntamos a la direccion del buffer.
	add $s0, $sp, 0							# Guardamos en $s0 la forma hasta ahora de la pila.
	la $t4, vector							# Direccion del vector.
	
	
	leerNumeros:
		lb $t1, ($t0)						# Cargamos el caracter a analizar.
		beqz $t1, convertirNumero				# Si la etiqueta esta nula, pasa a convertir ------TODO------
		beq $t1, $s1, convertirNumero				# Si el valor del caracter es el separador, saltar a convertir a numero.
		add $t1, $t1, -48					# Obtenemos el valor numerico del caracter.
		add $sp, $sp, -1					# Separamos un espacion en la pila para el numero.
		sb $t1, ($sp)						# Apilamos el numero.
		add $t0,$t0,1						# Nos movemos al siguiente caracter.
		j leerNumeros						# Repetimos el ciclo.
	convertirNumero:
		add $t2, $zero, 1					# Valor del exponente a multiplicar.
		add $s2, $zero, 0					# Se inicia el registro el cual contendra la suma.
		add $t0,$t0,1						# Se suma 1 a $t0, ya que se necesita que avance a la siguiente posicion cuando termine la conversion
		cicloNumero:
			beq $sp, $s0, guardarNumero			# Si ya no tengo elementos en la pila avanzo a la proxima iteracion.
			lb $t3, ($sp)					# Se obtiene el elemento de la pila.
			mul $t3, $t3, $t2				# Se multiplica el elemento de la pila por 10x^x
			add $s2, $s2, $t3				# Sumamos el valor de $s2 con la multiplicacion de $t3
			mul $t2, $t2, 10				# Multiplico el valor de $t2 x 10, asi avanzo en los exponentes.
			add $sp, $sp, 1					# Nos movemos al siguiente elemento de la pila.
			j cicloNumero					# Volvemos a iterar sobre la pila, hasta que se termine.
		guardarNumero:
			sw $s2, ($t4)					# Guardamos el valor de la suma en la posicion del vector.
			beqz $t1, fin					# Si el valor de $t0 es cero, se termino el buffer a convertir.
			add $t4, $t4, 4					# Avanzar a la siguiente posicion en memoria.
			j leerNumeros					# Saltamos al cliclo principal para leer los otros numeros.
	fin:								# Fin de la conversion de los numeros.	
		
			
			
					
		
		
		
