Code.require_file("Datos.exs", __DIR__)
Code.require_file("Validaciones.exs", __DIR__)
Code.require_file("Liquidacion.exs", __DIR__)
Code.require_file("Reportes.exs", __DIR__)

# Primero validar
{validos, _rechazados} = Validaciones.validar_servicios_validos_rechazados(
  Datos.servicios(),
  Datos.repartidores(),
  Datos.zonas()
)
r8 = Reportes.reporte_r8(validos, Datos.zonas())
IO.inspect(r8, label: "R8")
