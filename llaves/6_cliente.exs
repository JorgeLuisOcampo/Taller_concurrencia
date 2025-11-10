
defmodule ClienteEj6 do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej6

  def main() do
    Node.start(@nodo_cliente)
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      IO.puts("Cliente conectado al servidor")

      datos = crear_datos()

      IO.puts("\n----- Cálculo Secuencial -----")
      res_sec = secuencial(datos)
      IO.inspect(res_sec)

      IO.puts("\n----- Cálculo Concurrente -----")
      res_con = concurrente(datos)
      IO.inspect(res_con)

      if res_sec[:tiempo] != 0 and res_con[:tiempo] != 0 do
        speedup = Benchmark.calcular_speedup(res_con[:tiempo], res_sec[:tiempo]) |> Float.round(2)
        IO.puts("\nSpeed up es #{speedup}x mas rapido.")
      else
        IO.puts("\nNo se pudo calcular el speedup (tiempos inválidos).")
      end
    else
      IO.puts("No se pudo conectar con el servidor")
    end
  end

  defp secuencial(lista) do
    send({@servicio, @nodo_servidor}, {self(), {{:secuencial, :ok}, lista}})
    receive do
      {{:resultado, :ok}, datos, tiempo} -> %{resultado: datos, tiempo: tiempo}
    after
      100_000 -> %{resultado: [], tiempo: 0}
    end
  end

  defp concurrente(lista) do
    send({@servicio, @nodo_servidor}, {self(), {{:concurrente, :ok}, lista}})
    receive do
      {{:resultado, :ok}, datos, tiempo} -> %{resultado: datos, tiempo: tiempo}
    after
      100_000 -> %{resultado: [], tiempo: 0}
    end
  end

  # --- datos del ejercicio ---

  defmodule User do
    defstruct email: "", edad: 0, nombre: ""
    def crear(em,edad,name), do: %User{email: em, edad: edad, nombre: name}
  end

  defp crear_datos do
    u1 = User.crear("ana@example.com", 25, "Ana")
    u2 = User.crear("pedroexample.com", 30, "Pedro")
    u3 = User.crear("luz@example.com", -4, "Luz")
    u4 = User.crear("carlos@example.com", 40, "")
    u5 = User.crear("sofia@example.com", 22, "Sofia")
    [u1,u2,u3,u4,u5]
  end

end

ClienteEj6.main()
