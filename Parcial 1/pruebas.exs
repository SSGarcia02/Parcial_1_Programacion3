Code.require_file("datos.exs")
Code.require_file("validaciones.exs")
Code.require_file("liquidacion.exs")

{validos, _} = Validaciones.validar_servicios_validos_rechazados(Datos.servicios(), Datos.repartidores(), Datos.zonas())
agrupado = Liquidacion.agrupar_por_dia(validos)

# Caso 1: M05 día 3 → con bonificación y con bicicleta
IO.inspect(
  Liquidacion.resumen_dia({"M05", 3}, Map.get(agrupado, {"M05", 3}), Datos.repartidores()),
  label: "M05 d3 (bonif + alquiler)"
)

# Caso 2: M03 día 1 → sin bonificación pero con bicicleta
IO.inspect(
  Liquidacion.resumen_dia({"M03", 1}, Map.get(agrupado, {"M03", 1}), Datos.repartidores()),
  label: "M03 d1 (sin bonif + alquiler)"
)

# Caso 3: M02 día 2 → sin bonificación y sin bicicleta
IO.inspect(
  Liquidacion.resumen_dia({"M02", 2}, Map.get(agrupado, {"M02", 2}), Datos.repartidores()),
  label: "M02 d2 (sin bonif + sin alquiler)"
)
