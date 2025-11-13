defmodule User do
  defstruct email: "", edad: 0, nombre: ""
  def crear(em, edad, name), do: %User{email: em, edad: edad, nombre: name}
end

defmodule Cliente do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_validacion

  def main() do
    Node.start(@nodo_cliente)
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      IO.puts("Cliente conectado al servidor\n")

      usuarios = crear_usuarios()

      # ----- Secuencial -----
      IO.puts("----- Validación Secuencial -----")
      sec = secuencial(usuarios)
      IO.puts("Tiempo secuencial: #{sec.tiempo} μs")

      # ----- Concurrente -----
      IO.puts("\n----- Validación Concurrente -----")
      con = concurrente(usuarios)
      IO.puts("Tiempo concurrente: #{con.tiempo} μs")

      sp = Benchmark.calcular_speedup(con.tiempo, sec.tiempo) |> Float.round(2)
      IO.puts("\nSpeed Up: #{sp}x más rápido\n")

    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  defp crear_usuarios do
    [
      User.crear("ana@example.com", 25, "Ana"),
      User.crear("pedroexample.com", 30, "Pedro"),
      User.crear("luz@example.com", -4, "Luz"),
      User.crear("carlos@example.com", 40, ""),
      User.crear("sofia@example.com", 22, "Sofia")
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
