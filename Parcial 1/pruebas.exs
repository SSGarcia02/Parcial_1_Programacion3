Code.require_file("datos.exs")
Code.require_file("validaciones.exs")
Code.require_file("liquidacion.exs")
Code.require_file("reportes.exs")

# Primero validar
{validos, rechazados} = Validaciones.validar_servicios_validos_rechazados(
  Datos.servicios(),
  Datos.repartidores(),
  Datos.zonas()
)
r8 = Reportes.reporte_r8(validos, Datos.zonas())
IO.inspect(r8, label: "R8")
