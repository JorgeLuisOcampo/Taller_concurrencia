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

defmodule Main do
  def main do
    t1 = Tarea.crear(:reindex)
    t2 = Tarea.crear(:purge_cache)
    t3 = Tarea.crear(:build_sitemap)
    t4 = Tarea.crear(:backup)
    t5 = Tarea.crear(:analyze_logs)
    tareas = [t1, t2, t3, t4, t5]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [tareas]})
    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [tareas]})
    IO.puts("\nSecuencial: #{t_sec} microsegundos.")
    IO.puts("Concurrente: #{t_con} microsegundos.")
    sp_up = Benchmark.calcular_speedup(t_con, t_sec) |> Float.round(2)
    IO.puts("Speed up es #{sp_up}x mas rapido.")

  end

  def secuencial(lista) do
    lista
    |> Enum.each(fn t ->
      Mantenimiento.ejecutar(t)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn t->
      Task.async(fn ->
        Mantenimiento.ejecutar(t)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

end

Main.main()
