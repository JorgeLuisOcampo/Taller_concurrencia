
defmodule ServidorEj3 do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej3

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)
    IO.puts("ServidorEj3 listo")
    loop()
  end

  defp loop do
    receive do
      {cliente, {{:secuencial, :ok}, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :secuencial, [lista]})
        resultado = secuencial(lista)
        send(cliente, {{:resultado, :ok}, resultado, tiempo})
        loop()
      {cliente, {{:concurrente, :ok}, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :concurrente, [lista]})
        resultado = concurrente(lista)
        send(cliente, {{:resultado, :ok}, resultado, tiempo})
        loop()
    end
  end

  # --- logica del ejercicio ---

  defmodule Orden do
    defstruct id: "", item: "", prep_ms: 0
    def crear(id, item, prep_ms), do: %Orden{id: id, item: item, prep_ms: prep_ms}
  end

  defp preparar(o) do
    :timer.sleep(o.prep_ms)
    {o.id, o.item}
  end

  def secuencial(lista) do
    Enum.map(lista, &preparar/1)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn o -> Task.async(fn -> preparar(o) end) end)
    |> Enum.map(&Task.await(&1, 10_000))
  end

end

ServidorEj3.main()
