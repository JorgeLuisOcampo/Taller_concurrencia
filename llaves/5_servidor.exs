
defmodule ServidorEj5 do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej5

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)
    IO.puts("ServidorEj5 listo")
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

  defp reporte(s) do
    total =
      s.ventas_diarias
      |> Enum.map(fn {_p,v} -> v end)
      |> Enum.sum()

    top3 =
      s.ventas_diarias
      |> Enum.sort_by(fn {_p,v} -> v end, :desc)
      |> Enum.take(3)

    {s.id, total, top3}
  end

  def secuencial(lista), do: Enum.map(lista, &reporte/1)

  def concurrente(lista) do
    lista
    |> Enum.map(fn s -> Task.async(fn -> reporte(s) end) end)
    |> Enum.map(&Task.await(&1, 10_000))
  end

end

ServidorEj5.main()
