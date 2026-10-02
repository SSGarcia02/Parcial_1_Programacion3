# SOLORZANO GARCIA SEBASTIÁN jssolorzanog@uqvirtual.edu.co
# CARDONA PETREL JUAN DAVID juand.cardonap@uqvirtual.edu.co
# MORALES LONDOÑO NIKOLL nikoll.moralesl@uqvirtual.edu.co
# Fecha: 1 de octubre del 2026

defmodule Liquidacion do
  @tarifa_base_por_kilometro 2500
  @kilometros_diarios_para_bonificacion 80
  @bonificacion_diaria 15000
  @alquiler_bicicleta 10000

  # Devuelve el multiplicador de ajuste por puntualidad según el rango del retraso
  def factor_puntualidad(retraso) do
    cond do
      retraso <= 0 -> 1.08
      retraso <= 10 -> 1.0
      retraso <= 30 -> 0.90
      true -> 0.75
    end
  end

  # Calcula el valor de un servicio: kilómetros × tarifa base × factor de puntualidad.
  def valor_servicio(servicio) do
    kilometros = servicio[:kilometros]
    retraso = servicio[:retraso]

    factor = factor_puntualidad(retraso)

    kilometros * factor * @tarifa_base_por_kilometro
  end

  # Agrupa los servicios válidos por la tupla {repartidor, dia}.
  # Devuelve un mapa donde cada clave es {repartidor, dia} y cada valor es la lista de servicios de ese grupo.
  def agrupar_por_dia(servicios_validos) do
    Enum.group_by(servicios_validos, fn s -> {s[:repartidor], s[:dia]} end)
  end

  # Suma los kilómetros de todos los servicios de un mismo día para un repartidor.
  def kilometros_dia(servicios_dia) do
    Enum.reduce(servicios_dia, 0, fn s, acc -> acc + s[:kilometros] end)
  end

  # Suma el valor de todos los servicios de un mismo día para un repartidor.
  def valor_dia(servicios_dia) do
    Enum.reduce(servicios_dia, 0, fn s, acc -> acc + valor_servicio(s) end)
  end

  # Devuelve la bonificación diaria si los kilómetros del día son ≥ 80, o 0 en caso contrario.
  def bonificacion_dia(kilometros_totales) do
    if kilometros_totales >= @kilometros_diarios_para_bonificacion do
      @bonificacion_diaria
    else
      0
    end
  end

  # Devuelve el alquiler diario de bicicleta si el repartidor usa bicicleta, o 0 si no.
  def alquiler_dia(usa_bicicleta) do
    if usa_bicicleta do
      @alquiler_bicicleta
    else
      0
    end
  end

  # Construye el resumen de un repartidor en un día: km, valor de servicios, bonificación y alquiler.
  #   clave — tupla {repartidor, dia} que identifica el grupo.
  #   servicios_dia — lista de servicios válidos de ese repartidor ese día.
  #   repartidores — lista completa de repartidores (para saber si usa bicicleta).
  def resumen_dia(clave, servicios_dia, repartidores) do
    {repartidor, dia} = clave
    kilometros = kilometros_dia(servicios_dia)
    valor = valor_dia(servicios_dia)
    bonificacion = bonificacion_dia(kilometros)

    info_repartidor = Enum.find(repartidores, fn r -> r[:codigo] == repartidor end)
    usa_bicicleta = info_repartidor[:bicicleta]
    alquiler = alquiler_dia(usa_bicicleta)

    %{
      repartidor: repartidor,
      dia: dia,
      kilometros: kilometros,
      valor_servicios: valor,
      bonificacion: bonificacion,
      alquiler: alquiler
    }
  end

  # Convierte el mapa agrupado por {repartidor, dia} en una lista de resúmenes diarios.
  #   agrupado — mapa %{{repartidor, dia} => [servicios]}.
  #   repartidores — lista completa de repartidores (se pasa a resumen_dia/3).
  def resumenes_diarios(agrupado, repartidores) do
    Enum.map(agrupado, fn {clave, servicios} ->
      resumen_dia(clave, servicios, repartidores)
    end)
  end

  # Calcula la liquidación semanal de un repartidor sumando sus resúmenes diarios.
  #   codigo — código del repartidor.
  #   resumenes — lista de resúmenes diarios de ese repartidor (puede estar vacía).
  #   info_repartidor — mapa del repartidor con :codigo, :nombre y :bicicleta.
  # Devuelve un mapa con km, valor de servicios, bonificaciones, alquiler y neto
  def liquidacion_repartidor(codigo, resumenes, info_repartidor) do
    nombre = info_repartidor[:nombre]

    kilometros = Enum.reduce(resumenes, 0, fn r, acc -> acc + r[:kilometros] end)
    valor_servicios = Enum.reduce(resumenes, 0, fn r, acc -> acc + r[:valor_servicios] end)
    bonificaciones = Enum.reduce(resumenes, 0, fn r, acc -> acc + r[:bonificacion] end)
    alquiler = Enum.reduce(resumenes, 0, fn r, acc -> acc + r[:alquiler] end)

    neto = valor_servicios + bonificaciones - alquiler

    %{
      codigo: codigo,
      nombre: nombre,
      kilometros: kilometros,
      valor_servicios: valor_servicios,
      bonificaciones: bonificaciones,
      alquiler: alquiler,
      neto: neto
    }
  end

  # Calcula la liquidación de todos los repartidores a partir de los servicios válidos.
  #   validos — lista de servicios válidos.
  #   repartidores — lista completa de repartidores (incluye los que no tuvieron servicios).
  # Devuelve una lista de mapas, uno por repartidor, con todos los valores en cero si no trabajó.
  def liquidacion(validos, repartidores) do
    validos_agrupados = agrupar_por_dia(validos)
    resumenes = resumenes_diarios(validos_agrupados, repartidores)

    Enum.map(repartidores, fn rep ->
      codigo = rep[:codigo]
      resumen_repartidor = Enum.filter(resumenes, fn res -> res[:repartidor] == codigo end)
      liquidacion_repartidor(codigo, resumen_repartidor, rep)
    end)
  end


end
