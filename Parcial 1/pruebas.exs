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

km_por_dia = Reportes.kilometros_por_repartidor_dia(validos)
IO.inspect(map_size(km_por_dia), label: "grupos con km")
IO.inspect(Map.get(km_por_dia, {"M05", 3}), label: "M05 d3 km")
IO.inspect(Map.get(km_por_dia, {"M01", 4}), label: "M01 d4 km")
IO.inspect(Map.get(km_por_dia, {"M03", 1}), label: "M03 d1 km")
