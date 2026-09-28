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
    entrada =
      Util.ingresar(
        "Ingrese un servicio adicional (repartidor:zona dia kilometros retraso) o Enter para omitir:",
        :texto
      )

    if entrada == "" do
      Util.mostrar_mensaje("Se omitió la entrada adicional.")
      servicios_validos
    else
      case parsear_servicio(entrada) do
        {:ok, servicio} ->
          case Validaciones.validar_servicio(servicio, repartidores, zonas) do
            {:ok, servicio_validado} ->
              Util.mostrar_mensaje("El servicio adicional fue agregado.")
              servicios_validos ++ [servicio_validado]

            {:error, motivo} ->
              Util.mostrar_mensaje("Servicio rechazado por #{inspect({:error, motivo})}.")
              servicios_validos
          end

        {:error, :formato_invalido} ->
          Util.mostrar_mensaje("Servicio rechazado por {:error, :formato_invalido}.")
          servicios_validos
      end
    end
  end

  defp parsear_servicio(entrada) do
    case String.split(entrada) do
      [repartidor_zona, dia_texto, kilometros_texto, retraso_texto] ->
        case String.split(repartidor_zona, ":") do
          [repartidor, zona] ->
            construir_servicio(repartidor, zona, dia_texto, kilometros_texto, retraso_texto)

          _ ->
            {:error, :formato_invalido}
        end

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

  defp generar_reportes(servicios_validos, rechazados, repartidores) do
    Util.mostrar_mensaje("\n=== Reportes Jugutier ===")

    IO.inspect(Reportes.reporte_r1(rechazados), label: "R1 - Servicios rechazados")

    IO.inspect(
      Reportes.total_kilometros(servicios_validos),
      label: "R2 - Total de kilómetros"
    )

    liquidaciones = Liquidacion.liquidacion(servicios_validos, repartidores)

    IO.inspect(
      Reportes.total_pagado(liquidaciones),
      label: "R3 - Total neto pagado"
    )

    IO.inspect(
      Reportes.kilometros_por_repartidor_dia(servicios_validos),
      label: "R4 - Kilómetros por repartidor y día"
    )

    IO.inspect(
      Reportes.zonas_por_repartidor(servicios_validos),
      label: "R5 - Zonas por repartidor"
    )

    IO.inspect(
      Reportes.retraso_ponderado(servicios_validos),
      label: "R6 - Retraso ponderado global"
    )

    Util.mostrar_mensaje("R7 - No disponible: Reportes no define este reporte.")
    Util.mostrar_mensaje("R8 - No disponible: Reportes no define este reporte.")
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

        liquidacion =
          Liquidacion.liquidacion_repartidor(codigo, resumenes, repartidor)

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
