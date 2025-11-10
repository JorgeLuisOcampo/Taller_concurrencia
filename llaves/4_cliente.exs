
defmodule ClienteEj4 do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej4

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

  defmodule Review do
    defstruct id: "", texto: ""
    def crear(id, texto), do: %Review{id: id, texto: texto}
  end

  defp crear_datos do
    r1 = Review.crear("a1", "La película fue ÉPICA, me encantó cada escena")
    r2 = Review.crear("b2", "No me gustó la actuación del protagonista.")
    r3 = Review.crear("c3", "Excelente historia, pero un poco larga en algunas partes.")
    r4 = Review.crear("d4", "La música y los efectos sonoros fueron geniales.")
    r5 = Review.crear("e5", "Una obra maestra del cine moderno, sin duda.")
    [r1, r2, r3, r4, r5]
  end

end

ClienteEj4.main()
