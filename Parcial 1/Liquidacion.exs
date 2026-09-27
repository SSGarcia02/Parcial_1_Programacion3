defmodule Liquidacion do
  @tarifa_base_por_kilometro 2500
  @kilometros_diarios_para_bonificacion 80
  @bonificacion_diaria 15000
  @alquiler_bicicleta 10000

  def factor_puntualidad(retraso) do
    cond do
      retraso <= 0 -> 1.08
      retraso <= 10 -> 1.0
      retraso <= 30 -> 0.90
      true -> 0.75
    end
  end

  def valor_servicio(servicio) do
    kilometros = servicio[:kilometros]
    retraso = servicio[:retraso]

    factor = factor_puntualidad(retraso)

    kilometros * factor * @tarifa_base_por_kilometro
  end

  def agrupar_por_dia(servicios_validos) do
    Enum.group_by(servicios_validos, fn s -> {s[:repartidor], s[:dia]} end)
  end

  def kilometros_dia(servicios_dia) do
    Enum.reduce(servicios_dia, 0, fn s, acc -> acc + s[:kilometros] end)
  end

  def valor_dia(servicios_dia) do
    Enum.reduce(servicios_dia, 0, fn s, acc -> acc + valor_servicio(s) end)
  end

  def bonificacion_dia(kilometros_totales) do
    if kilometros_totales >= @kilometros_diarios_para_bonificacion do
      @bonificacion_diaria
    else
      0
    end
  end

  def alquiler_dia(usa_bicicleta) do
    if usa_bicicleta do
      @alquiler_bicicleta
    else
      0
    end
  end

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

  def resumenes_diarios(agrupado, repartidores) do
    Enum.map(agrupado, fn {clave, servicios} ->
      resumen_dia(clave, servicios, repartidores)
    end)
  end

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
