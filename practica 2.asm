.data

    	filename:  .asciiz "vector.txt"                                         		# Nombre del archivo que contiene los numeros.
    	buffer:    .space 1024                                                  		# Espacio para almacenar el contenido del archivo.
    	separator: .space 4                                                     		# Espacion para almacenar el separador del archivo.
    	vector:    .space 1024                                                  		# Espacio para almacenar los numeros.
    	newLine:   .asciiz "\n"						    			# Nueva linea.

	msg_separator: .asciiz "Por favor ingrese el separador que conforma su archivo.\n"
	msg_contenido: .asciiz "Este es el contenido del archivo. \n"

.text
.globl main

	main:
		jal getSeparator
        	jal processesBuffer
        	#jal processesVector
        
        getSeparator:
            	# imprimir el mensaje del separador para que ingrese el caracter.
            	li $v0, 4									# Cargar el servicio para imprimir una cadena.
            	la $a0, msg_separator								# Cargar la direccion del mensaje
            	syscall                                                         # Llamar al sistema para que imprima el mensaje.
    
            # Leer el caracter del separador
            li $v0, 12                                                      # Cargar el servicio de lectura del caracter.
            syscall                                                         # Llamar al sistema para leer el separador.
            sb $v0, separator                                               # Almacenar el separador en la ubicacion de memoria 'separator'.
        
            # imprimir una nueva linea, solo por el orden
            li $v0, 4
            la $a0, newLine
            syscall
        
        processesBuffer:
            # Abrir el archivo en modo lectura
            li $v0, 13                                                      # Cargar el número de la llamada al sistema para abrir un archivo
            la $a0, filename                                                # Cargar la dirección del nombre del archivo
            li $a1, 0                                                       # Modo de apertura (0 para lectura)
            li $a2, 0                                                       # Modo de permisos (no se usa en este caso)
            syscall                                                         # Llamar al sistema

            move $s0, $v0                                                   # Guardar el descriptor de archivo en $s0

            # Leer el contenido del archivo
            li $v0, 14                                                      # Cargar el número de la llamada al sistema para leer de un archivo
            move $a0, $s0                                                   # Cargar el descriptor de archivo
            la $a1, buffer                                                  # Cargar la dirección del buffer donde se almacenará el contenido
            li $a2, 1024                                                    # Tamaño máximo de lectura
            syscall                                                         # Llamar al sistema

            # Imprimir el contenido del archivo
            li $v0, 4                                                       # Cargar el número de la llamada al sistema para imprimir una cadena
            la $a0, buffer                                                  # Cargar la dirección del buffer
            syscall                                                         # Llamar al sistema
            
            # imprimir una nueva linea, solo por el orden
            li $v0, 4
            la $a0, newLine
            syscall

            # Cerrar el archivo
            li $v0, 16                                                      # Cargar el número de la llamada al sistema para cerrar un archivo
            move $a0, $s0                                                   # Cargar el descriptor de archivo
            syscall                                                         # Llamar al sistema
                 
