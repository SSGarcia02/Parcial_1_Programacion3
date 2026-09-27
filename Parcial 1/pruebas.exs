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
servicios_m05 = Enum.filter(validos, fn s -> s[:repartidor] == "M05" end)
IO.inspect(Reportes.retraso_ponderado(servicios_m05), label: "retraso ponderado M05")

promedio_simple = Enum.sum(Enum.map(servicios_m05, fn s -> s[:retraso] end)) / length(servicios_m05)
IO.inspect(promedio_simple, label: "promedio simple M05")

IO.inspect(Reportes.retraso_ponderado([]), label: "retraso ponderado vacío")
