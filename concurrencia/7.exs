defmodule Carrito do
  defstruct id: "", items: [], cupon: nil

  def crear(id, items, cupon) do
    %Carrito{id: id, items: items, cupon: cupon}
  end
end

defmodule Descuentos do
  # Función que calcula el total final con descuentos aplicados
  def total_con_descuentos(carrito) do
    :timer.sleep(Enum.random(5..15))  # Simula el tiempo de cálculo

    subtotal = Enum.sum(carrito.items)
    total = aplicar_cupon(subtotal, carrito.cupon)

    # Salida como tupla
    IO.inspect({carrito.id, total})

    {carrito.id, total}
  end

  defp aplicar_cupon(subtotal, cupon) do
    case cupon do
      :ninguno -> subtotal
      :descuento10 -> Float.round(subtotal * 0.9, 2)       # 10% de descuento
      :descuento20 -> Float.round(subtotal * 0.8, 2)       # 20% de descuento
      :dosxuno -> aplicar_2x1(subtotal)
      _ -> subtotal
    end
  end

  # Simula una regla tipo “2x1”: se descuenta el precio de un producto promedio
  defp aplicar_2x1(subtotal) do
    descuento = subtotal * 0.5 / Enum.random(2..3)
    Float.round(subtotal - descuento, 2)
  end
end

defmodule Main do
  def main do
    # Carritos simulados
    c1 = Carrito.crear("A1", [10000, 15000, 12000], :descuento10)
    c2 = Carrito.crear("B2", [20000, 25000, 18000], :dosxuno)
    c3 = Carrito.crear("C3", [5000, 8000], :ninguno)
    c4 = Carrito.crear("D4", [30000, 25000], :descuento20)
    c5 = Carrito.crear("E5", [12000, 7000, 9000, 11000], :ninguno)

    lista = [c1, c2, c3, c4, c5]

    # Medición de tiempos
    tiempo_sec = Benchmark.determinar_tiempo_ejecucion({Main, :procesar_secuencial, [lista]})
    tiempo_conc = Benchmark.determinar_tiempo_ejecucion({Main, :procesar_concurrente, [lista]})

    IO.puts("\nSecuencial: #{tiempo_sec} microsegundos")
    IO.puts("Concurrente: #{tiempo_conc} microsegundos")

    speedup = Benchmark.calcular_speedup(tiempo_conc, tiempo_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x más rápido\n")
  end

  # Versión secuencial
  def procesar_secuencial(lista) do
    Enum.each(lista, fn c ->
      Descuentos.total_con_descuentos(c)
    end)
  end

  # Versión concurrente
  def procesar_concurrente(lista) do
    lista
    |> Enum.map(fn c ->
      Task.async(fn -> Descuentos.total_con_descuentos(c) end)
    end)
    |> Enum.each(&Task.await(&1, 100_000))
  end
end

Main.main()
