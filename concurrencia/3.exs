defmodule Orden do
  defstruct id: "", item: "", prep_ms: 0.0

  def crear(id, item, prep_ms) do
    %Orden{id: id, item: item, prep_ms: prep_ms}
  end

end

defmodule Main do
  def main do
    p1 = Orden.crear("ab12", "hamburguesa", 1500)
    p2 = Orden.crear("cd45", "perro", 2000)
    p3 = Orden.crear("wq78", "gaseosa", 4500)
    p4 = Orden.crear("we96", "jugo", 3500)
    p5 = Orden.crear("ko65", "ensalada", 1600)
    lista = [p1,p2,p3,p4,p5]
    IO.puts("Secuencial: #{Benchmark.determinar_tiempo_ejecucion({Main, :ticket_secuencial, [lista]})} microsegundos")
    IO.puts("Concurrente: #{Benchmark.determinar_tiempo_ejecucion({Main, :ticket_concurrencia, [lista]})} microsegundos")

  end

  def ticket_secuencial(lista) do
    Enum.each(lista, fn o ->
      :timer.sleep(o.prep_ms)
      IO.puts("Preparado: id #{o.id}, #{o.item}")
    end)
  end


  def ticket_concurrencia(lista) do
    lista
    |> Enum.map(fn o ->
      Task.async(fn -> :timer.sleep(o.prep_ms)
      IO.puts("Preparado: id #{o.id}, #{o.item}")
    end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))

  end

end

Main.main()
