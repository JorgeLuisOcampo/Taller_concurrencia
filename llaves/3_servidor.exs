defmodule Orden do
  defstruct id: "", item: "", prep_ms: 0.0
  def crear(id, item, prep_ms), do: %Orden{id: id, item: item, prep_ms: prep_ms}
end

defmodule Cocina do
  def preparar(o) do
    :timer.sleep(o.prep_ms)
    IO.puts("Orden #{o.id}, prod: #{o.item} lista")
  end
end

defmodule ServidorCocina do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_cocina

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)

    IO.puts("Servidor Cocina listo")
    loop()
  end

  defp loop do
    receive do
      {cliente, {:secuencial, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({ServidorCocina, :secuencial, [lista]})
        send(cliente, {:resultado, tiempo})
        loop()

      {cliente, {:concurrente, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({ServidorCocina, :concurrente, [lista]})
        send(cliente, {:resultado, tiempo})
        loop()
    end
  end

  # ---------- LÓGICA DE PREPARACIÓN ----------

  def secuencial(lista) do
    lista
    |> Enum.each(fn o ->
      Cocina.preparar(o)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn o ->
      Task.async(fn -> Cocina.preparar(o) end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))
  end
end

ServidorCocina.main()
