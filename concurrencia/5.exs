defmodule Sucursal do
  defstruct id: "", ventas_diarias: []

  def crear(id, ventas_diarias) do
    %Sucursal{id: id, ventas_diarias: ventas_diarias}
  end
end

defmodule Reporte do
  # Función que genera un resumen simple de ventas
  def generar(sucursal) do
    :timer.sleep(Enum.random(50..120))  # Simula el tiempo del procesamiento

    total_ventas = Enum.sum(sucursal.ventas_diarias)
    promedio = Float.round(total_ventas / length(sucursal.ventas_diarias), 2)
    top_3 = sucursal.ventas_diarias |> Enum.sort(:desc) |> Enum.take(3)

    IO.puts("Reporte listo Sucursal #{sucursal.id}: Total $#{total_ventas}, Promedio $#{promedio}, Top 3 #{inspect(top_3)}")
    {sucursal.id, total_ventas}
  end
end

defmodule Main do
  def main do
    # Creación de datos simulados
    s1 = Sucursal.crear("A1", [100000, 80000, 90000, 75000, 120000])
    s2 = Sucursal.crear("B2", [60000, 70000, 65000, 85000, 95000])
    s3 = Sucursal.crear("C3", [110000, 105000, 95000, 130000, 100000])
    s4 = Sucursal.crear("D4", [50000, 60000, 40000, 55000, 45000])
    s5 = Sucursal.crear("E5", [90000, 92000, 88000, 95000, 99000])

    lista = [s1, s2, s3, s4, s5]

    # Tiempos de ejecución
    tiempo_sec = Benchmark.determinar_tiempo_ejecucion({Main, :reportes_secuenciales, [lista]})
    tiempo_conc = Benchmark.determinar_tiempo_ejecucion({Main, :reportes_concurrentes, [lista]})

    IO.puts("\nSecuencial: #{tiempo_sec} microsegundos")
    IO.puts("Concurrente: #{tiempo_conc} microsegundos")

    speedup = Benchmark.calcular_speedup(tiempo_conc, tiempo_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x más rápido\n")
  end

  # Versión secuencial
  def reportes_secuenciales(lista) do
    Enum.each(lista, fn sucursal ->
      Reporte.generar(sucursal)
    end)
  end

  # Versión concurrente
  def reportes_concurrentes(lista) do
    lista
    |> Enum.map(fn sucursal ->
      Task.async(fn -> Reporte.generar(sucursal) end)
    end)
    |> Enum.each(&Task.await(&1, 100_000))
  end
end

Main.main()
