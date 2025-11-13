defmodule Sucursal do
  defstruct id: "", ventas_diarias: []
  def crear(id, ventas), do: %Sucursal{id: id, ventas_diarias: ventas}
end

defmodule Reporte do
  def reporte(s) do
    :timer.sleep(Enum.random(50..120))

    total =
      s.ventas_diarias
      |> Enum.map(fn {_p, v} -> v end)
      |> Enum.sum()

    promedio = Float.round(total / length(s.ventas_diarias), 2)

    top_3 =
      s.ventas_diarias
      |> Enum.sort_by(fn {_p, v} -> v end, :desc)
      |> Enum.take(3)
      |> Enum.map(fn {p, v} -> "#{p}: #{v}," end)

    IO.puts("Reporte listo Sucursal #{s.id}: Total $#{total}, Promedio $#{promedio}, Top 3 #{top_3}")
  end
end

defmodule Servidor do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_sucursal

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)

    IO.puts("\nServidor de Reportes listo\n")
    loop()
  end

  defp loop do
    receive do
      {cliente, {:secuencial, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({Servidor, :secuencial, [lista]})
        send(cliente, {:resultado, tiempo})
        loop()

      {cliente, {:concurrente, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({Servidor, :concurrente, [lista]})
        send(cliente, {:resultado, tiempo})
        loop()
    end
  end

  def secuencial(lista) do
    Enum.each(lista, fn s -> Reporte.reporte(s) end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn s ->
      Task.async(fn -> Reporte.reporte(s) end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))
  end
end

Servidor.main()
