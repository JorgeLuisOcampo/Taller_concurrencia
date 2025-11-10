defmodule Orden do
  defstruct id: "", item: "", prep_ms: 0.0

  def crear(id, item, prep_ms) do
    %Orden{id: id, item: item, prep_ms: prep_ms}
  end

end

defmodule Cocina do
  def preparar(o) do
    :timer.sleep(o.prep_ms)
    IO.puts("Orden #{o.id}, prod: #{o.item} lista")
  end

end

defmodule Main do
  def main do
    o1 = Orden.crear("ab12", "hamburguesa", 1500)
    o2 = Orden.crear("cd45", "perro", 2000)
    o3 = Orden.crear("wq78", "gaseosa", 4500)
    o4 = Orden.crear("we96", "jugo", 3500)
    o5 = Orden.crear("ko65", "ensalada", 1600)
    ordenes = [o1,o2,o3,o4,o5]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [ordenes]})
    IO.puts("Secuencial: #{t_sec} microsegundos")
    t_con =Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [ordenes]})
    IO.puts("Concurrente: #{t_con} microsegundos")

    sp_up = Benchmark.calcular_speedup(t_con, t_sec) |> Float.round(2)
    IO.puts("Speed up es #{sp_up}x mas rapido")

  end

  def secuencial(lista) do
    lista
    |> Enum.each(fn o ->
      Cocina.preparar(o)
    end)

  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn o->
      Task.async(fn ->
        Cocina.preparar(o)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))

  end

end

Main.main()
