defmodule Reportes do
  def total_kilometros(validos) do
    Enum.reduce(validos, 0, fn v, acc -> acc + v[:kilometros] end)
  end

  def total_pagado(liquidaciones) do
    Enum.reduce(liquidaciones, 0, fn l, acc -> acc + l[:neto] end)
  end

  def kilometros_por_repartidor_dia(validos) do
    agrupado = Liquidacion.agrupar_por_dia(validos)

    Map.new(
      Enum.map(agrupado, fn {clave, servicios} ->
        {clave, Liquidacion.kilometros_dia(servicios)}
      end)
    )
  end

  def zonas_por_repartidor(validos) do
    por_repartidor = Enum.group_by(validos, fn s -> s[:repartidor] end)

    zonas =
      Map.new(
        Enum.map(por_repartidor, fn {repartidor, servicios} ->
          {repartidor, Enum.uniq(Enum.map(servicios, fn s -> s[:zona] end))}
        end)
      )

    zonas
  end

  def retraso_ponderado(servicios) do
    numerador = Enum.reduce(servicios, 0, fn s, acc -> acc + s[:retraso] * s[:kilometros] end)

    denominador = Enum.reduce(servicios, 0, fn s, acc -> acc + s[:kilometros] end)

    if denominador == 0 do
      nil
    else
      numerador / denominador
    end
  end

  def reporte_r1(rechazados) do
    conteo = Enum.frequencies(Enum.map(rechazados, fn {_s, m} -> m end))
    {rechazados, conteo}
  end

  def reporte_r2(liquidaciones) do
    Enum.map(liquidaciones, fn liquidacion ->
      %{
        codigo: liquidacion[:codigo],
        nombre: liquidacion[:nombre],
        kilometros: liquidacion[:kilometros],
        valor_servicios: liquidacion[:valor_servicios],
        bonificaciones: liquidacion[:bonificaciones],
        alquiler: liquidacion[:alquiler],
        neto: liquidacion[:neto]
      }
    end)
  end

  def reporte_r3(validos) do
    validos
    |> Enum.group_by(fn servicio -> servicio[:dia] end)
    |> Map.new(fn {dia, servicios_dia} ->
      {dia, Liquidacion.kilometros_dia(servicios_dia)}
    end)
  end

  def reporte_r4(validos), do: total_kilometros(validos)

  def reporte_r5(liquidaciones), do: total_pagado(liquidaciones)

  def reporte_r6(validos) do
    validos
    |> Enum.group_by(fn servicio -> servicio[:repartidor] end)
    |> Enum.filter(fn {_codigo, servicios} -> length(servicios) >= 3 end)
    |> Map.new(fn {codigo, servicios} -> {codigo, retraso_ponderado(servicios)} end)
  end

  def reporte_r7(validos), do: zonas_por_repartidor(validos)

  def reporte_r8(validos, zonas) do
    zonas_ciudad = Enum.map(zonas, fn zona -> zona[:id] end)
    por_repartidor = Enum.group_by(validos, fn servicio -> servicio[:repartidor] end)

    por_repartidor
    |> Enum.filter(fn {_codigo, servicios} ->
      zonas_visitadas = Enum.map(servicios, fn servicio -> servicio[:zona] end)
      Enum.all?(zonas_ciudad, fn zona -> Enum.member?(zonas_visitadas, zona) end)
    end)
    |> Enum.map(fn {codigo, _servicios} -> codigo end)
  end

  def combinar_kilometros_aliada(kilometros_por_dia) do
    kilometros_aliada = %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}

    Map.merge(kilometros_aliada, kilometros_por_dia, fn _dia,
                                                        kilometros_aliados,
                                                        kilometros_jugutier ->
      kilometros_aliados + kilometros_jugutier
    end)
  end

  def ranking(reporte_r2, opciones) do
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(reporte_r2))
    orden = if orden == :asc, do: :asc, else: :desc

    reporte_r2
    |> Enum.sort_by(fn repartidor -> repartidor[:neto] end, orden)
    |> limitar(limite)
  end

  def medir_reportes(validos) do
    {tiempo_r3, resultado_r3} = :timer.tc(fn -> reporte_r3(validos) end)
    {tiempo_r6, resultado_r6} = :timer.tc(fn -> reporte_r6(validos) end)

    {tiempo_combinacion, resultado_combinacion} =
      :timer.tc(fn -> validos |> reporte_r3() |> combinar_kilometros_aliada() end)

    %{
      r3: %{microsegundos: tiempo_r3, resultado: resultado_r3},
      r6: %{microsegundos: tiempo_r6, resultado: resultado_r6},
      combinacion: %{microsegundos: tiempo_combinacion, resultado: resultado_combinacion}
    }
  end

  defp limitar(reporte, limite) when is_integer(limite) and limite >= 0 do
    Enum.take(reporte, limite)
  end

  defp limitar(reporte, _limite), do: reporte

  def obtener_categorias_unicas(ventas) do
    ventas
    |> Enum.map(& &1.categoria)
    |> Enum.uniq()
  end

  def agrupar_productos_por_categoria(ventas) do
    Enum.group_by(ventas, & &1.categoria, & &1.producto)
  end

  def contar_ventas_por_categoria(ventas) do
    Enum.frequencies_by(ventas, & &1.categoria)
  end

  def sumar_unidades_por_categoria(ventas) do
    Enum.reduce(ventas, %{}, fn venta, acumulado ->
      Map.update(
        acumulado,
        venta.categoria,
        venta.cantidad,
        &(&1 + venta.cantidad)
      )
    end)
  end

  def hay_venta_alta?(ventas) do
    Enum.any?(ventas, &(&1.cantidad > 4))
  end

  def ventas_validas?(ventas) do
    Enum.all?(ventas, &(&1.cantidad > 0))
  end

  def buscar_primera_venta_categoria(ventas, categoria) do
    Enum.find(ventas, &(&1.categoria == categoria))
  end
end
