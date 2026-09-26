defmodule Datos do
  def repartidores do
    [
      %{codigo: "M01", nombre: "Ana Torres",     bicicleta: true},
      %{codigo: "M02", nombre: "David López",    bicicleta: false},
      %{codigo: "M03", nombre: "Sara Ramírez",   bicicleta: true},
      %{codigo: "M04", nombre: "Camilo Rojas",   bicicleta: false},
      %{codigo: "M05", nombre: "Laura Méndez",   bicicleta: true},
      %{codigo: "M06", nombre: "Andrés Pineda",  bicicleta: false},
      %{codigo: "M07", nombre: "Valentina Cruz", bicicleta: true},
      %{codigo: "M08", nombre: "Julián Ospina",  bicicleta: false},
      %{codigo: "M09", nombre: "Mariana Gil",    bicicleta: false},
      %{codigo: "M10", nombre: "Felipe Arango",  bicicleta: false}
    ]
  end

  def zonas do
    [
      %{id: "Z1", nombre: "Centro",    area: 6.5},
      %{id: "Z2", nombre: "Norte",     area: 10.2},
      %{id: "Z3", nombre: "Sur",       area: 8.0},
      %{id: "Z4", nombre: "Occidente", area: 12.5}
    ]
  end

  def servicios do
    [
      # ---------------- DÍA 1 ----------------
      %{repartidor: "M01", zona: "Z1", dia: 1, kilometros: 18,    retraso: 3},
      %{repartidor: "M01", zona: "Z2", dia: 1, kilometros: 25,    retraso: 14},
      %{repartidor: "M01", zona: "Z3", dia: 1, kilometros: 40,    retraso: -5},
      %{repartidor: "M02", zona: "Z1", dia: 1, kilometros: 22,    retraso: 8},
      %{repartidor: "M02", zona: "Z4", dia: 1, kilometros: 45,    retraso: 0},
      %{repartidor: "M03", zona: "Z2", dia: 1, kilometros: 30,    retraso: 25},
      %{repartidor: "M03", zona: "Z3", dia: 1, kilometros: 12.5,  retraso: -3},
      %{repartidor: "M04", zona: "Z1", dia: 1, kilometros: 20,    retraso: 40},
      %{repartidor: "M04", zona: "Z2", dia: 1, kilometros: 15,    retraso: 2},
      %{repartidor: "M05", zona: "Z3", dia: 1, kilometros: 35,    retraso: -10},
      %{repartidor: "M05", zona: "Z4", dia: 1, kilometros: 28,    retraso: 12},
      %{repartidor: "M06", zona: "Z1", dia: 1, kilometros: 10,    retraso: 5},
      %{repartidor: "M06", zona: "Z4", dia: 1, kilometros: 38,    retraso: 60},
      %{repartidor: "M07", zona: "Z2", dia: 1, kilometros: 42,    retraso: -2},
      %{repartidor: "M08", zona: "Z1", dia: 1, kilometros: 42,    retraso: -3},
      %{repartidor: "M09", zona: "Z2", dia: 1, kilometros: 40,    retraso: 6},
      %{repartidor: "M10", zona: "Z3", dia: 1, kilometros: 38,    retraso: 2},
      %{repartidor: "M02", zona: "Z4", dia: 1, kilometros: 44,    retraso: -1},
      %{repartidor: "M06", zona: "Z2", dia: 1, kilometros: 36,    retraso: 8},

      # ---------------- DÍA 2 ----------------
      %{repartidor: "M01", zona: "Z1", dia: 2, kilometros: 20,    retraso: 1},
      %{repartidor: "M01", zona: "Z4", dia: 2, kilometros: 30,    retraso: 18},
      %{repartidor: "M02", zona: "Z2", dia: 2, kilometros: 25,    retraso: -4},
      %{repartidor: "M02", zona: "Z3", dia: 2, kilometros: 35,    retraso: 9},
      %{repartidor: "M03", zona: "Z1", dia: 2, kilometros: 15,    retraso: 22},
      %{repartidor: "M04", zona: "Z3", dia: 2, kilometros: 28,    retraso: -1},
      %{repartidor: "M05", zona: "Z2", dia: 2, kilometros: 40,    retraso: 6},
      %{repartidor: "M06", zona: "Z3", dia: 2, kilometros: 18,    retraso: 30},
      %{repartidor: "M07", zona: "Z4", dia: 2, kilometros: 44,    retraso: -8},
      %{repartidor: "M08", zona: "Z1", dia: 2, kilometros: 12,    retraso: 2},
      %{repartidor: "M08", zona: "Z2", dia: 2, kilometros: 33,    retraso: 15},
      %{repartidor: "M09", zona: "Z3", dia: 2, kilometros: 27,    retraso: 4},
      %{repartidor: "M10", zona: "Z4", dia: 2, kilometros: 21,    retraso: -6},

      # ---------------- DÍA 3 ----------------
      %{repartidor: "M01", zona: "Z1", dia: 3, kilometros: 19,    retraso: 0},
      %{repartidor: "M02", zona: "Z1", dia: 3, kilometros: 24,    retraso: 11},
      %{repartidor: "M03", zona: "Z2", dia: 3, kilometros: 31,    retraso: -7},
      %{repartidor: "M03", zona: "Z4", dia: 3, kilometros: 29,    retraso: 20},
      %{repartidor: "M04", zona: "Z1", dia: 3, kilometros: 16,    retraso: 3},
      %{repartidor: "M05", zona: "Z1", dia: 3, kilometros: 22,    retraso: -2},
      %{repartidor: "M05", zona: "Z2", dia: 3, kilometros: 38,    retraso: 13},
      %{repartidor: "M06", zona: "Z2", dia: 3, kilometros: 45,    retraso: 45},
      %{repartidor: "M07", zona: "Z1", dia: 3, kilometros: 14,    retraso: 2},
      %{repartidor: "M07", zona: "Z3", dia: 3, kilometros: 26,    retraso: -9},
      %{repartidor: "M08", zona: "Z3", dia: 3, kilometros: 36,    retraso: 7},
      %{repartidor: "M09", zona: "Z2", dia: 3, kilometros: 23,    retraso: 0},
      %{repartidor: "M10", zona: "Z3", dia: 3, kilometros: 41,    retraso: 16},
      %{repartidor: "M10", zona: "Z1", dia: 3, kilometros: 17,    retraso: -3},
      %{repartidor: "M05", zona: "Z3", dia: 3, kilometros: 45,    retraso: -2},
      %{repartidor: "M02", zona: "Z1", dia: 3, kilometros: 40,    retraso: 3},
      %{repartidor: "M04", zona: "Z3", dia: 3, kilometros: 42,    retraso: -5},
      %{repartidor: "M09", zona: "Z4", dia: 3, kilometros: 38,    retraso: 6},
      %{repartidor: "M01", zona: "Z1", dia: 3, kilometros: 35,    retraso: 0},
      %{repartidor: "M08", zona: "Z2", dia: 3, kilometros: 37,    retraso: 4},

      # ---------------- DÍA 4 ----------------
      %{repartidor: "M01", zona: "Z2", dia: 4, kilometros: 27,    retraso: 5},
      %{repartidor: "M01", zona: "Z3", dia: 4, kilometros: 33,    retraso: -4},
      %{repartidor: "M02", zona: "Z4", dia: 4, kilometros: 44,    retraso: 21},
      %{repartidor: "M03", zona: "Z1", dia: 4, kilometros: 13,    retraso: 0},
      %{repartidor: "M04", zona: "Z2", dia: 4, kilometros: 26,    retraso: -5},
      %{repartidor: "M05", zona: "Z3", dia: 4, kilometros: 39,    retraso: 8},
      %{repartidor: "M06", zona: "Z1", dia: 4, kilometros: 11,    retraso: 2},
      %{repartidor: "M06", zona: "Z3", dia: 4, kilometros: 30,    retraso: 35},
      %{repartidor: "M07", zona: "Z1", dia: 4, kilometros: 20,    retraso: -1},
      %{repartidor: "M08", zona: "Z4", dia: 4, kilometros: 43,    retraso: 10},
      %{repartidor: "M09", zona: "Z1", dia: 4, kilometros: 18,    retraso: 4},
      %{repartidor: "M09", zona: "Z4", dia: 4, kilometros: 24,    retraso: -6},
      %{repartidor: "M10", zona: "Z2", dia: 4, kilometros: 32,    retraso: 19},
      %{repartidor: "M01", zona: "Z2", dia: 4, kilometros: 25,    retraso: 4},

      # ---------------- DÍA 5 ----------------
      %{repartidor: "M01", zona: "Z4", dia: 5, kilometros: 29,    retraso: 3},
      %{repartidor: "M02", zona: "Z1", dia: 5, kilometros: 21,    retraso: -2},
      %{repartidor: "M02", zona: "Z2", dia: 5, kilometros: 34,    retraso: 12},
      %{repartidor: "M03", zona: "Z3", dia: 5, kilometros: 25,    retraso: 0},
      %{repartidor: "M04", zona: "Z4", dia: 5, kilometros: 42,    retraso: 28},
      %{repartidor: "M05", zona: "Z1", dia: 5, kilometros: 16,    retraso: -7},
      %{repartidor: "M05", zona: "Z4", dia: 5, kilometros: 37,    retraso: 6},
      %{repartidor: "M06", zona: "Z2", dia: 5, kilometros: 23,    retraso: 2},
      %{repartidor: "M07", zona: "Z2", dia: 5, kilometros: 40,    retraso: 9},
      %{repartidor: "M08", zona: "Z1", dia: 5, kilometros: 15,    retraso: -3},
      %{repartidor: "M09", zona: "Z2", dia: 5, kilometros: 28,    retraso: 17},
      %{repartidor: "M10", zona: "Z1", dia: 5, kilometros: 19,    retraso: 1},
      %{repartidor: "M10", zona: "Z2", dia: 5, kilometros: 31,    retraso: -8},
      %{repartidor: "M08", zona: "Z3", dia: 5, kilometros: 26,    retraso: 5},
      %{repartidor: "M03", zona: "Z1", dia: 5, kilometros: 41,    retraso: -2},
      %{repartidor: "M04", zona: "Z2", dia: 5, kilometros: 39,    retraso: 5},
      %{repartidor: "M09", zona: "Z3", dia: 5, kilometros: 43,    retraso: -4},
      %{repartidor: "M10", zona: "Z4", dia: 5, kilometros: 36,    retraso: 7},
      %{repartidor: "M06", zona: "Z1", dia: 5, kilometros: 34,    retraso: 2},
      %{repartidor: "M07", zona: "Z4", dia: 5, kilometros: 40,    retraso: -6},

      # ---------------- DÍA 6 ----------------
      %{repartidor: "M01", zona: "Z1", dia: 6, kilometros: 22,    retraso: 0},
      %{repartidor: "M02", zona: "Z3", dia: 6, kilometros: 30,    retraso: -4},
      %{repartidor: "M03", zona: "Z4", dia: 6, kilometros: 45,    retraso: 25},
      %{repartidor: "M04", zona: "Z1", dia: 6, kilometros: 17,    retraso: 7},
      %{repartidor: "M05", zona: "Z2", dia: 6, kilometros: 33,    retraso: -1},
      %{repartidor: "M06", zona: "Z4", dia: 6, kilometros: 28,    retraso: 14},
      %{repartidor: "M07", zona: "Z2", dia: 6, kilometros: 39,    retraso: 3},
      %{repartidor: "M08", zona: "Z2", dia: 6, kilometros: 24,    retraso: -5},
      %{repartidor: "M09", zona: "Z1", dia: 6, kilometros: 20,    retraso: 0},
      %{repartidor: "M10", zona: "Z3", dia: 6, kilometros: 35,    retraso: 11},

      # ---------------- SERVICIOS INVÁLIDOS ----------------
      # Motivo: repartidor_desconocido (2)
      %{repartidor: "M99", zona: "Z1", dia: 1, kilometros: 20, retraso: 5},
      %{repartidor: "M99", zona: "Z2", dia: 3, kilometros: 30, retraso: 2},

      # Motivo: zona_desconocida (2)
      %{repartidor: "M01", zona: "Z9", dia: 2, kilometros: 20, retraso: 5},
      %{repartidor: "M02", zona: "Z9", dia: 4, kilometros: 30, retraso: 2},

      # Motivo: dia_invalido (2)
      %{repartidor: "M01", zona: "Z1", dia: 0,  kilometros: 20, retraso: 5},
      %{repartidor: "M02", zona: "Z2", dia: 7,  kilometros: 30, retraso: 2},

      # Motivo: kilometros_fuera_de_rango (2)
      %{repartidor: "M03", zona: "Z1", dia: 1, kilometros: 0,   retraso: 5},
      %{repartidor: "M04", zona: "Z2", dia: 2, kilometros: 50,  retraso: 2},

      # Motivo: retraso_invalido (2)
      %{repartidor: "M05", zona: "Z1", dia: 1, kilometros: 20, retraso: -40},
      %{repartidor: "M06", zona: "Z2", dia: 2, kilometros: 30, retraso: 200}
    ]
  end
end
