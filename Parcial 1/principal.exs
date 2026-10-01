# Carga los módulos del proyecto desde el directorio actual del archivo.
# Se usa __DIR__ para que las rutas funcionen sin importar desde dónde se ejecute.
Enum.each(
  ["Datos.exs", "Validaciones.exs", "Liquidacion.exs", "Reportes.exs", "Util.ex"],
  &Code.require_file(&1, __DIR__)
)

defmodule Interfaz do
  # Punto de entrada del programa.
  # Carga datos, valida los servicios, captura un servicio adicional opcional,
  # genera los reportes R1 a R8 y muestra el comprobante de un repartidor.
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

  # Pide al usuario un servicio adicional opcional y lo agrega a la lista de válidos si pasa la validación.
  # Parámetros:
  #   servicios_validos — lista de servicios ya validados.
  #   repartidores — lista de repartidores (para mostrar códigos y validar el repartidor).
  #   zonas — lista de zonas (para mostrar ids y validar la zona).
  # Si el usuario presiona Enter, omite la entrada. Si el formato es inválido o falla alguna regla,
  # informa el motivo y devuelve la lista original sin cambios.
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

  # Parsea la entrada del usuario separada por punto y coma en cinco campos.
  # Parámetro: entrada — string con el formato "repartidor;zona;dia;kilometros;retraso".
  # Devuelve {:ok, mapa_servicio} o {:error, :formato_invalido} si no hay exactamente cinco campos.
  defp parsear_servicio(entrada) do
    campos = entrada |> String.split(";") |> Enum.map(&String.trim/1)

    case campos do
      [repartidor, zona, dia_texto, kilometros_texto, retraso_texto] ->
        construir_servicio(repartidor, zona, dia_texto, kilometros_texto, retraso_texto)

      _ ->
        {:error, :formato_invalido}
    end
  end

  # Construye el mapa del servicio a partir de los cinco campos en texto.
  # Convierte día a entero y kilómetros/retraso a número.
  # Devuelve {:ok, mapa} si todo convierte bien, o {:error, :formato_invalido} si algo falla.
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

  # Convierte un texto a entero.
  # Devuelve {:ok, entero} si el texto es un entero completo, o {:error, :formato_invalido} si no.
  defp parsear_entero(texto) do
    case Integer.parse(texto) do
      {entero, ""} -> {:ok, entero}
      _ -> {:error, :formato_invalido}
    end
  end

  # Convierte un texto a número (entero o decimal).
  # Intenta primero Integer.parse/1 y luego Float.parse/1.
  # Devuelve {:ok, numero} si el texto es un número completo, o {:error, :formato_invalido} si no.
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

  # Traduce cada átomo de motivo de rechazo a un mensaje legible para el usuario.
  # Se usa en Interfaz para informar por qué se rechazó un servicio adicional.
  defp motivo_rechazo(:repartidor_desconocido), do: "el código de repartidor no existe"
  defp motivo_rechazo(:zona_desconocida), do: "la zona no existe"
  defp motivo_rechazo(:dia_invalido), do: "el día debe ser un número entero entre 1 y 6"

  defp motivo_rechazo(:kilometros_fuera_de_rango),
    do: "los kilómetros deben ser mayores que 0 y no superar 45"

  defp motivo_rechazo(:retraso_invalido),
    do: "el retraso debe estar entre -30 y 180 minutos"

  # Calcula y muestra los reportes R1 a R8, la combinación con la empresa aliada,
  # el ranking top 5 por neto y las mediciones de tiempo de cada reporte.
  # Parámetros:
  #   servicios_validos — lista de servicios que pasaron la validación.
  #   rechazados — lista de tuplas {servicio, motivo} de los servicios rechazados.
  #   repartidores — lista completa de repartidores.
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

    # Calcula la combinación de km con la empresa aliada (a partir de la lista por_dia de R3),
    # el ranking top 5 por neto descendente y las mediciones de tiempo de R2 a R8.
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

  # Pide el código de un repartidor y muestra su comprobante de pago con el detalle diario y los totales.
  # Parámetros:
  #   servicios_validos — lista de servicios válidos.
  #   repartidores — lista completa de repartidores (para buscar el código y validar su existencia).
  # Si el código no existe, informa la situación y no muestra comprobante.
  defp generar_comprobante(servicios_validos, repartidores) do
    codigo = Util.ingresar("Ingrese el código del repartidor (ej. M01):", :texto)

    case Enum.find(repartidores, fn repartidor -> repartidor[:codigo] == codigo end) do
      nil ->
        Util.mostrar_mensaje("El repartidor no existe")

      # Calcula los resúmenes diarios solo del repartidor consultado.
      # Agrupa los servicios válidos por {repartidor, dia}, filtra los del código pedido
      # y construye un resumen diario por cada día trabajado.
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
