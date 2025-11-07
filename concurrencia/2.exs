defmodule Producto do
  defstruct nombre: "", stock: 0, precio_sin_iva: 0.0, iva: 0.0

  def crear(nombre, stock, precio_sin_iva, iva) do
    %Producto{nombre: nombre, stock: stock, precio_sin_iva: precio_sin_iva, iva: iva}
  end

end

defmodule Main do
  def main do
    p1 = Producto.crear("camisa", 12, 15500, 0.19)
    p2 = Producto.crear("pantalon", 20, 20000, 0.19)
    p3 = Producto.crear("zapato", 30, 45000, 0.19)
    p4 = Producto.crear("camiseta", 5, 35000, 0.19)
    p5 = Producto.crear("medias", 18, 16000, 0.19)
    lista = [p1,p2,p3,p4,p5]
    IO.inspect(calcular_iva_sencuencial(lista))
    IO.puts(Benchmark.determinar_tiempo_ejecucion({Main, :calcular_iva_sencuencial, [lista]}))
    IO.inspect(calcular_iva_concurrente(lista))
    IO.puts(Benchmark.determinar_tiempo_ejecucion({Main, :calcular_iva_concurrente, [lista]}))

  end

  def calcular_iva_sencuencial(lista) do
    Enum.map(lista, fn p -> {p.nombre, p.precio_sin_iva * (1 + p.iva)} end)
  end


  def calcular_iva_concurrente(lista) do
    lista
    |> Enum.map(fn p ->
      Task.async(fn -> {p.nombre, p.precio_sin_iva * (1 + p.iva)} end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))

  end

end

Main.main()
