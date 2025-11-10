
defmodule ClienteEj5 do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej5

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

  defmodule Sucursal do
    defstruct id: "", ventas_diarias: []
    def crear(id, ventas_diarias), do: %Sucursal{id: id, ventas_diarias: ventas_diarias}
  end

  defp crear_datos do
    s1 = Sucursal.crear("A1", [{"pizza", 100_000},{"hamburguesa", 80_000},{"perro caliente", 70_000},{"papas fritas", 50_000},{"gaseosa", 40_000}])
    s2 = Sucursal.crear("B2", [{"ensalada", 60_000},{"sandwich", 75_000},{"jugos naturales", 45_000},{"pollo asado", 90_000},{"arepa con queso", 30_000}])
    s3 = Sucursal.crear("C3", [{"sushi", 110_000},{"ramen", 95_000},{"té verde", 35_000},{"tempura", 80_000},{"gyoza", 60_000}])
    s4 = Sucursal.crear("D4", [{"bandeja paisa", 120_000},{"frijoles", 70_000},{"chicharrón", 90_000},{"arepa antioqueña", 40_000},{"limonada", 50_000}])
    s5 = Sucursal.crear("E5", [{"taco", 85_000},{"burrito", 95_000},{"nachos", 60_000},{"guacamole", 35_000},{"agua fresca", 40_000}])
    [s1,s2,s3,s4,s5]
  end

end

ClienteEj5.main()
