defmodule Sucursal do
  defstruct id: "", ventas_diarias: []
  def crear(id, ventas_diarias), do: %Sucursal{id: id, ventas_diarias: ventas_diarias}
end

defmodule Reporte do
  def reporte(s) do
    :timer.sleep(Enum.random(50..120))

    total_ventas =
      s.ventas_diarias
      |> Enum.map(fn {_p, v} -> v end)
      |> Enum.sum()

    promedio = Float.round(total_ventas / length(s.ventas_diarias), 2)
    top_3 =
      s.ventas_diarias
      |> Enum.sort_by(fn {_p, v} -> v end, :desc)
      |> Enum.take(3)
      |> Enum.map(fn {p, v} -> "#{p}: #{v}," end)


    IO.puts("Reporte listo Sucursal #{s.id}: Total $#{total_ventas}, Promedio $#{promedio}, Top 3 #{top_3}")
  end
end

defmodule Main do
  def main do
    s1 = Sucursal.crear("A1", [
      {"pizza", 100_000},
      {"hamburguesa", 80_000},
      {"perro caliente", 70_000},
      {"papas fritas", 50_000},
      {"gaseosa", 40_000}
    ])

    s2 = Sucursal.crear("B2", [
      {"ensalada", 60_000},
      {"sandwich", 75_000},
      {"jugos naturales", 45_000},
      {"pollo asado", 90_000},
      {"arepa con queso", 30_000}
    ])

    s3 = Sucursal.crear("C3", [
      {"sushi", 110_000},
      {"ramen", 95_000},
      {"té verde", 35_000},
      {"tempura", 80_000},
      {"gyoza", 60_000}
    ])

    s4 = Sucursal.crear("D4", [
      {"bandeja paisa", 120_000},
      {"frijoles", 70_000},
      {"chicharrón", 90_000},
      {"arepa antioqueña", 40_000},
      {"limonada", 50_000}
    ])

    s5 = Sucursal.crear("E5", [
      {"taco", 85_000},
      {"burrito", 95_000},
      {"nachos", 60_000},
      {"guacamole", 35_000},
      {"agua fresca", 40_000}
    ])

    sucursales = [s1, s2, s3, s4, s5]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [sucursales]})
    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [sucursales]})

    IO.puts("\nSecuencial: #{t_sec} microsegundos")
    IO.puts("Concurrente: #{t_con} microsegundos")

    speedup = Benchmark.calcular_speedup(t_con, t_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x mas rapido")
  end


  def secuencial(lista) do
    lista
    |> Enum.each(fn s ->
      Reporte.reporte(s)
    end)

  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn s ->
      Task.async(fn ->
        Reporte.reporte(s)
      end)
    end)
    |> Enum.each(&Task.await(&1, 10000))
  end
end

Main.main()
