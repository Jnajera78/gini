///////////////////////////////////////////////////////
* By Perez-Najera J. A. & Munoz-Ramos T.
///////////////////////////////////////////////////////
* input: base de datos con idh y gini por estado de 2008 a 2018 
* output: analizar la relacion entre ambas variables a traves de un panel de datos
///////////////////////////////////////////////////////
* Note:
* 1) sin acentos
* 2) resultados preliminares

////////////////////////////////////////////////////////
cls
set more off
clear

log using "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\pruebas171022.log", replace

///////////////////////////////////////////////////////
* By Perez-Najera J. A. & Munoz-Ramos T.
///////////////////////////////////////////////////////
* input: base de datos con idh y gini por estado de 2008 a 2018 
* output: analizar la relacion entre ambas variables a traves de un panel de datos
///////////////////////////////////////////////////////
* Note:
* 1) texto sin acentos
* 2) resultados preliminares

////////////////////////////////////////////////////////

* El primer paso es abrir la base de datos, construida que incluye el indice de desarrollo humano y el coeficiente de gini, para todos los estados de la republica, en el periodo 2008 a 2018; con el objetivo de identificar el tipo de relacion que existe entre ambas variables:

* En este caso, es una base de excel y se realiza una importacion, donde la primera fila es el nombre de las variables.

import excel "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\071122\idh_gini_pib.dta"

* El comando “describe” nos indica las características generales de los datos, incluyendo el nombre de la variable, tipo, formato y etiquetas:

describe

* El comando “sum” nos presenta el resumen de todas las variables:

sum 

* Para obtener la media de los datos se utiliza el comando “ameans”, el cual nos proporciona la media aritmética, geométrica y armónica (Es recomendable incluir el factor de expansión, pero se pueden obtener ambas para identificar las diferencias), por ejemplo:

ameans idh gini PIB

* Para obtener algunos datos de tendencia central y de dispersion que describen nuestros datos podemos utilizar el comando: “tabstat” el cual nos permite solicitar la desviación estándar y/o cuartiles entre otros, por ejemplo:

tabstat idh gini PIB, statistics ( mean sd median var max min cv semean )
tabstat idh gini PIB, statistics ( skewness kurtosis  p10 p25 p50 p75 p90 )

* cabe senalar que en esta base de datos no tenemos missing values

* Para graficar el histograma utilizamos el comando “histogram” e indicamos la variable (en este caso; continua), asi mismo guardamos la grafica en la carpeta seleccionada para no perder lo que hemos trabajado, por ejemplo:

histogram idh, normal
graph export "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\histogram_idh.png", replace
histogram gini, normal
graph export "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\histogram_gini.png", replace
histogram PIB, normal
graph export "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\histogram_gini.png", replace


* La grafica incluye la curva de distribucion normal, lo cual permite observar si se ajustan las observaciones de manera simetrica (si la media, mediana y moda coinciden, etc.)

* Es posible generar una grafica de caja, a fin de identificar si muchos valores se salen de los parametros centrales:

graph box idh gini
graph export "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\box_idh_gini.png", replace
graph box gini PIB
graph export "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\box_gini_pib.png", replace



* Se puede utilizar una grafica de dispersion para observar los datos; recordando que y es la variable dependiente y x la independiente:

twoway (scatter idh gini), scheme(s2mono)
graph export "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\dispersion_idh_gini.png", replace

* Asi mismo, podemos incluir una linea de tendencia para observar las caracteristicas de los datos; la cual es muy util ya que nos da una primera impresion de la relacion entre las variables, la linea de ajuste tiene una pendiente negativa, es decir, que a mayor desigualdad (gini), menor desarrollo (idh)

twoway (scatter idh gini) (lfit idh gini), scheme(s2mono)
graph export "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\disp_tenden.png", replace

* Para avanzar el analisis de la informacion es posible correr una regresion lineal, la cual podria indicarnos algunos parametros respecto a la relacion entre ambas variables, como se observo en la grafica anterior, sin embargo, faltara una interpretacion mas a profundidad de los resultado:

regress idh gini PIB
pwcorr idh gini PIB

* El siguiente paso es generar las especificaciones para correr un panel de datos e identificar cual seria el modelo (Yit=α+β1X1it+eit) mas adecuado para el caso:

xtset id year, yearly
       panel variable:  id (strongly balanced)
        time variable:  year, 2008 to 2018, but with gaps
                delta:  1 unit



* En ocasiones hay que instalar algunos comandos a fin de poder correr instrucciones futuras, es el caso del comando:

findit xtcsd

* Es recomendable trabajar con logaritmo en el caso del pib, debido a sus magnitudes, generamos la variable:
gen InY=ln( PIB)

* observamos la correlacion de las variables:
pwcorr idh gini InY, sig

* El siguiente paso es identificar cual es el mejor modelo para nuestro panel de datos (en su caso para comprobar que panel es mejor que MCO), (re significa: Modelo de efectos aleatorios (Random effects)) para ello utilizamos la siguiente instruccion:

xtreg idh gini InY, re

* podemos correr la siguiente prueba:

xttest0
xtcsd, pesaran abs

* donde, Pesaran's test of cross sectional independence  (Panel corto) Ho: Usar MCO ( > .05) H1: Usar Panel de Datos ( < .05) Existe heterogeneidad no observada

* Si la Prob>chi2 es mayor a 0.05 rechazo Ho, es decir, no hay correlación entre los efectos individuales y las variables explicativas, lo que indica que el estimador aleatorio debe ser utilizado. En caso contrario, Prob>chi2 es menor a 0.05, emplearíamos el estimador de efectos fijos.

*PRUEBA DE PESARAN
*Confirmar que es mas recomendable el panel
xtcsd, pesaran abs
*menor a 0.05 se recomienda el panel


* ahora bien, si seguimos con el panel de datos es necesario identificar que tipo es el mas recomendable: ¿Cual modelo debo utilizar Efectos fijos o Aleatorios?
* para tal fin, es necesario correr la prueba Hausman (nota fe=fixed effects; para compararlos)

xtreg idh gini InY, re
estimates store re1
xtreg idh gini, fe
estimates store fe1
hausman fe1 re1
hausman re1 fe1

* es posible correr el panel para efectos aleatorios indicando el comando vce(robust) la estimación se realiza considerando la heterocedasticidad de la muestra.
*menor a 0.05 mejor modelo el de EFECTOS FIJOS

*PRUEBA DE WOOLDRIDGE
*test de autocorrelacion


xtreg idh gini InY , re
* xtserial idh gini, output
xtserial idh gini InY, output


*TEST MODIFICADO DE WALD
*Heterocedasticidad
xtreg idh gini InY, fe
xtreg idh gini InY, re vce(robust)
xttest3
xtsum


*menor a 0.05 , existe heterocedasticidad
*MODELOS PARA CORREGIR LA HETEROCEDASTICIDAD
* Blackwell, J. L. (2005) , xtxtpcse , MODELO DE CORRECCIONES STANDARD
xtpcse idh gini InY, het

*MODELO POR MINIMOS GENERALIZADO FACTIBLE XTGLS

xtgls idh gini InY, p(h)

*MODELOS PARA CORREGIR AUTOCORRELACION Y HETEROCEDASTICIDAD

xtpcse idh gini InY, het c(ar1)

*NO HAY AUTOCORRELACION
*MODELO XTGLS ES EL MAS ROBUSTO

save "G:\Mi unidad\UV DOCTORADO\1_opt_cuantitativo\071122\desig_ale.dta", replace



*Interpretacion de los resultados: De manera intuitiva podemos identificar que con un modelo de datos panel de efectos fijos XTGLS y encontramos que existe correlacion entre las variables; y si el coeficiente de gini (desigualdad) se reduce, el idh (bienestar) se incrementa. con ello, podemos inferir empiricamente otra razon que sustenta la importancia de reducir la desigualdad del ingreso, como se expresa en la literatura existente.   
 
*ultima actualizacion 28-feb-23

log close

