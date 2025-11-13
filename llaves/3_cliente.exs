defmodule Orden do
  defstruct id: "", item: "", prep_ms: 0.0
  def crear(id, item, prep_ms), do: %Orden{id: id, item: item, prep_ms: prep_ms}
end

defmodule ClienteCocina do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_cocina

  def main() do
    Node.start(@nodo_cliente)
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      IO.puts("Cliente conectado al servidor")

      ordenes = crear_ordenes()

      IO.puts("\n----- Preparación Secuencial -----")
      sec = secuencial(ordenes)
      IO.puts("Tiempo secuencial: #{sec.tiempo} μs")

      IO.puts("\n----- Preparación Concurrente -----")
      con = concurrente(ordenes)
      IO.puts("Tiempo concurrente: #{con.tiempo} μs")

      sp_up = Benchmark.calcular_speedup(con.tiempo, sec.tiempo) |> Float.round(2)
      IO.puts("\nSpeed Up: #{sp_up}x más rápido")

    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  defp crear_ordenes do
    [
      Orden.crear("ab12", "hamburguesa", 1500),
      Orden.crear("cd45", "perro", 2000),
      Orden.crear("wq78", "gaseosa", 4500),
      Orden.crear("we96", "jugo", 3500),
      Orden.crear("ko65", "ensalada", 1600)
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

ClienteCocina.main()
