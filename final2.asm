.data
	fileName: .asciiz "vector.txt"    								# Nombre del vector a leer.
	outFileName: .asciiz "output.txt"  								# nombre del archivo para guardar el resultado.
	.align 2
	newLine: .asciiz "\n"										# Salto de linea estetica.
	.align 2
	endPoint: .asciiz "*"										# Punto final del vector
	.align 2
	size: .space 4											# Variable para contener la cantidad de elementos del vector.
	buffer: .space 1024										# Espacio reservado para guardar el contenido del vector, 256 elemento en total.
	.align 2
	vector: .space 1024										# Espacio reservado para el vector donde estara los numeros a organizar.
	.align 2
	separator: .space 4										# Espacio para el separador de 1 palabra para no tener problemas de alineacion.
	
	msgSeparator: .asciiz "Por favor ingrese el separador que conforma su archivo.\n"
	msgContenido: .asciiz "Este es el contenido del archivo. \n"
.text
.globl main

	main:
		jal getSeparator
		jal processesBuffer
		jal processesVector
		jal sort
		jal saveFile
			
	# Finalizar el programa
	li $v0, 10											# Codigo para salir del sistema
	syscall
		
		
		
		
		
		
		getSeparator:
			# Imprimir el mensaje para pedir el separador
			li $v0, 4									# Cargar el servicio para imprimir una cadena.
			la $a0, msgSeparator								# Cargar la direccion del mensaje.
			syscall										# LLamar al sistema para imprimir el mensaje.
			# Leer el caracter que sera el separador
			li $v0, 12									# Cargar el servicio de lectura del caracter.
			syscall
			sb $v0, separator								# Almacenamos el separador en memoria.
			# Impirmir una nueva linea por orden
			li $v0, 4
			la $a0, newLine
			syscall
			
			jr $ra										# Volver a la pila en memoria de donde se llamo.
		
		processesBuffer:
			# Abrir el archivo en modo lectura
			li $v0, 13									# Cargar la operacion para abrir el archivo.
			la $a0, fileName								# Cargar la direccion del archivo.
			li $a1, 0									# Modo de apertura, solo lectura.
			li $a2, 0									# Permisos para el documento 0
			syscall
			
			add $s0, $zero, $v0								# Guardar el descriptor del archivo en $s0
			
			# Leer el contenido del archivo
			li $v0, 14									# Cargar la operacion para leer el archivo.
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
			li $v0, 16									# Operacion para cerrar el archivo.
			add $a0, $zero, $s0								# Cargar el descriptor del archivo.
			syscall
			
			jr $ra										# Regresar a la pila de ejecucion
			
		processesVector:
			la $t0, separator								# Cargar la direccion del separador.
			lw $t0, ($t0)									# Cargar el valor del separador.
			la $t1, endPoint								# Cargamos la direccion para marcar el final.
			lw $t1, ($t1)									# Cargamos el valor de la nueva linea.
			la $t2, buffer									# Cargar la direccion del buffer
			la $t3, vector									# Direccion del Vector.								
			la $t4, vector									# Copia de la direccion del vector.
			add $s0, $zero, 1								# Variable que contendra la cantidad de elementos del vector.
			
			leerNumero:
				lb $t5, ($t2)								# Se carga el bit en t5 donde esta apuntando t2 que es el buffer.
				beqz $t5, finProcessesVector						# Salto al final de la funcion. 
				beq $t5, $t0, avanzarVector						# Salta a la funcion que avanzara el vector a la proxima posicion, si se encuentra el separador.
				sb $t5, ($t3)								# Guardamos el valor en el vector.
				add $t3, $t3, 1  							# sumo 1 bit a la posicion del vector
				add $t2, $t2, 1  							# Sumo 1 bit a la posicion del buffer
				
				j leerNumero								# Realizamos otro ciclo para los caracteres faltantes antes del separador.
			
			avanzarVector:
				add $t4, $t4, 4  							# avanzar a la siguiente posicion del vector
				add $s0, $s0, 1								# Incrementar la cantidad de elementos del vector.
				li $t3, 0   								# Reiniciar el apuntador del vector.
				add $t3, $t4, $zero							# Copiar el valor de la copia del vector el cual se avanzo.
				add $t2, $t2, 1  							# avanzar en el buffer, ya que esta en el separador.
				
				j leerNumero								# Continuar con los siguientes caracteres.
			
		finProcessesVector:
			add $t4, $t4, 4									# Avanzamos a la siguiente posicion del vector.
			sb $t1, ($t4)									# Guardamos el punto final del vector.
			sb $s0, size									# Guardamos la cantidad de elementos en la variable size.
			
			jr $ra										# Volver a la pila de ejecucion.
		
		sort:
			la $t0, vector									# guardar la posicion del vector, funcionara como el apuntador j
			la $t1, vector									# Copia del vector, funcionara como el apuntador i
			add $t1, $t1, 4									# Avanzamos una posicion
			add $t2, $zero, 1								# Contador "i"
			la $a0, size									# Cargar la direccion del tamanio del vector.
			lw $a0, ($a0)									# Cargar el valor de la variable. tamanio
			add $sp, $sp, -4								# Separar espacio en la pila para guardar el ultimo ra
			sw $ra, ($sp)									# Guardamos la ultima llamada.
			
			loop:
				slt $t4, $t2, $a0							# Saber si i < n, donde n es el tamanio del vector.
				beqz $t4, finSort							# Saltar si ya se recorrio todo el vector.
				la $a1, ($t1)								# Cargar la direccion de la posicion "i" "now"
				lw $t9, ($t1)								# Separamos el valor  "now" para reemplazarlo en la posicion que corresponda.
				
				jal convertNumber							# Saltar a la funcion que me convertira lo que tenga $a1 en numero y sera guardado en s1
				
				add $s1, $a2, $zero							# Guardamos el valor de "now" en $s1
				add $t3, $t2, -1							# Contador "j" = i-1
				
				bgez $t3, secondLoop							# Si J >= 0, ir a realizar el siguiente bucle para dar espacio.
				
				secondLoop:
					la $a1, ($t0)							# Guardamos la direccion de [j] en a1 para convertirlo.
					lw $t8, ($t0)							# Guardar el valor de la posicion
					jal convertNumber						# Vamos a la funcion de conversion, el resultado estara en $a2
					add $s2, $a2, $zero						# Guardamos en s2 la representacion numerica de [j]
					slt $t4, $s2, $s1						# Saber si [j] < [i]
					beqz $t4, saveNow						# si es cero es porque no se puede separa mas espacio, por lo tanto redirecciona para guardar
					sw $t8, 4($t0)							# separo espacio [j+1] = [j]
					add $t3, $t3, -1						# Retrocedo una unidad el contador. j--
					add $t0, $t0, -4						# Retrocedemos una posicion el vector.
					bgez $t3, secondLoop						# Volver a reproducir el ciclo si j >= 0.
				saveNow:
					sw $t9, 4($t0)							# Se guarda el valor en el espacio separado
					add $t2, $t2, 1							# Incremento de la variable "i"
					add $t0, $t1, $zero						# Igualar mi apuntador j con i
					add $t1, $t1, 4							# Avanzo mi apuntador al siguiente elemento.
				j loop									# siguiente elemento del vector.
			
			finSort:
				lw $ra, ($sp)								# Recuperamos el llamado a la pila
				jr $ra									# Regresamos al llamado de la funcion.
				
			
			convertNumber:
				add $s0, $sp, $zero							# Guardamos una copia de como esta la pila.
				add $a2, $zero, $zero							# Variable que contendra la suma del valor numerico.
				add $t4, $zero, 1							# Variable por la cual se multiplicara 10x^$t4
				
				apilar:
					lb $t5, ($a1)							# Cargamos el bit de la variable que contiene el numero.
					beqz $t5, desapilar						# Si el bit era el ultimo, procedemos a desapilar los byte
					add $t5, $t5, -48						# Calculamos su valor numerico del bit.
					add $sp, $sp, -1						# Separamos espacio en la pila para el byte
					sb $t5, ($sp)							# Apilamos el numero.
					add $a1, $a1, 1							# Movernos al siguiente caracter del numero.
					j apilar							# Seguimos apilando los numeros.
				
				desapilar:
					beq $sp, $s0, finConvert					# Si la pila regreso a la normalidad, se acabo la conversion.
					lb $t5, ($sp)							# Cargamos el elemento de la pila.
					mul $t5, $t5, $t4						# multiplicamos el numero X*10^$t4
					add $a2, $a2, $t5						# Sumamos el acomulado de $a1 con la multiplicacion hecha antes.
					mul $t4, $t4, 10						# Avanzamos al siguiente exponentes.
					add $sp, $sp, 1							# Avanzamos al siguiente elemento de la pila.
					j desapilar							# Repetimos ciclo para desapilar los elementos.
			finConvert:
				jr $ra									# regresamos al punto del llamado de la funcion.
		
		
		saveFile:
			openFile:
				li $v0, 13								# Cargar el codigo para escribir en el archivo.
				la $a0, outFileName							# Nombre del archivo
				li $a1, 1								# Permisos para crear el archivo
				syscall
			writeFile:
				la $t0, vector     							# Cargar la direcci�n base del vector
    				la $t1, separator							# Cargar la direccion del separador.
    				la $t2, endPoint							# Cargar el final del vector.
    				lw $t2, ($t2)								# Cargar la palabra.
    				move $s0, $v0								# Guardar el archivo abierto en S1
    				
    				loopWrite:
    					li $v0, 15							# Codigo para escribir en el archivo.
    					add $a0, $s0, $zero						# Cargamos el archivo.
    					la $a1, ($t0)							# Cargamos el elemento del vector.
    					la $t3, ($t0)							# Copia del numero
    					add $a2, $zero, $zero						# Inicializacion de la longitud para cada caracter.
    					
    					longitud:
    						lb $t4, ($t3)						# bit del numero
    						beqz $t4, continue					# Continuar con la impresion.
    						add $a2, $a2, 1						# sumar 1 a la longitud
    						add $t3, $t3, 1						# Avanzar en el numero.
    						j longitud						# Revisar los otros bits
    					continue:
    					syscall
    					
    					la $a1, 4($t0)							# Cargar el siguiente caracter
    					lw $a1, ($a1)							# Cargar el contenido.
    					beq $a1, $t2, finSave						# Si se carga el separador, saltar al final.
    					
    					li $v0, 15							# Codigo para cargar el archivo
    					add $a0, $s0, $zero						# Cargamos el archivo.
    					la $a1, ($t1)							# Cargamos el separador.
    					la $a2, 1
    					syscall
    					
    					add $t0, $t0, 4							# Avanzamos a la siguiente posicion.
    					
    					j loopWrite							# Continuamos iterando.
    				finSave:
    					li $v0, 16         						# Cargar el c�digo de la syscall para cerrar un archivo
    					add $a0, $s0, $zero      					# Cargar el descriptor de archivo
    					syscall            						# Llamar a la syscall para cerrar el archivo
    					jr $ra 
    					
    									
				
				
											
			
			
