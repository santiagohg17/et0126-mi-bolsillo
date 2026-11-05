# Mi Bolsillo 💰

App movil hecha en Flutter para el curso **ET0126 · Programación de Dispositivos Móviles** de la I.U. Pascual Bravo.

## Propuesta de la app

Mi app se llama **Mi Bolsillo**. Está dirigida a **estudiantes universitarios que manejan poca plata al mes** (lo que les dan en la casa o lo que ganan en un trabajo de medio tiempo), quien necesita **saber en que se le va el dinero y no quedarse sin plata antes de que termine el mes**. La app le ayudará a **controlar sus gastos y no pasarse de su presupuesto** mediante **el registro de cada gasto con su categoria, una lista con todos los gastos y un anillo dibujado que muestra cuanto del presupuesto ya se gastó**.

- **Nombre de la app:** Mi Bolsillo
- **Usuario:** estudiantes de la universidad que tienen un presupuesto pequeño para transporte, comida, fotocopias, etc.
- **Problema:** muchas veces uno gasta "de a poquito" (un tinto, un pasaje, unas copias) y al final del mes no sabe en que se fue la plata y ya no le alcanza.
- **Solución:** la app deja anotar cada gasto rapido, muestra el total gastado contra el presupuesto del mes y avisa con colores cuando uno ya se esta acercando al limite.

### Funciones iniciales

1. Registrar un gasto con descripción, valor y categoria (Comida, Transporte, Estudio, Ocio, Otros).
2. Ver la lista de gastos y filtrarla por categoria (y borrar un gasto si me equivoque).
3. Definir el presupuesto del mes y ver en un anillo (Canvas) cuanto se ha gastado y cuantos dias le alcanza la plata que queda.

### Recorrido principal

1. El usuario abre la app y ve el nombre, una descripción corta y el anillo con su presupuesto.
2. Toca el botón **"Agregar gasto"**.
3. Escribe la descripción y el valor, escoge la categoria y toca **Guardar** (si falta algo o el valor no es valido la app le avisa).
4. Vuelve a la pantalla inicial, sale un mensaje de confirmación y el gasto aparece en la lista; el anillo y el resumen por categoria se actualizan.
5. Si quiere, filtra la lista por categoria o cambia su presupuesto con el botón del lapiz.

### Datos que guarda la app

- La lista de gastos: descripción, valor, categoria, fecha y una nota opcional.
- El presupuesto del mes (un número).

### Canvas

Con `CustomPainter` dibujo un **anillo de avance** que muestra el porcentaje del presupuesto que ya se gastó. El anillo cambia de color: verde si va bien, naranja si ya se gasto mas del 70% y rojo si se paso del presupuesto. Así el usuario entiende de un vistazo como va sin tener que hacer cuentas.

### ¿Por qué SharedPreferences y no SQLite?

Escogi **SharedPreferences** porque los datos de esta primera versión son pocos y sencillos: un número (el presupuesto) y una lista de gastos que guardo como texto JSON. Un estudiante no registra miles de gastos al mes, entonces no necesito hacer consultas complicadas ni tablas. Si mas adelante la app crece (por ejemplo, historial de varios meses o reportes) pensaria en cambiar a SQLite.
