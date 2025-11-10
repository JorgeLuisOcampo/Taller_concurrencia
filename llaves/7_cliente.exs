
defmodule ClienteEj7 do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej7

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

  defmodule Carrito do
    defstruct id: "", items: [], cupon: ""
    def crear(id, items, cupon), do: %Carrito{id: id, items: items, cupon: cupon}
  end

  defp crear_datos do
    c1 = Carrito.crear("a101", [{:ropa, {"camisa", 25_000}}, {:calzado, {"zapatos", 180_000}}, {:accesorio, {"correa", 45_000}}, {:tecnologia, {"mouse", 70_000}}], "10off")
    c2 = Carrito.crear("b202", [{:ropa, {"vestido", 160_000}}, {:calzado, {"tacones", 210_000}}, {:accesorio, {"aretes", 30_000}}, {:higiene, {"perfume", 250_000}}], "20off")
    c3 = Carrito.crear("c303", [{:deporte, {"balón", 85_000}}, {:ropa, {"camiseta deportiva", 60_000}}, {:tecnologia, {"reloj inteligente", 400_000}}, {:accesorio, {"gorra", 25_000}}], "10off")
    c4 = Carrito.crear("d404", [{:accesorio, {"reloj de pared", 90_000}}, {:ropa, {"delantal", 30_000}}], "")
    c5 = Carrito.crear("e505", [{:ropa, {"blusa", 45_000}}, {:calzado, {"botas", 190_000}}, {:accesorio, {"collar", 80_000}}, {:tecnologia, {"audífonos", 150_000}}], "20off")
    c6 = Carrito.crear("f606", [{:ropa, {"camiseta niño", 35_000}}, {:higiene, {"crema", 25_000}}, {:hogar, {"almohada", 40_000}}], "")
    c7 = Carrito.crear("g707", [{:tecnologia, {"celular", 1_200_000}}, {:accesorio, {"funda", 30_000}}, {:electrodomestico, {"plancha", 110_000}}, {:ropa, {"chaqueta", 90_000}}], "2X1")
    c8 = Carrito.crear("h808", [{:entretenimiento, {"videojuego", 250_000}}, {:accesorio, {"audífonos gamer", 200_000}}, {:ropa, {"camiseta gamer", 55_000}}, {:hogar, {"silla gamer", 850_000}}], "20off")
    c9 = Carrito.crear("i909", [{:deporte, {"raqueta", 280_000}}, {:ropa, {"pantaloneta", 80_000}}, {:calzado, {"tenis deportivos", 320_000}}, {:accesorio, {"toalla", 20_000}}], "")
    c10 = Carrito.crear("j010", [{:higiene, {"shampoo", 25_000}}, {:hogar, {"toalla", 40_000}}, {:accesorio, {"reloj", 150_000}}, {:electrodomestico, {"secador de cabello", 230_000}}], "2X1")
    [c1,c2,c3,c4,c5,c6,c7,c8,c9,c10]
  end

end

ClienteEj7.main()
