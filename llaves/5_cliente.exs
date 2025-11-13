defmodule Sucursal do
  defstruct id: "", ventas_diarias: []
  def crear(id, ventas), do: %Sucursal{id: id, ventas_diarias: ventas}
end

defmodule Cliente do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_sucursal

  def main() do
    Node.start(@nodo_cliente)
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      IO.puts("Cliente conectado al servidor\n")

      sucursales = crear_sucursales()

      IO.puts("----- Procesamiento Secuencial -----")
      sec = secuencial(sucursales)
      IO.puts("Tiempo secuencial: #{sec.tiempo} μs")

      IO.puts("\n----- Procesamiento Concurrente -----")
      conc = concurrente(sucursales)
      IO.puts("Tiempo concurrente: #{conc.tiempo} μs")

      sp = Benchmark.calcular_speedup(conc.tiempo, sec.tiempo) |> Float.round(2)
      IO.puts("\nSpeed Up: #{sp}x más rápido\n")

    else
      IO.puts("No se pudo conectar al servidor.")
    end
  end

  defp crear_sucursales do
    [
      Sucursal.crear("A1", [
        {"pizza", 100_000},
        {"hamburguesa", 80_000},
        {"perro caliente", 70_000},
        {"papas fritas", 50_000},
        {"gaseosa", 40_000}
      ]),
      Sucursal.crear("B2", [
        {"ensalada", 60_000},
        {"sandwich", 75_000},
        {"jugos naturales", 45_000},
        {"pollo asado", 90_000},
        {"arepa con queso", 30_000}
      ]),
      Sucursal.crear("C3", [
        {"sushi", 110_000},
        {"ramen", 95_000},
        {"té verde", 35_000},
        {"tempura", 80_000},
        {"gyoza", 60_000}
      ]),
      Sucursal.crear("D4", [
        {"bandeja paisa", 120_000},
        {"frijoles", 70_000},
        {"chicharrón", 90_000},
        {"arepa antioqueña", 40_000},
        {"limonada", 50_000}
      ]),
      Sucursal.crear("E5", [
        {"taco", 85_000},
        {"burrito", 95_000},
        {"nachos", 60_000},
        {"guacamole", 35_000},
        {"agua fresca", 40_000}
      ])
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
