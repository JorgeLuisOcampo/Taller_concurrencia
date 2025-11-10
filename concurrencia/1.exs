defmodule Car do
  defstruct id: "", piloto: "", pit_ms: 0, vuelta_ms: 0
  def crear(id, p, pit, vuelta), do: %Car{id: id, piloto: p, pit_ms: pit, vuelta_ms: vuelta}

end

defmodule Carrera do
  @vueltas 3
  def simular_carrera(car) do
    tiempo = (car.vuelta_ms + car.pit_ms) * @vueltas
    :timer.sleep(tiempo)
    IO.puts("#{car.piloto}, tiempo total: #{tiempo}")
  end

end

defmodule Main do
  def main do
    c1  = Car.crear("C1", "Lewis Hamilton", 200, 500)
    c2  = Car.crear("C2", "Max Verstappen", 200, 400)
    c3  = Car.crear("C3", "Charles Leclerc", 500, 700)
    c4  = Car.crear("C4", "Lando Norris", 300, 600)
    c5  = Car.crear("C5", "Fernando Alonso", 400, 550)
    c6  = Car.crear("C6", "Sergio Pérez", 100, 450)
    c7  = Car.crear("C7", "Carlos Sainz", 500, 600)
    c8  = Car.crear("C8", "George Russell", 250, 550)
    c9  = Car.crear("C9", "Oscar Piastri", 300, 650)
    c10 = Car.crear("C10", "Valtteri Bottas", 400, 750)

    cars = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [cars]})

    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [cars]})

    sp_up = Benchmark.calcular_speedup(t_con, t_sec) |> Float.round(2)

    IO.puts("Speed up es #{sp_up}x mas rapido.")
  end

  def secuencial(lista) do
    lista
    |> Enum.each(fn c ->
      Carrera.simular_carrera(c)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn c ->
      Task.async(fn ->
        Carrera.simular_carrera(c)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

end


Main.main()
