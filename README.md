# Sistema de liquidación de servicios de reparto

Proyecto de consola desarrollado en Elixir para validar servicios de reparto,
calcular la liquidación semanal de los repartidores y generar reportes de
operación.

## Requisitos

- Elixir instalado y disponible desde la terminal (`elixir --version`).
- No se necesita instalar dependencias externas ni crear una base de datos.

## Cómo ejecutar

Desde la carpeta raíz del proyecto, ejecute:

```powershell
elixir "Parcial 1/principal.exs"
```

El programa valida los servicios de ejemplo definidos en `Parcial 1/Datos.exs`.
Luego ofrece la opción de agregar un servicio para esta ejecución y genera los
reportes. Al final solicita un código de repartidor para mostrar su comprobante.
Los datos no se guardan entre ejecuciones; para cambiar los datos de ejemplo,
edite `Datos.exs`.

Para ejecutar la comprobación incluida (validación de datos y reporte R8),
use:

```powershell
elixir "Parcial 1/pruebas.exs"
```

## Agregar un servicio por consola

Cuando aparezca **Agregar un servicio adicional**, ingrese cinco datos en este
orden:

1. Código del repartidor.
2. Código de la zona.
3. Día.
4. Kilómetros recorridos.
5. Retraso en minutos.

Separe los datos con punto y coma (`;`), no con comas. Por ejemplo:

```text
M01;Z1;2;18;5
```

Esto representa el servicio del repartidor `M01`, en la zona `Z1`, el día 2,
con 18 kilómetros y 5 minutos de retraso. Se permiten espacios alrededor de
cada dato, por ejemplo `M01; Z1; 2; 18; 5`.

Los códigos disponibles y los rangos aceptados se muestran también en la
consola:

- Repartidores: `M01` a `M10`.
- Zonas: `Z1` a `Z4`.
- Día: entero entre 1 y 6.
- Kilómetros: número mayor que 0 y máximo 45.
- Retraso: número entre -30 y 180 minutos.

Presione **Enter** sin escribir nada si desea continuar sin agregar un
servicio. Si el formato o algún valor no es válido, el programa explica el
motivo y continúa sin agregar ese servicio.

## Qué genera el programa

- **R1:** servicios rechazados y cantidad de rechazos por motivo.
- **R2:** kilómetros y densidad de kilómetros por zona.
- **R3:** kilómetros por día y cumplimiento de la meta diaria.
- **R4:** liquidación de los repartidores, ordenada por valor neto.
- **R5:** repartidor o repartidores con más kilómetros en cada día.
- **R6:** mejor puntualidad.
- **R7:** total pagado y costo promedio.
- **R8:** repartidores que cubrieron todas las zonas.
- Una combinación de kilómetros con una empresa aliada.
- Un ranking de los cinco repartidores con mayor valor neto.
- Mediciones de ejecución de los reportes.
- Un comprobante individual para el código solicitado al final.

## Estructura del proyecto

Los archivos ejecutables y módulos están en `Parcial 1/`:

- `principal.exs`: coordina la validación, la entrada interactiva, los reportes
  y el comprobante.
- `Datos.exs`: datos de ejemplo de repartidores, zonas y servicios.
- `Validaciones.exs`: reglas de validación de los servicios.
- `Liquidacion.exs`: agrupación de servicios y cálculo de liquidaciones.
- `Reportes.exs`: generación de reportes y ranking.
- `Util.ex`: funciones auxiliares para la entrada y salida por consola.
- `Util2.ex`: utilidades adicionales para colecciones.
- `pruebas.exs`: script de comprobación de algunos módulos.
