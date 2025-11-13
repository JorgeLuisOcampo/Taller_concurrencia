defmodule Tarea do
  defstruct nombre: ""
  def crear(n), do: %Tarea{nombre: n}
end

defmodule Cliente do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_tareas

  def main() do
    Node.start(@nodo_cliente)
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      IO.puts("Cliente conectado al servidor\n")

      tareas = crear_tareas()

      # ---- SEC ----
      IO.puts("----- Ejecución Secuencial -----")
      sec = secuencial(tareas)
      IO.puts("Tiempo secuencial: #{sec.tiempo} μs")

      # ---- CONC ----
      IO.puts("\n----- Ejecución Concurrente -----")
      conc = concurrente(tareas)
      IO.puts("Tiempo concurrente: #{conc.tiempo} μs")

      # ---- SPEEDUP ----
      sp = Benchmark.calcular_speedup(conc.tiempo, sec.tiempo) |> Float.round(2)
      IO.puts("\nSpeed Up: #{sp}x más rápido\n")

    else
      IO.puts("No se pudo conectar al servidor.")
    end
  end

  defp crear_tareas do
    [
      Tarea.crear(:reindex),
      Tarea.crear(:purge_cache),
      Tarea.crear(:build_sitemap),
      Tarea.crear(:backup),
      Tarea.crear(:analyze_logs)
    ]
  end

  defp secuencial(lista) do
    send({@servicio, @nodo_servidor}, {self(), {:secuencial, lista}})

    receive do
      {:resultado, tiempo} -> %{tiempo: tiempo}
    after
      100_000 -> %{tiempo: 0}
    end
  end

  defp concurrente(lista) do
    send({@servicio, @nodo_servidor}, {self(), {:concurrente, lista}})

    receive do
      {:resultado, tiempo} -> %{tiempo: tiempo}
    after
      100_000 -> %{tiempo: 0}
    end
  end
end

Cliente.main()
