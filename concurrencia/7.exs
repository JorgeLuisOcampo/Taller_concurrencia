defmodule Carrito do
  defstruct id: "", items: [], cupon: ""
  def crear(id, items, cupon), do: %Carrito{id: id, items: items, cupon: cupon}
end

defmodule Calculadora do
  def total_con_descuentos(c) do
    :timer.sleep(Enum.random(5..15))
    precio_por_cat =
      c.items
      |> Enum.map(fn {cat, {_p,v}} ->
        evaluar_cat(cat) * v
      end)
      |> Enum.sum()

    total_con_cupon =
      precio_por_cat
      |> aplicar_cupon(c.cupon)

    {c.id, total_con_cupon}

  end

  def evaluar_cat(cat) do
    case cat do
      :ropa -> 0.9
      :calzado -> 0.95
      :accesorio -> 0.85
      :tecnologia -> 0.8
      :higiene -> 0.75
      :deporte -> 0.6
      :hogar -> 0.9
      :electrodomestico -> 0.85
      :entretenimiento -> 0.6
      _ -> 1
    end
  end

  def aplicar_cupon(suma, cupon) do
    case cupon do
      "10off" -> suma * 0.9
      "20off" -> suma * 0.8
      "2X1" -> suma * 0.5
      "" -> suma
      _ -> suma
    end
  end

end

defmodule Main do
  def main do
    c1 = Carrito.crear("a101", [
      {:ropa, {"camisa", 25_000}},
      {:calzado, {"zapatos", 180_000}},
      {:accesorio, {"correa", 45_000}},
      {:tecnologia, {"mouse", 70_000}}
    ], "10off")

    c2 = Carrito.crear("b202", [
      {:ropa, {"vestido", 160_000}},
      {:calzado, {"tacones", 210_000}},
      {:accesorio, {"aretes", 30_000}},
      {:higiene, {"perfume", 250_000}}
    ], "20off")

    c3 = Carrito.crear("c303", [
      {:deporte, {"balón", 85_000}},
      {:ropa, {"camiseta deportiva", 60_000}},
      {:tecnologia, {"reloj inteligente", 400_000}},
      {:accesorio, {"gorra", 25_000}}
    ], "10off")

    c4 = Carrito.crear("d404", [
      {:accesorio, {"reloj de pared", 90_000}},
      {:ropa, {"delantal", 30_000}}
    ], "")

    c5 = Carrito.crear("e505", [
      {:ropa, {"blusa", 45_000}},
      {:calzado, {"botas", 190_000}},
      {:accesorio, {"collar", 80_000}},
      {:tecnologia, {"audífonos", 150_000}}
    ], "20off")

    c6 = Carrito.crear("f606", [
      {:ropa, {"camiseta niño", 35_000}},
      {:higiene, {"crema", 25_000}},
      {:hogar, {"almohada", 40_000}}
    ], "")

    c7 = Carrito.crear("g707", [
      {:tecnologia, {"celular", 1_200_000}},
      {:accesorio, {"funda", 30_000}},
      {:electrodomestico, {"plancha", 110_000}},
      {:ropa, {"chaqueta", 90_000}}
    ], "2X1")

    c8 = Carrito.crear("h808", [
      {:entretenimiento, {"videojuego", 250_000}},
      {:accesorio, {"audífonos gamer", 200_000}},
      {:ropa, {"camiseta gamer", 55_000}},
      {:hogar, {"silla gamer", 850_000}}
    ], "20off")

    c9 = Carrito.crear("i909", [
      {:deporte, {"raqueta", 280_000}},
      {:ropa, {"pantaloneta", 80_000}},
      {:calzado, {"tenis deportivos", 320_000}},
      {:accesorio, {"toalla", 20_000}}
    ], "")

    c10 = Carrito.crear("j010", [
      {:higiene, {"shampoo", 25_000}},
      {:hogar, {"toalla", 40_000}},
      {:accesorio, {"reloj", 150_000}},
      {:electrodomestico, {"secador de cabello", 230_000}}
    ], "2X1")

    carritos = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [carritos]})
    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [carritos]})
    IO.puts("\nSecuencial: #{t_sec}")
    IO.puts("Concurrente: #{t_con}")
    sp_up = Benchmark.calcular_speedup(t_con, t_sec) |> Float.round(2)
    IO.puts("Speed up es #{sp_up}x mas rapido.")

  end

  def secuencial(lista) do
    lista
    |>Enum.each(fn c->
      Calculadora.total_con_descuentos(c)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn c->
      Task.async(fn ->
        Calculadora.total_con_descuentos(c)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

end

Main.main()
