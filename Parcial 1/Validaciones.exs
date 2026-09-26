# 1 El repartidor existe :repartidor_desconocido
# 2 La zona existe :zona_desconocida
# 3 El día es un entero entre 1 y 6 :dia_invalido
# 4 Los kilómetros son un número mayor que 0 y máximo 45 :kilometros_fuera_de_rango
# 5 El retraso es numérico y se encuentra entre -30 y 180 minutos :retraso_invalido

defmodule Validaciones do
  def validar_repartidor(codigo, repartidores) do
    codigos_validos = Enum.map(repartidores, fn r -> r[:codigo] end)

    if Enum.member?(codigos_validos, codigo) do
      :ok
    else
      {:error, :repartidor_desconocido}
    end
  end

  def validar_zona(zona, zonas) do
    zonas_validas = Enum.map(zonas, fn z -> z[:id] end)

    if Enum.member?(zonas_validas, zona) do
      :ok
    else
      {:error, :zona_desconocida}
    end
  end

  def validar_dia(dia) do
    if is_integer(dia) and dia >= 1 and dia <= 6 do
      :ok
    else
      {:error, :dia_invalido}
    end
  end

  def validar_kilometros(kilometros) do
    if is_number(kilometros) and kilometros > 0 and kilometros <= 45 do
      :ok
    else
      {:error, :kilometros_fuera_de_rango}
    end
  end

  def validar_retraso(retraso) do
    if is_number(retraso) and retraso >= -30 and retraso <= 180 do
      :ok
    else
      {:error, :retraso_invalido}
    end
  end

  def validar_servicio(servicio, repartidores, zonas) do
    with :ok <- validar_repartidor(servicio[:repartidor], repartidores),
         :ok <- validar_zona(servicio[:zona], zonas),
         :ok <- validar_dia(servicio[:dia]),
         :ok <- validar_kilometros(servicio[:kilometros]),
         :ok <- validar_retraso(servicio[:retraso]) do
      {:ok, servicio}
    end
  end

  def validar_servicios_validos_rechazados(servicios, repartidores, zonas) do
    lista_formateada =
      Enum.map(servicios, fn s -> {s, validar_servicio(s, repartidores, zonas)} end)

    {ok, error} =
      Enum.split_with(lista_formateada, fn {_servicio, resultado} ->
        match?({:ok, _}, resultado)
      end)

    validos = Enum.map(ok, fn {servicio, _resultado} -> servicio end)
    rechazados = Enum.map(error, fn {servicio, {:error, motivo}} -> {servicio, motivo} end)

    {validos, rechazados}
  end
end
