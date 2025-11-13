defmodule Tarea do
  defstruct nombre: ""
  def crear(n), do: %Tarea{nombre: n}
end

defmodule Mantenimiento do
  def ejecutar(t) do
    case t.nombre do
      :reindex -> :timer.sleep(200)
      :purge_cache -> :timer.sleep(400)
      :build_sitemap -> :timer.sleep(600)
      :backup -> :timer.sleep(500)
      :analyze_logs -> :timer.sleep(600)
    end

    IO.puts("Ok tarea #{t.nombre}")
  end
end

defmodule Servidor do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_tareas

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)

    IO.puts("\nServidor de Tareas listo\n")
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

  # -------------------------
  # LÓGICA DE EJECUCIÓN
  # -------------------------

  def secuencial(lista) do
    Enum.each(lista, fn t -> Mantenimiento.ejecutar(t) end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn t ->
      Task.async(fn -> Mantenimiento.ejecutar(t) end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))
  end
end

Servidor.main()
