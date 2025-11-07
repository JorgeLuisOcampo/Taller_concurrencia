defmodule Orden do
  defstruct id: "", item: "", prep_ms: 0.0

  def crear(id, item, prep_ms) do
    %Orden{id: id, item: item, prep_ms: prep_ms}
  end

end

defmodule Main do
  def main do
    p1 = Orden.crear("ab12", 12, 15500)
    p2 = Orden.crear("cd45", 20, 20000)
    p3 = Orden.crear("wq78", 30, 45000)
    p4 = Orden.crear("we96", 5, 35000)
    p5 = Orden.crear("ko65", 18, 16000)
    lista = [p1,p2,p3,p4,p5]
    IO.inspect(calcular_iva_sencuencial(lista))
    IO.puts(Benchmark.determinar_tiempo_ejecucion({Main, :calcular_iva_sencuencial, [lista]}))
    IO.inspect(calcular_iva_concurrente(lista))
    IO.puts(Benchmark.determinar_tiempo_ejecucion({Main, :calcular_iva_concurrente, [lista]}))

  end

  def ticket_secuencial(lista) do
    Enum.each(lista, fn o -> timer.sleep(o.prep_ms) end)
  end


  def calcular_iva_concurrente(lista) do
    lista
    |> Enum.map(fn p ->
      Task.async(fn -> {p.nombre, p.precio_sin_iva * (1 + p.iva)} end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))

  end

end

Main.main()
