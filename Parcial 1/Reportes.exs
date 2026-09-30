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

  def reporte_r2(validos, zonas) do
    km_por_zona =
      validos
      |> Enum.group_by(fn s -> s[:zona] end)
      |> Map.new(fn {zona, servicios} -> {zona, Liquidacion.kilometros_dia(servicios)} end)

    zonas
    |> Enum.map(fn zona ->
      km = Map.get(km_por_zona, zona[:id], 0)
      densidad = km / zona[:area]

      %{
        id: zona[:id],
        nombre: zona[:nombre],
        area: zona[:area],
        km: km,
        densidad: densidad
      }
    end)
    |> Enum.sort_by(fn z -> z[:densidad] end, :desc)
  end

  def reporte_r3(validos) do
    km_por_dia =
      validos
      |> Enum.group_by(fn s -> s[:dia] end)
      |> Map.new(fn {dia, servicios} -> {dia, Liquidacion.kilometros_dia(servicios)} end)

    por_dia =
      Enum.map(1..6, fn dia ->
        km = Map.get(km_por_dia, dia, 0)
        %{dia: dia, km: km, alcanzo: km >= 500}
      end)

    todos = Enum.all?(por_dia, fn d -> d[:alcanzo] end)
    al_menos_uno = Enum.any?(por_dia, fn d -> d[:alcanzo] end)

    {por_dia, todos, al_menos_uno}
  end

  def reporte_r4(liquidaciones) do
    liquidaciones
    |> Enum.sort_by(fn l -> l[:neto] end, :desc)
    |> Enum.with_index(1)
    |> Enum.map(fn {l, posicion} ->
      %{
        posicion: posicion,
        codigo: l[:codigo],
        nombre: l[:nombre],
        kilometros: l[:kilometros],
        valor_servicios: l[:valor_servicios],
        bonificaciones: l[:bonificaciones],
        alquiler: l[:alquiler],
        neto: l[:neto]
      }
    end)
  end

  def reporte_r5(validos, repartidores) do
    km_por_repartidor_dia = kilometros_por_repartidor_dia(validos)
    nombres = Map.new(repartidores, fn r -> {r[:codigo], r[:nombre]} end)

    maximos_por_dia =
      Enum.map(1..6, fn dia ->
        del_dia =
          km_por_repartidor_dia
          |> Enum.filter(fn {{_rep, d}, _km} -> d == dia end)

        case del_dia do
          [] ->
            {dia, []}

          _ ->
            max_km = del_dia |> Enum.map(fn {_clave, km} -> km end) |> Enum.max()

            empatados =
              del_dia
              |> Enum.filter(fn {_clave, km} -> km == max_km end)
              |> Enum.map(fn {{rep, _d}, km} ->
                %{codigo: rep, nombre: Map.get(nombres, rep, rep), km: km}
              end)
              |> Enum.sort_by(fn r -> r[:codigo] end)

            {dia, empatados}
        end
      end)

    conteo_primeros =
      maximos_por_dia
      |> Enum.flat_map(fn {_dia, reps} -> reps end)
      |> Enum.map(fn r -> r[:codigo] end)
      |> Enum.frequencies()

    ganador =
      case conteo_primeros do
        mapa when map_size(mapa) == 0 ->
          nil

        _ ->
          max_veces = conteo_primeros |> Map.values() |> Enum.max()

          conteo_primeros
          |> Enum.filter(fn {_c, v} -> v == max_veces end)
          |> Enum.map(fn {c, _} -> c end)
      end

    {maximos_por_dia, conteo_primeros, ganador}
  end

  def reporte_r6(validos) do
    candidatos =
      validos
      |> Enum.group_by(fn s -> s[:repartidor] end)
      |> Enum.filter(fn {_codigo, servicios} -> length(servicios) >= 3 end)

    case candidatos do
      [] ->
        nil

      _ ->
        candidatos
        |> Enum.map(fn {codigo, servicios} ->
          %{codigo: codigo, retraso_ponderado: retraso_ponderado(servicios)}
        end)
        |> Enum.min_by(fn c -> c[:retraso_ponderado] end)
    end
  end

  def reporte_r7(liquidaciones, validos) do
  total_pagado = total_pagado(liquidaciones)
  total_km = total_kilometros(validos)

  costo_promedio =
    if total_km == 0 do
      nil
    else
      total_pagado / total_km
    end

  %{
    total_pagado: total_pagado,
    total_kilometros: total_km,
    costo_promedio: costo_promedio
  }
end

  def reporte_r8(validos, zonas) do
    zonas_ciudad = Enum.map(zonas, fn z -> z[:id] end)
    por_repartidor = Enum.group_by(validos, fn s -> s[:repartidor] end)

    por_repartidor
    |> Enum.filter(fn {_codigo, servicios} ->
      zonas_visitadas = servicios |> Enum.map(fn s -> s[:zona] end) |> Enum.uniq()
      Enum.all?(zonas_ciudad, fn z -> Enum.member?(zonas_visitadas, z) end)
    end)
    |> Enum.map(fn {codigo, _servicios} -> codigo end)
    |> Enum.sort()
  end

  def combinar_kilometros_aliada(por_dia) do
  kilometros_aliada = %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}
  km_jugutier = Map.new(por_dia, fn d -> {d[:dia], d[:km]} end)

  Map.merge(kilometros_aliada, km_jugutier, fn _dia, aliada, jugutier ->
    aliada + jugutier
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

  defp medir_promedio(fun, repeticiones \\ 1000) do
  tiempos =
    for _ <- 1..repeticiones do
      {t, _} = :timer.tc(fun)
      t
    end

  Enum.sum(tiempos) / repeticiones
end

  def medir_reportes(validos, liquidaciones, zonas, repartidores) do
  r2 = medir_promedio(fn -> reporte_r2(validos, zonas) end)
  r3 = medir_promedio(fn -> reporte_r3(validos) end)
  r4 = medir_promedio(fn -> reporte_r4(liquidaciones) end)
  r5 = medir_promedio(fn -> reporte_r5(validos, repartidores) end)
  r6 = medir_promedio(fn -> reporte_r6(validos) end)
  r7 = medir_promedio(fn -> reporte_r7(liquidaciones, validos) end)
  r8 = medir_promedio(fn -> reporte_r8(validos, zonas) end)

  %{r2: r2, r3: r3, r4: r4, r5: r5, r6: r6, r7: r7, r8: r8}
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
