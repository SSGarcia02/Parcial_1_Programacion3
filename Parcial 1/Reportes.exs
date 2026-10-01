defmodule Reportes do
  # Suma los kilómetros de todos los servicios válidos de la empresa.
  def total_kilometros(validos) do
    Enum.reduce(validos, 0, fn v, acc -> acc + v[:kilometros] end)
  end

  # Suma el neto de todas las liquidaciones para obtener el total pagado en la semana.
  # :neto -> campo del mapa de liquidacion_repartidor/3
  def total_pagado(liquidaciones) do
    Enum.reduce(liquidaciones, 0, fn l, acc -> acc + l[:neto] end)
  end

  # Construye un mapa con los kilómetros totales por repartidor y día.
  # Devuelve %{{repartidor, dia} => km}, útil para R5.
  def kilometros_por_repartidor_dia(validos) do
    agrupado = Liquidacion.agrupar_por_dia(validos)

    Map.new(
      Enum.map(agrupado, fn {clave, servicios} ->
        {clave, Liquidacion.kilometros_dia(servicios)}
      end)
    )
  end

  # Construye un mapa con las zonas distintas en las que trabajó cada repartidor.
  # Devuelve %{repartidor => [zonas distintas]}, útil para R8.
  def zonas_por_repartidor(validos) do
    por_repartidor = Enum.group_by(validos, fn s -> s[:repartidor] end)

    # Transforma el mapa de servicios agrupados por repartidor en un mapa de zonas distintas por repartidor.
    # Para cada repartidor, extrae las zonas de sus servicios y elimina duplicados con Enum.uniq/1.
    zonas =
      Map.new(
        Enum.map(por_repartidor, fn {repartidor, servicios} ->
          {repartidor, Enum.uniq(Enum.map(servicios, fn s -> s[:zona] end))}
        end)
      )

    zonas
  end

  # Calcula el retraso promedio ponderado por kilómetros: suma(retraso × km) / suma(km).
  # Devuelve nil si la lista está vacía (denominador 0) para evitar división por cero.
  def retraso_ponderado(servicios) do
    numerador = Enum.reduce(servicios, 0, fn s, acc -> acc + s[:retraso] * s[:kilometros] end)
    denominador = Enum.reduce(servicios, 0, fn s, acc -> acc + s[:kilometros] end)

    if denominador == 0 do
      nil
    else
      numerador / denominador
    end
  end

  # R1: devuelve los servicios rechazados junto con el conteo de rechazos por motivo.
  # Parámetro: rechazados — lista de tuplas {servicio, motivo}.
  def reporte_r1(rechazados) do
    conteo = Enum.frequencies(Enum.map(rechazados, fn {_s, m} -> m end))
    {rechazados, conteo}
  end

  # R2: kilómetros y densidad (km/área) por zona, ordenados de mayor a menor densidad.
  # validos — lista de servicios válidos.
  # zonas — lista de zonas con :id, :nombre y :area.
  # Las zonas sin servicios aparecen con km 0 y densidad 0.
  def reporte_r2(validos, zonas) do
    # Agrupa los servicios válidos por zona y suma los kilómetros de cada una.
    # Devuelve un mapa %{zona => km_total}, solo con las zonas que tienen servicios.
    km_por_zona =
      validos
      |> Enum.group_by(fn s -> s[:zona] end)
      |> Map.new(fn {zona, servicios} -> {zona, Liquidacion.kilometros_dia(servicios)} end)

    # Recorre todas las zonas (incluidas las que no tienen servicios) y calcula su densidad.
    # Usa Map.get/3 con valor por defecto 0 para las zonas sin servicios.
    zonas
    |> Enum.map(fn zona ->
      km = Map.get(km_por_zona, zona[:id], 0)
      densidad = km / zona[:area]

      # Construye un mapa por zona con id, nombre, área, km y densidad, y ordena la lista
      # de mayor a menor densidad.
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

  # R3: kilómetros por día e indicación de si se alcanzó la meta de 500 km.
  # Devuelve {lista_por_dia, todos, al_menos_uno}, donde:
  #   lista_por_dia — lista de mapas con :dia, :km, :alcanzo para los 6 días.
  #   todos — true si los 6 días alcanzaron la meta.
  #   al_menos_uno — true si al menos un día la alcanzó.
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

  # R4: liquidación de todos los repartidores, numerada y ordenada por neto descendente.
  # Parámetro: liquidaciones — lista que produce Liquidacion.liquidacion/2.
  # Devuelve una lista de mapas con posición, código, nombre, km, valor, bonificaciones, alquiler y neto.
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

  # R5: construye la lista de repartidores con más km en cada día (todos los empatados)
  #   validos — lista de servicios válidos.
  #   repartidores — lista completa de repartidores (para obtener nombres).
  # Devuelve una lista de tuplas {dia, [reps]} para los 6 días.
  def reporte_r5(validos, repartidores) do
    km_por_repartidor_dia = kilometros_por_repartidor_dia(validos)
    nombres = Map.new(repartidores, fn r -> {r[:codigo], r[:nombre]} end)

    # Recorre los 6 días y filtra, del mapa de km por repartidor y día,
    # solo las entradas cuyo día coincide con el actual.
    maximos_por_dia =
      Enum.map(1..6, fn dia ->
        del_dia =
          km_por_repartidor_dia
          |> Enum.filter(fn {{_rep, d}, _km} -> d == dia end)

        # Si no hay servicios ese día, devuelve {dia, []}.
        # Si hay, calcula el máximo de km, filtra todos los repartidores que lo alcanzaron (empates),
        # los convierte en mapas con código, nombre y km, y los ordena por código.
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

    # Cuenta cuántas veces cada repartidor quedó en primer lugar a lo largo de los 6 días.
    # Devuelve un mapa %{codigo => veces}.
    conteo_primeros =
      maximos_por_dia
      |> Enum.flat_map(fn {_dia, reps} -> reps end)
      |> Enum.map(fn r -> r[:codigo] end)
      |> Enum.frequencies()

    # Determina el ganador: el repartidor (o repartidores) que quedó primero más veces.
    # Devuelve nil si nadie quedó primero, o la lista de códigos con más primeros lugares.
    # La función retorna la tupla {maximos_por_dia, conteo_primeros, ganador}.
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

  # R6: encuentra el repartidor con mejor puntualidad entre los que tienen al menos 3 servicios válidos.
  # Devuelve un mapa %{codigo, retraso_ponderado} del mejor, o nil si nadie cumple.
  def reporte_r6(validos) do
    # Agrupa los servicios válidos por repartidor y filtra solo los que tienen 3 o más servicios.
    candidatos =
      validos
      |> Enum.group_by(fn s -> s[:repartidor] end)
      |> Enum.filter(fn {_codigo, servicios} -> length(servicios) >= 3 end)

    # Si no hay candidatos, devuelve nil.
    # Si hay, calcula el retraso ponderado de cada uno y devuelve el de menor valor (el más puntual).
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

  # R7: total pagado a todos los repartidores y costo promedio por kilómetro.
  #   liquidaciones — lista de liquidaciones por repartidor.
  #   validos — lista de servicios válidos (para el total de km).
  # Devuelve un mapa con total_pagado, total_kilometros y costo_promedio.
  # costo_promedio es nil si no hay kilómetros, para evitar división por cero.
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

  # R8: repartidores que realizaron al menos un servicio válido en todas las zonas.
  #   validos — lista de servicios válidos.
  #   zonas — lista de zonas (se extraen sus ids).
  # Devuelve una lista ordenada de códigos de repartidores que cubren las 4 zonas.
  def reporte_r8(validos, zonas) do
    zonas_ciudad = Enum.map(zonas, fn z -> z[:id] end)
    por_repartidor = Enum.group_by(validos, fn s -> s[:repartidor] end)

    # Filtra los repartidores cuyas zonas visitadas incluyen todas las zonas de la ciudad,
    # extrae solo sus códigos y los devuelve ordenados alfabéticamente.
    por_repartidor
    |> Enum.filter(fn {_codigo, servicios} ->
      zonas_visitadas = servicios |> Enum.map(fn s -> s[:zona] end) |> Enum.uniq()
      Enum.all?(zonas_ciudad, fn z -> Enum.member?(zonas_visitadas, z) end)
    end)
    |> Enum.map(fn {codigo, _servicios} -> codigo end)
    |> Enum.sort()
  end

  # Combina los km diarios de la empresa aliada con los de Jugutier.
  # Parámetro: por_dia — lista de mapas con :dia y :km que produce reporte_r3/1.
  # Suma los km cuando el día aparece en ambos mapas; conserva los días que solo están en uno.
  # Usa Map.merge/3 para que la función de resolución sume en lugar de reemplazar.
  def combinar_kilometros_aliada(por_dia) do
    kilometros_aliada = %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}
    km_jugutier = Map.new(por_dia, fn d -> {d[:dia], d[:km]} end)

    Map.merge(kilometros_aliada, km_jugutier, fn _dia, aliada, jugutier ->
      aliada + jugutier
    end)
  end

  # Ordena las liquidaciones por neto según las opciones y devuelve solo las primeras `limite`.
  #   liquidaciones — lista de liquidaciones por repartidor.
  #   opciones — keyword list con :orden (:asc o :desc, por defecto :desc) y :limite (por defecto todas).
  # Ojo: el primer argumento se llama `reporte_r2` en tu código, pero recibe liquidaciones. Renómbralo.
  def ranking(reporte_r2, opciones) do
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(reporte_r2))
    orden = if orden == :asc, do: :asc, else: :desc

    reporte_r2
    |> Enum.sort_by(fn repartidor -> repartidor[:neto] end, orden)
    |> limitar(limite)
  end

  # Ejecuta la función `fun` varias veces y devuelve el tiempo promedio en microsegundos.
  #   fun — función de aridad cero que se quiere medir.
  #   repeticiones — número de veces que se ejecuta (por defecto 1000).
  defp medir_promedio(fun, repeticiones \\ 1000) do
    tiempos =
      for _ <- 1..repeticiones do
        {t, _} = :timer.tc(fun)
        t
      end

    Enum.sum(tiempos) / repeticiones
  end

  # Mide el tiempo promedio de ejecución de los reportes R2 a R8.
  #   validos — lista de servicios válidos.
  #   liquidaciones — lista de liquidaciones por repartidor.
  #   zonas — lista de zonas.
  #   repartidores — lista completa de repartidores.
  # Devuelve un mapa %{r2: µs, r3: µs, ..., r8: µs} con los tiempos promedio.
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

  # Devuelve los primeros `limite` elementos de la lista.
  # Se usa desde ranking/2 para aplicar el límite configurado en las opciones.
  defp limitar(reporte, limite) when is_integer(limite) and limite >= 0 do
    Enum.take(reporte, limite)
  end

  # Caso alternativo de limitar/2: si el límite no es un entero válido,
  # devuelve la lista completa sin recortar.
  defp limitar(reporte, _limite), do: reporte

  # Función auxiliar de ejemplo: obtiene las categorías únicas de una lista de ventas.
  # No pertenece al parcial; se recomienda eliminarla del módulo.
  def obtener_categorias_unicas(ventas) do
    ventas
    |> Enum.map(& &1.categoria)
    |> Enum.uniq()
  end

  # Función auxiliar de ejemplo: agrupa productos por categoría.
  # No pertenece al parcial; se recomienda eliminarla del módulo.
  def agrupar_productos_por_categoria(ventas) do
    Enum.group_by(ventas, & &1.categoria, & &1.producto)
  end

  # Función auxiliar de ejemplo: cuenta cuántas ventas hay por categoría.
  # No pertenece al parcial; se recomienda eliminarla del módulo.
  def contar_ventas_por_categoria(ventas) do
    Enum.frequencies_by(ventas, & &1.categoria)
  end

  # Función auxiliar de ejemplo: suma las unidades vendidas por categoría.
  # No pertenece al parcial; se recomienda eliminarla del módulo.
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
end
