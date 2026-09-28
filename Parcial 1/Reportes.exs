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
