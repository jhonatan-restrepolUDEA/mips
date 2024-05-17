.data
	buffer: .asciiz "20,30"										# Espacio reservado para guardar el contenido del vector, 256 elemento en total.
	.align 2
	separator: .asciiz ","										# Espacio para el separador de 1 palabra para no tener problemas de alineacion.
	.align 2
	vector: .space 1024										# Espacio reservado para el vector donde estara los numeros a organizar.
	newLine: .asciiz "\n"
	.align 2
.text

la $t0, separator								
lw $t0, ($t0)
la $t1, newLine
lw $t1, ($t1)
							
la $t2, buffer	
																
la $t3, vector								
la $t4, vector	

add $s0, $sp, $zero							

loop:

lb $t5, ($t2)
beqz $t5, fin
beq $t5, $t0, avanzarSumarPosicion4

sb $t5, ($t3)
add $t3, $t3, 1  # sumo 1 bit a la posicion del vector
add $t2, $t2, 1  # Sumo 1 bit a la posicion del buffer

j loop
 
avanzarSumarPosicion4:
add $t4, $t4, 4  # avanzar a la siguiente posicion del vector
li $t3, 0   # Cargar el apuntador de t2 para repetir el ciclo.
add $t3, $t4, $zero
add $t2, $t2, 1  # avanzar en el buffer.
j loop

fin:
add $t4, $t4, 4
sb $t1, ($t4)
la $t3, vector


imprimir:
li $v0, 4
la $a0, ($t3)
lw $t4, ($a0)
beq $t1, $t4, finn
add, $t3, $t3, 4
syscall
li $v0, 4
la $a0, separator
syscall

j imprimir

finn:
li $v0, 10												# Codigo para salir del sistema
syscall

