Enum.each(
  ["Datos.exs", "Validaciones.exs", "Liquidacion.exs", "Reportes.exs", "Util.ex"],
  &Code.require_file(&1, __DIR__)
)

defmodule Interfaz do
  def main do
    repartidores = Datos.repartidores()
    zonas = Datos.zonas()

    {servicios_validos, rechazados} =
      Validaciones.validar_servicios_validos_rechazados(
        Datos.servicios(),
        repartidores,
        zonas
      )

    servicios_validos =
      capturar_servicio_adicional(servicios_validos, repartidores, zonas)

    generar_reportes(servicios_validos, rechazados, repartidores)
    generar_comprobante(servicios_validos, repartidores)
  end

  defp capturar_servicio_adicional(servicios_validos, repartidores, zonas) do
    codigos_repartidores =
      repartidores
      |> Enum.map(fn repartidor -> repartidor[:codigo] end)
      |> Enum.join(", ")

    zonas_disponibles =
      zonas
      |> Enum.map(fn zona -> "#{zona[:id]} (#{zona[:nombre]})" end)
      |> Enum.join(", ")

    mensaje = """
    === Agregar un servicio adicional (opcional) ===
    Ingrese los datos en este orden, separados por punto y coma (;):
      Repartidor; zona; día; kilómetros; retraso en minutos
    Ejemplo: M01;Z1;2;18;5
    Repartidores disponibles: #{codigos_repartidores}
    Zonas disponibles: #{zonas_disponibles}
    Reglas: día 1-6, kilómetros mayores que 0 y hasta 45, retraso entre -30 y 180 minutos.
    Presione Enter sin escribir nada si no desea agregar un servicio.
    Servicio:
    """

    entrada = Util.ingresar(String.trim_trailing(mensaje) <> " ", :texto)

    if entrada == "" do
      Util.mostrar_mensaje("Se omitió la entrada adicional.")
      servicios_validos
    else
      case parsear_servicio(entrada) do
        {:ok, servicio} ->
          case Validaciones.validar_servicio(servicio, repartidores, zonas) do
            {:ok, servicio_validado} ->
              Util.mostrar_mensaje("Servicio agregado. Se incluirá en los reportes.")
              servicios_validos ++ [servicio_validado]

            {:error, motivo} ->
              Util.mostrar_mensaje("No se agregó el servicio: #{motivo_rechazo(motivo)}.")
              servicios_validos
          end

        {:error, :formato_invalido} ->
          Util.mostrar_mensaje(
            "No se agregó el servicio: formato incorrecto. Ingrese exactamente cinco campos " <>
              "separados por punto y coma (;), por ejemplo: M01;Z1;2;18;5."
          )

          servicios_validos
      end
    end
  end

  defp parsear_servicio(entrada) do
    campos = entrada |> String.split(";") |> Enum.map(&String.trim/1)

    case campos do
      [repartidor, zona, dia_texto, kilometros_texto, retraso_texto] ->
        construir_servicio(repartidor, zona, dia_texto, kilometros_texto, retraso_texto)

      _ ->
        {:error, :formato_invalido}
    end
  end

  defp construir_servicio(repartidor, zona, dia_texto, kilometros_texto, retraso_texto) do
    with {:ok, dia} <- parsear_entero(dia_texto),
         {:ok, kilometros} <- parsear_numero(kilometros_texto),
         {:ok, retraso} <- parsear_numero(retraso_texto) do
      {:ok,
       %{
         repartidor: repartidor,
         zona: zona,
         dia: dia,
         kilometros: kilometros,
         retraso: retraso
       }}
    else
      _ -> {:error, :formato_invalido}
    end
  end

  defp parsear_entero(texto) do
    case Integer.parse(texto) do
      {entero, ""} -> {:ok, entero}
      _ -> {:error, :formato_invalido}
    end
  end

  defp parsear_numero(texto) do
    case Integer.parse(texto) do
      {entero, ""} ->
        {:ok, entero}

      _ ->
        case Float.parse(texto) do
          {numero, ""} -> {:ok, numero}
          _ -> {:error, :formato_invalido}
        end
    end
  end

  defp motivo_rechazo(:repartidor_desconocido), do: "el código de repartidor no existe"
  defp motivo_rechazo(:zona_desconocida), do: "la zona no existe"
  defp motivo_rechazo(:dia_invalido), do: "el día debe ser un número entero entre 1 y 6"

  defp motivo_rechazo(:kilometros_fuera_de_rango),
    do: "los kilómetros deben ser mayores que 0 y no superar 45"

  defp motivo_rechazo(:retraso_invalido),
    do: "el retraso debe estar entre -30 y 180 minutos"

  defp generar_reportes(servicios_validos, rechazados, repartidores) do
    Util.mostrar_mensaje("\n=== Reportes Jugutier ===")

    liquidaciones = Liquidacion.liquidacion(servicios_validos, repartidores)
    zonas = Datos.zonas()

    r1 = Reportes.reporte_r1(rechazados)
    r2 = Reportes.reporte_r2(servicios_validos, zonas)
    r3 = Reportes.reporte_r3(servicios_validos)
    r4 = Reportes.reporte_r4(liquidaciones)
    r5 = Reportes.reporte_r5(servicios_validos, repartidores)
    r6 = Reportes.reporte_r6(servicios_validos)
    r7 = Reportes.reporte_r7(liquidaciones, servicios_validos)
    r8 = Reportes.reporte_r8(servicios_validos, zonas)

    combinacion = Reportes.combinar_kilometros_aliada(elem(r3, 0))
    ranking = Reportes.ranking(liquidaciones, orden: :desc, limite: 5)
    mediciones = Reportes.medir_reportes(servicios_validos, liquidaciones, zonas, repartidores)

    IO.inspect(r1, label: "R1 - Servicios rechazados y conteo por motivo")
    IO.inspect(r2, label: "R2 - Kilómetros por zona y densidad")
    IO.inspect(r3, label: "R3 - Kilómetros por día y meta")
    IO.inspect(r4, label: "R4 - Liquidación numerada por neto")
    IO.inspect(r5, label: "R5 - Repartidor con más km cada día")
    IO.inspect(r6, label: "R6 - Mejor puntualidad")
    IO.inspect(r7, label: "R7 - Total pagado y costo promedio")
    IO.inspect(r8, label: "R8 - Repartidores con cobertura total")
    IO.inspect(combinacion, label: "Combinación con empresa aliada")
    IO.inspect(ranking, label: "Ranking de repartidores (top 5 por neto)")
    IO.inspect(mediciones, label: "Mediciones de ejecución (µs)")
  end

  defp generar_comprobante(servicios_validos, repartidores) do
    codigo = Util.ingresar("Ingrese el código del repartidor (ej. M01):", :texto)

    case Enum.find(repartidores, fn repartidor -> repartidor[:codigo] == codigo end) do
      nil ->
        Util.mostrar_mensaje("El repartidor no existe")

      repartidor ->
        resumenes =
          servicios_validos
          |> Liquidacion.agrupar_por_dia()
          |> Enum.filter(fn {{codigo_dia, _dia}, _servicios} -> codigo_dia == codigo end)
          |> Enum.map(fn {clave, servicios_dia} ->
            Liquidacion.resumen_dia(clave, servicios_dia, repartidores)
          end)

        liquidacion = Liquidacion.liquidacion_repartidor(codigo, resumenes, repartidor)

        Util.mostrar_mensaje("\n=== Comprobante de repartidor ===")
        IO.inspect(%{nombre: repartidor[:nombre], codigo: codigo}, label: "Repartidor")
        IO.inspect(resumenes, label: "Detalle diario")

        IO.inspect(
          %{
            valor_servicios: liquidacion[:valor_servicios],
            bonificaciones: liquidacion[:bonificaciones],
            alquiler_bicicleta: liquidacion[:alquiler],
            neto_a_pagar: liquidacion[:neto]
          },
          label: "Totales"
        )
    end
  end
end

Interfaz.main()
