
defmodule ServidorEj8 do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej8

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)
    IO.puts("ServidorEj8 listo")
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

  defp ejecutar(t) do
    case t.nombre do
      :reindex -> :timer.sleep(200)
      :purge_cache -> :timer.sleep(400)
      :build_sitemap -> :timer.sleep(600)
      :backup -> :timer.sleep(500)
      :analyze_logs -> :timer.sleep(600)
    end
    {:ok, t.nombre}
  end

  def secuencial(lista), do: Enum.map(lista, &ejecutar/1)

  def concurrente(lista) do
    lista
    |> Enum.map(fn t -> Task.async(fn -> ejecutar(t) end) end)
    |> Enum.map(&Task.await(&1, 10_000))
  end

end

ServidorEj8.main()
