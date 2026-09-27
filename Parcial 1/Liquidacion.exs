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
end
