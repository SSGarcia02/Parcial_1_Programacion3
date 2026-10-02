# SOLORZANO GARCIA SEBASTIÁN jssolorzanog@uqvirtual.edu.co
# CARDONA PETREL JUAN DAVID juand.cardonap@uqvirtual.edu.co
# MORALES LONDOÑO NIKOLL nikoll.moralesl@uqvirtual.edu.co
# Fecha: 1 de octubre del 2026

defmodule Validaciones do

  # Verifica que el código del repartidor exista en la lista de repartidores.
  # Devuelve :ok si existe o {:error, :repartidor_desconocido} si no.
  def validar_repartidor(codigo, repartidores) do
    codigos_validos = Enum.map(repartidores, fn r -> r[:codigo] end)

    if Enum.member?(codigos_validos, codigo) do
      :ok
    else
      {:error, :repartidor_desconocido}
    end
  end

  # Verifica que el id de la zona exista en la lista de zonas.
  # Devuelve :ok si existe o {:error, :zona_desconocida} si no.
  def validar_zona(zona, zonas) do
    zonas_validas = Enum.map(zonas, fn z -> z[:id] end)

    if Enum.member?(zonas_validas, zona) do
      :ok
    else
      {:error, :zona_desconocida}
    end
  end

  # Verifica que el día sea un entero entre 1 y 6.
  # Devuelve :ok si es válido o {:error, :dia_invalido} si no.
  def validar_dia(dia) do
    if is_integer(dia) and dia >= 1 and dia <= 6 do
      :ok
    else
      {:error, :dia_invalido}
    end
  end

  # Verifica que los kilómetros sean un número mayor que 0 y máximo 45.
  # Devuelve :ok si es válido o {:error, :kilometros_fuera_de_rango} si no.
  def validar_kilometros(kilometros) do
    if is_number(kilometros) and kilometros > 0 and kilometros <= 45 do
      :ok
    else
      {:error, :kilometros_fuera_de_rango}
    end
  end

  # Verifica que el retraso sea un número entre -30 y 180 minutos.
  # Devuelve :ok si es válido o {:error, :retraso_invalido} si no.
  def validar_retraso(retraso) do
    if is_number(retraso) and retraso >= -30 and retraso <= 180 do
      :ok
    else
      {:error, :retraso_invalido}
    end
  end

  # Encadena las cinco reglas de validación en orden con `with`.
  # Devuelve {:ok, servicio} si pasa todas, o el primer {:error, motivo} que falle.
  def validar_servicio(servicio, repartidores, zonas) do
    with :ok <- validar_repartidor(servicio[:repartidor], repartidores),
         :ok <- validar_zona(servicio[:zona], zonas),
         :ok <- validar_dia(servicio[:dia]),
         :ok <- validar_kilometros(servicio[:kilometros]),
         :ok <- validar_retraso(servicio[:retraso]) do
      {:ok, servicio}
    end
  end

  # Valida toda la lista de servicios y los separa en dos listas: válidos y rechazados.
  # Devuelve {validos, rechazados}, donde cada rechazado es una tupla {servicio, motivo}.
  def validar_servicios_validos_rechazados(servicios, repartidores, zonas) do
    lista_formateada =
      Enum.map(servicios, fn s -> {s, validar_servicio(s, repartidores, zonas)} end)

    # Separa la lista de {servicio, resultado} en dos:
    #los que empiezan con :ok y los que empiezan con :error.
    {ok, error} =
      Enum.split_with(lista_formateada, fn {_servicio, resultado} ->
        match?({:ok, _}, resultado)
      end)

    validos = Enum.map(ok, fn {servicio, _resultado} -> servicio end)
    rechazados = Enum.map(error, fn {servicio, {:error, motivo}} -> {servicio, motivo} end)

    {validos, rechazados}
  end
end
