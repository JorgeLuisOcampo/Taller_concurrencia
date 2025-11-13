defmodule Review do
  defstruct id: "", texto: ""
  def crear(id, texto), do: %Review{id: id, texto: texto}
end

defmodule Cliente do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_review

  def main() do
    Node.start(@nodo_cliente)
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      IO.puts("Cliente conectado al servidor\n")

      reseñas = crear_resenas()

      IO.puts("----- Limpieza Secuencial -----")
      sec = secuencial(reseñas)
      IO.puts("Tiempo secuencial: #{sec.tiempo} μs")

      IO.puts("\n----- Limpieza Concurrente -----")
      conc = concurrente(reseñas)
      IO.puts("Tiempo concurrente: #{conc.tiempo} μs")

      sp = Benchmark.calcular_speedup(conc.tiempo, sec.tiempo) |> Float.round(2)
      IO.puts("\nSpeed Up: #{sp}x más rápido\n")

    else
      IO.puts("No se pudo conectar al servidor.")
    end
  end

  defp crear_resenas do
    [
      Review.crear("a1", "La película fue ÉPICA, me encantó cada escena"),
      Review.crear("b2", "No me gustó la actuación del protagonista."),
      Review.crear("c3", "Excelente historia, pero un poco larga en algunas partes."),
      Review.crear("d4", "La música y los efectos sonoros fueron geniales."),
      Review.crear("e5", "Una obra maestra del cine moderno, sin duda.")
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
