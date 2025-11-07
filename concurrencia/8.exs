defmodule Tarea do
  defstruct nombre: ""

  def crear(nombre) do
    %Tarea{nombre: nombre}
  end
end

defmodule Backoffice do
  # Ejecuta una tarea según su tipo y simula el tiempo de ejecución
  def ejecutar(tarea) do
    tiempo = tiempo_por_tarea(tarea.nombre)
    :timer.sleep(tiempo)

    IO.puts("OK tarea #{tarea.nombre} (#{tiempo} ms)")
    {tarea.nombre, tiempo}
  end

  defp tiempo_por_tarea(nombre) do
    case nombre do
      :reindex -> 80
      :purge_cache -> 100
      :build_sitemap -> 60
      :backup -> 120
      :analyze_logs -> 90
      _ -> 70
    end
  end
end

defmodule Main do
  def main do
    # Lista de tareas de backoffice
    t1 = Tarea.crear(:reindex)
    t2 = Tarea.crear(:purge_cache)
    t3 = Tarea.crear(:build_sitemap)
    t4 = Tarea.crear(:backup)
    t5 = Tarea.crear(:analyze_logs)

    lista = [t1, t2, t3, t4, t5]

    # Medición de tiempos
    tiempo_sec = Benchmark.determinar_tiempo_ejecucion({Main, :tareas_secuenciales, [lista]})
    tiempo_conc = Benchmark.determinar_tiempo_ejecucion({Main, :tareas_concurrentes, [lista]})

    IO.puts("\nSecuencial: #{tiempo_sec} microsegundos")
    IO.puts("Concurrente: #{tiempo_conc} microsegundos")

    speedup = Benchmark.calcular_speedup(tiempo_conc, tiempo_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x más rápido\n")
  end

  # Versión secuencial
  def tareas_secuenciales(lista) do
    Enum.each(lista, fn t ->
      Backoffice.ejecutar(t)
    end)
  end

  # Versión concurrente
  def tareas_concurrentes(lista) do
    lista
    |> Enum.map(fn t ->
      Task.async(fn -> Backoffice.ejecutar(t) end)
    end)
    |> Enum.each(&Task.await(&1, 100_000))
  end
end

Main.main()
