# ScrollView Dinamico en Swift
Pasos para crear el scroll view dinamico

# 1 - Se crea el viewController y se deja caer el elemento scrollView 
	
	- con (0,0,0,0) para que ocupe toda la pantalla
	
	- Otro detalle se puede cambiar el alto del ViewController total para trabajar con mayor facilidad
  
# 2 - dentro del scrollview se deja caer una UIView
	
	A) Se le coloca el equal width de la vista que esta encima del scrollview
	
	B) Se le coloca el equal height con la vista que esta encima del scrollview [A una prioridad de 250]
	
	C) Es importante que el primer y ultimo elemento dentro de este view definan los "padding" 
	el primero en el top y el ultimo en el bottom 
