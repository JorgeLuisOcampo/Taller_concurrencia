defmodule Carrito do
  defstruct id: "", items: [], cupon: ""
  def crear(id, items, cupon), do: %Carrito{id: id, items: items, cupon: cupon}
end

defmodule Cliente do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_carrito

  def main() do
    Node.start(@nodo_cliente)
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      IO.puts("Cliente conectado al servidor\n")

      carritos = crear_carritos()

      IO.puts("----- Cálculo Secuencial -----")
      sec = secuencial(carritos)
      IO.puts("Tiempo secuencial: #{sec.tiempo} μs")

      IO.puts("\n----- Cálculo Concurrente -----")
      con = concurrente(carritos)
      IO.puts("Tiempo concurrente: #{con.tiempo} μs")

      sp = Benchmark.calcular_speedup(con.tiempo, sec.tiempo) |> Float.round(2)
      IO.puts("\nSpeed Up: #{sp}x más rápido\n")

    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  # ----------------- Datos -----------------

  defp crear_carritos do
    [
      Carrito.crear("a101", [
        {:ropa, {"camisa", 25_000}},
        {:calzado, {"zapatos", 180_000}},
        {:accesorio, {"correa", 45_000}},
        {:tecnologia, {"mouse", 70_000}}
      ], "10off"),

      Carrito.crear("b202", [
        {:ropa, {"vestido", 160_000}},
        {:calzado, {"tacones", 210_000}},
        {:accesorio, {"aretes", 30_000}},
        {:higiene, {"perfume", 250_000}}
      ], "20off"),

      Carrito.crear("c303", [
        {:deporte, {"balón", 85_000}},
        {:ropa, {"camiseta deportiva", 60_000}},
        {:tecnologia, {"reloj inteligente", 400_000}},
        {:accesorio, {"gorra", 25_000}}
      ], "10off"),

      Carrito.crear("d404", [
        {:accesorio, {"reloj de pared", 90_000}},
        {:ropa, {"delantal", 30_000}}
      ], ""),

      Carrito.crear("e505", [
        {:ropa, {"blusa", 45_000}},
        {:calzado, {"botas", 190_000}},
        {:accesorio, {"collar", 80_000}},
        {:tecnologia, {"audífonos", 150_000}}
      ], "20off"),

      Carrito.crear("f606", [
        {:ropa, {"camiseta niño", 35_000}},
        {:higiene, {"crema", 25_000}},
        {:hogar, {"almohada", 40_000}}
      ], ""),

      Carrito.crear("g707", [
        {:tecnologia, {"celular", 1_200_000}},
        {:accesorio, {"funda", 30_000}},
        {:electrodomestico, {"plancha", 110_000}},
        {:ropa, {"chaqueta", 90_000}}
      ], "2X1"),

      Carrito.crear("h808", [
        {:entretenimiento, {"videojuego", 250_000}},
        {:accesorio, {"audífonos gamer", 200_000}},
        {:ropa, {"camiseta gamer", 55_000}},
        {:hogar, {"silla gamer", 850_000}}
      ], "20off"),

      Carrito.crear("i909", [
        {:deporte, {"raqueta", 280_000}},
        {:ropa, {"pantaloneta", 80_000}},
        {:calzado, {"tenis deportivos", 320_000}},
        {:accesorio, {"toalla", 20_000}}
      ], ""),

      Carrito.crear("j010", [
        {:higiene, {"shampoo", 25_000}},
        {:hogar, {"toalla", 40_000}},
        {:accesorio, {"reloj", 150_000}},
        {:electrodomestico, {"secador de cabello", 230_000}}
      ], "2X1")
    ]
  end

  # ----------------- Comunicación cliente-servidor -----------------

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
