
defmodule ClienteEj3 do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej3

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

  defmodule Orden do
    defstruct id: "", item: "", prep_ms: 0
    def crear(id, item, prep_ms), do: %Orden{id: id, item: item, prep_ms: prep_ms}
  end

  defp crear_datos do
    o1 = Orden.crear("ab12", "hamburguesa", 1500)
    o2 = Orden.crear("cd45", "perro", 2000)
    o3 = Orden.crear("wq78", "gaseosa", 4500)
    o4 = Orden.crear("we96", "jugo", 3500)
    o5 = Orden.crear("ko65", "ensalada", 1600)
    [o1,o2,o3,o4,o5]
  end

end

ClienteEj3.main()
