# ScrollView Dinamico en Swift
Pasos para crear el scroll view dinamico

# 1 - Se crea el viewController y se deja caer el elemento scrollView 
	
- con (0,0,0,0) para que ocupe toda la pantalla
	
- Otro detalle se puede cambiar el alto del ViewController total para trabajar con mayor facilidad

- Al scrollview hay que quitarle el Content Layout Guides
	
  
# 2 - dentro del scrollview se deja caer una UIView
	
A) Se le coloca el equal width de la vista que esta encima del scrollview
	
B) Se le coloca el equal height con la vista que esta encima del scrollview [A una prioridad de 250]
	
C) Es importante que el primer y ultimo elemento dentro de este view definan los "padding" 
el primero en el top y el ultimo en el bottom 


# Para xCode 11 

El Scrollview funciona un poco diferente, para esto se debe crear una vista dentro del view principal, quedaria así:

+ ViewPrincipal
+ -- ViewContent (0,0,0,0)
+ --- ScrollView (0,0,0,0)
+ ---- ViewChildContend (0,0,0,0) (EqualWeight = WeightViewContent) (EquealHeight = HeightViewContent)
+ ----- First (Top)
+ ----- Last (Bottom) (Marcando la casilla "Constraint to margin")

<img src="scroll.png" alt="" />

¿Dudas? 
https://useyourloaf.com/blog/scroll-view-layouts-with-interface-builder/
