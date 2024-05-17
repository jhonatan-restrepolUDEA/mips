.data
	fileName: .asciiz "vector.txt"							# Nombre del vector a leer.
	buffer: .space 1024										# Espacio reservado para guardar el contenido del vector, 256 elemento en total.
	.align 2
	separator: .space 4										# Espacio para el separador de 1 palabra para no tener problemas de alineacion.
	.align 2
	vector: .space 1024										# Espacio reservado para el vector donde estara los numeros a organizar.
	outFilename: .asciiz "output.txt"  						# nombre del archivo para guardar el resultado.
	newLine: .asciiz "\n"
	.align 2
	number: .space 4
	
	msgSeparator: .asciiz "Por favor ingrese el separador que conforma su archivo.\n"
	msgContenido: .asciiz "Este es el contenido del archivo. \n"
.text
.globl main

	main:
		jal getSeparator
		jal processesBuffer
		jal processesVector
		
	
	# Finalizar el programa
	li $v0, 10												# Codigo para salir del sistema
	syscall
		
		
		
		
		
		
		getSeparator:
			# Imprimir el mensaje para pedir el separador
			li $v0, 4										# Cargar el servicio para imprimir una cadena.
			la $a0, msgSeparator							# Cargar la direccion del mensaje.
			syscall											# LLamar al sistema para imprimir el mensaje.
			# Leer el caracter que sera el separador
			li $v0, 12										# Cargar el servicio de lectura del caracter.
			syscall
			sb $v0, separator								# Almacenamos el separador en memoria.
			# Impirmir una nueva linea por orden
			li $v0, 4
			la $a0, newLine
			syscall
			
			jr $ra											# Volver a la pila en memoria de donde se llamo.
		
		processesBuffer:
			# Abrir el archivo en modo lectura
			li $v0, 13										# Cargar la operacion para abrir el archivo.
			la $a0, fileName								# Cargar la direccion del archivo.
			li $a1, 0										# Modo de apertura, solo lectura.
			li $a2, 0										# Permisos para el documento 0
			syscall
			
			add $s0, $zero, $v0								# Guardar el descriptor del archivo en $s0
			
			# Leer el contenido del archivo
			li $v0, 14										# Cargar la operacion para leer el archivo.
			add $a0, $zero, $s0								# Cargar el archivo.
			la $a1, buffer									# Cargar la direccion donde se guardara el contenido.
			li $a2, 1024									# Maximo de lectura.
			syscall
			
			# Imprimir el contenido del archivo
			li $v0, 4
			la $a0, msgContenido
			syscall
			
			li $v0, 4
			la $a0, buffer
			syscall
			
			li $v0, 4
			la $a0, newLine
			syscall
			
			# Cerrar el archivo.
			li $v0, 16										#Operacion para cerrar el archivo.
			add $a0, $zero, $s0								# Cargar el descriptor del archivo.
			syscall
			
			jr $ra											# Regresar a la pila de ejecucion
			
		processesVector:
			la $t0, separator								# Cargar la direccion del separador.
			lw $s1, ($t0)									# Cargar el separador para usarlo luego.
			la $t0, buffer									# Cargar la direccion del buffer
			add $s0, $sp, $zero								# Guardar en $s0 la manera en como esta la pila hasta ahora.
			la $t4, vector									# Direccion del vector.
			add $s3, $zero, $zero							# Variable que contendra la cantidad de elementos del vector.
			
			leerNumeros:
				lb $t1, ($t0)								# Cargamos el caracter inicial.
				beqz $t1, convertirNumero					# si la etiqueta esta nula, pasar a convertir el numero.
				beq $t1, $s1, convertirNumero				# Si el valor del caracter es el separador, saltar a convertir a numero.
				add $t1, $t1, -48							# Obtener el valor numerico del caracter.
				add $sp, $sp, -1							# Separar espacio en la pila para guardar el numero.
				sb $t1, ($sp)								# Apilar el numero
				add $t0, $t0, 1								# Moverse al siguiente caracter
				j leerNumeros								# Repetir ciclo.
			convertirNumero:
				add $t2, $zero, 1							# Valor del exponente a multiplicar
				add $s2, $zero, $zero						# Inicializar el registro que tendra la suma
				add $t0, $t0, 1								# Se suma 1 a $t0, ya que se necesita que avance a la siguiente posicion cuando termine la conversion	
				cicloNumero:
					beq $sp, $s0, guardarNumero				# Si ya no tengo elementos en la pila, redirijo a la funcion para guardar en el vector
					lb $t3, ($sp)							# Optener el elemento de la pila
					mul $t3, $t3, $t2						# Se multiplica el elemento de la pila por 10^x
					add $s2, $s2, $t3						# Acumulamos el valor multiplicado con los demas
					mul $t2, $t2, 10						# Avanzar al siguiente exponente.
					add $sp, $sp, 1							# Siguiente elemento de la pila
					j cicloNumero							# Repetir ciclo
				guardarNumero:
					sw $s2, ($t4)							# Guardar el valor de la suma en la posicion del vector.
					add $s3, $s3, 1							# Incremento de a una unidad los elementos que se guardaran en vector.
					beqz $t1, fin							# Si el valor es cero, ya se finalizo el buffer
					add $t4, $t4, 4							# Avanzar a la siguiente posicion en memoria.
					j leerNumeros							# Saltar al ciclo principal para leer los otros numeros
		fin:
			jr $ra											# regresar a la pila de ejecucion.		
		
		sortingVector:
    			addi $t0, $zero, 1         					# $t0 = i = 1
			LoopOuter:
    				bge $t0, $a1, EndOuter     				# if i >= length, end the loop
    				sll $t1, $t0, 2            				# $t1 = i * 4 (index of array[i])
    				add $t1, $t1, $a0          				# $t1 = &array[i]
    				lw $t2, 0($t1)             				# now = array[i]
    				addi $t3, $t0, -1          				# $t3 = j = i - 1
			LoopInner:
    				blt $t3, $zero, EndInner   				# if j < 0, end the inner loop
				sll $t4, $t3, 2            					# $t4 = j * 4 (index of array[j])
    				add $t4, $t4, $a0          				# $t4 = &array[j]
    				lw $t5, 0($t4)             				# array[j]
    				blt $t5, $t2, EndInner     				# if array[j] < now, end the inner loop
    				add $t6, $t4, 4            				# $t6 = (j + 1) * 4 (index of array[j+1])
    				sw $t5, 0($t6)             				# array[j + 1] = array[j]
    				addi $t3, $t3, -1          				# j--
    				j LoopInner
			EndInner:
    				addi $t7, $t3, 1           				# $t7 = (j + 1)
    				sll $t8, $t7, 2            				# $t8 = (j + 1) * 4 (index of array[j+1])
    				add $t8, $t8, $a0          				# $t8 = &array[j+1]
    				sw $t2, 0($t8)             				# array[j + 1] = now
    				addi $t0, $t0, 1           				# i++
    				j LoopOuter
			EndOuter:
    				jr $ra                      			# return
				
		saveFile:
			openFile:
				li $v0, 13									# Cargar el codigo para escribir en el archivo.
				la $a0, outFilename							# Nombre del archivo
				li $a1, 1									# Permisos para crear el archivo
				syscall
			writeFile:
				la $t0, vector     							# Cargar la direcci�n base del vector
    				add $t1, $s3, $zero          			# Inicializar el �ndice del vector desde la cantidad de elementos
    				la $t5, separator						# Cargar la direccion del separador.
    				move $s1, $v0							# Guardar el archivo abierto en S1

			loop:
				add $t1, $t1, -1        					# Reducir el indice.
				li $v0, 1
				sb $t2, number
				la $a0, ($t2)
				syscall
    				li $v0, 15          					# Cargar el c�digo de la syscall para guardar el valor
    				add $a0, $s1, $zero						# cargar el archivo a $a0
    				lw $t2, ($t0)      						# Cargar el elemento del vector en $t2
    				sb $t2, number								
    				la $a1, number
    				la $a2, 4								# Longitud del dato.
    				syscall            						# Llamar a la syscall para imprimir el elemento
    				add $t0, $t0, 4							# Seguir a la siguiente posicion.
    				beqz $t1, closeFile   					# Si es el ultimo elemento salir y no imprimir la coma
    				li $v0, 4
    				la $a0, ($t5)
    				syscall
    				li $v0, 15								# Cargar el c�digo de la syscall para imprimir un car�cter
    				add $a0, $s1, $zero
    				la $a1, ($t5)							# Cargar el separador para usarlo luego.
    				la $a2,  4								# Longitud del dato.
    				syscall      
    				j loop       							# Volver al inicio del bucle    				
			closeFile:
    				li $v0, 16         						# Cargar el c�digo de la syscall para cerrar un archivo
    				add $a0, $s0, $zero      				# Cargar el descriptor de archivo
    				syscall            						# Llamar a la syscall para cerrar el archivo
    				jr $ra             						# Retornar
