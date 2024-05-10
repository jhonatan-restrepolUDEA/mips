.data
cadena: .asciiz "12345"
aviso: .asciiz "Cadena a convertir: "
saltodelinea: .asciiz "\n"
aviso2: .asciiz "Cadena convertida: " 
.text

main:
	#Voy a imprimir la cadena 12345a nivel de ejemplo, para eso uso syscall 4
	
	addi $v0, $zero, 4    #Establezco el modo de operacion para syscall 4
	la $a0, aviso
	syscall       
        la $a0, cadena
        syscall
        
	la $t0, cadena         #Inicializando contador al inicio de la cadena (Posicion de memoria, address de la base del arreglo asciiz)
	add $s0, $sp, 0        #Sacamos un backup de la base de la pila para no perdernos luego y poder recorrerla inversamente
	
	cicloApiladoNumerosIndividuales:
		lb $t1,($t0)    #Cargamos el byte del caracter que estamos analizando
		beqz $t1, inicioRecorridoPilaInversa #Si el elemento leido es el 0 (fin de las cadenas asciiz)
		add $t1,$t1,-48 #Como son bytes y necesitamos los valores numericos, debemos restarte 48 para alinear con la tabla ascii, Ej: 1=49 en ascii
		add $sp, $sp -1 #Separamos 1 byte de la pila para almacenar el numero, ya que necesitamos recorrer el numero luego en forma inversa.
		sb $t1,($sp)    #Apilamos el numero en cuestion
		add $t0,$t0,1   #Nos movemos al byte que sigue
		j cicloApiladoNumerosIndividuales#Repetimos el ciclo
		
	inicioRecorridoPilaInversa:#En este punto ya tenemoss el numero caracter a caracter en la pila, ahora tenemos que recorrer la pila inversa para convertir desde el digo menos significativo al mas significativo
		add $t0,$zero,0 #Inicializamos una variable para los productos (10^x)
		add $s1,$zero,0 #Inicializamos el registro donde haremos la acumulacion del numero final
		cicloNumero:
			beq $sp,$s0,fin  #Verificamos no estar en la cabeza de la pila (ya que en teoria estamos en el ultimo elemento apilado por el proceso anterior)
			lb $t1,($sp)     #Obtenemos el elemento de la pila, la cual tiene los numeros en ascii
			add $sp,$sp,1    #Movemos la pila al siguiente elemento
			beqz $t0, indice0
			#Si no es la cifra menos significativa, se multiplica por su base 10 y se acumula
			mul $t1,$t1,$t0
			add $s1,$s1,$t1
			mul $t0,$t0,10
			j cicloNumero
			indice0:         #Saltamos aqui cuando hablamos del numero de indice 0, o la cifra menos significativa
				add $s1,$t1,0
				add $t0,$t0,10
				j cicloNumero
		fin:
			#El numero finalmente en word queda $s1, lo imprimos en consola
			addi $v0,$zero,4      #Pasar a modo impresion cadena de texto
			la $a0,saltodelinea
			syscall
			la $a0,aviso2
			syscall
			
			addi $v0, $zero, 1   #Pasar a modo de impresion de numeros (word)
			addi $a0, $s1,0
			syscall
			
       
        
