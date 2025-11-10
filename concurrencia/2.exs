defmodule Producto do
  defstruct nombre: "", stock: 0, precio_sin_iva: 0.0, iva: 0.0

  def crear(nombre, stock, precio_sin_iva, iva) do
    %Producto{nombre: nombre, stock: stock, precio_sin_iva: precio_sin_iva, iva: iva}
  end

end

defmodule Calculadora do
  def precio_final(p) do
    precio = (p.precio_sin_iva * p.iva) + p.precio_sin_iva
    precio
  end

end

defmodule Main do
  def main do
  p1  = Producto.crear("Camisa", 12, 15_500, 0.19)
  p2  = Producto.crear("Pantalón", 20, 20_000, 0.19)
  p3  = Producto.crear("Zapato", 30, 45_000, 0.19)
  p4  = Producto.crear("Camiseta", 5, 35_000, 0.19)
  p5  = Producto.crear("Medias", 18, 16_000, 0.19)
  p6  = Producto.crear("Chaqueta", 10, 90_000, 0.19)
  p7  = Producto.crear("Bufanda", 15, 25_000, 0.19)
  p8  = Producto.crear("Guantes", 25, 18_000, 0.19)
  p9  = Producto.crear("Gorra", 30, 22_000, 0.19)
  p10 = Producto.crear("Cinturón", 14, 28_000, 0.19)
  p11 = Producto.crear("Reloj", 8, 150_000, 0.19)
  p12 = Producto.crear("Lentes de sol", 10, 80_000, 0.19)
  p13 = Producto.crear("Bolso", 9, 120_000, 0.19)
  p14 = Producto.crear("Billetera", 20, 45_000, 0.19)
  p15 = Producto.crear("Computador portátil", 6, 2_500_000, 0.19)
  p16 = Producto.crear("Celular", 15, 1_200_000, 0.19)
  p17 = Producto.crear("Tablet", 10, 800_000, 0.19)
  p18 = Producto.crear("Audífonos", 25, 150_000, 0.19)
  p19 = Producto.crear("Mouse inalámbrico", 20, 90_000, 0.19)
  p20 = Producto.crear("Teclado mecánico", 15, 250_000, 0.19)
  p21 = Producto.crear("Monitor", 10, 1_000_000, 0.19)
  p22 = Producto.crear("Impresora", 8, 600_000, 0.19)
  p23 = Producto.crear("Lámpara LED", 25, 50_000, 0.19)
  p24 = Producto.crear("Silla ergonómica", 10, 700_000, 0.19)
  p25 = Producto.crear("Escritorio", 12, 500_000, 0.19)
  p26 = Producto.crear("Ventilador", 14, 180_000, 0.19)
  p27 = Producto.crear("Microondas", 9, 480_000, 0.19)
  p28 = Producto.crear("Licuadora", 13, 210_000, 0.19)
  p29 = Producto.crear("Refrigerador", 5, 3_000_000, 0.19)
  p30 = Producto.crear("Horno eléctrico", 7, 450_000, 0.19)
  p31 = Producto.crear("Tostadora", 20, 150_000, 0.19)
  p32 = Producto.crear("Cafetera", 15, 320_000, 0.19)
  p33 = Producto.crear("Plancha", 25, 110_000, 0.19)
  p34 = Producto.crear("Aspiradora", 10, 680_000, 0.19)
  p35 = Producto.crear("Televisor", 8, 2_000_000, 0.19)
  p36 = Producto.crear("Cámara fotográfica", 6, 1_800_000, 0.19)
  p37 = Producto.crear("Disco duro externo", 18, 320_000, 0.19)
  p38 = Producto.crear("Memoria USB", 40, 45_000, 0.19)
  p39 = Producto.crear("Router WiFi", 14, 230_000, 0.19)
  p40 = Producto.crear("Cargador portátil", 30, 85_000, 0.19)
  p41 = Producto.crear("Libro", 25, 60_000, 0.19)
  p42 = Producto.crear("Cuaderno", 60, 12_000, 0.19)
  p43 = Producto.crear("Bolígrafo", 100, 4_000, 0.19)
  p44 = Producto.crear("Mochila", 18, 95_000, 0.19)
  p45 = Producto.crear("Agenda", 22, 25_000, 0.19)
  p46 = Producto.crear("Regla", 40, 3_000, 0.19)
  p47 = Producto.crear("Calculadora", 15, 70_000, 0.19)
  p48 = Producto.crear("Perfume", 10, 220_000, 0.19)
  p49 = Producto.crear("Desodorante", 30, 15_000, 0.19)
  p50 = Producto.crear("Cepillo de dientes", 50, 8_000, 0.19)

  productos = [
    p1, p2, p3, p4, p5, p6, p7, p8, p9, p10,
    p11, p12, p13, p14, p15, p16, p17, p18, p19, p20,
    p21, p22, p23, p24, p25, p26, p27, p28, p29, p30,
    p31, p32, p33, p34, p35, p36, p37, p38, p39, p40,
    p41, p42, p43, p44, p45, p46, p47, p48, p49, p50
  ]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [productos]})
    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [productos]})
    IO.inspect(secuencial(productos))
    IO.inspect(concurrente(productos))

    sp_up = Benchmark.calcular_speedup(t_con, t_sec)
    IO.puts("Speed up es #{sp_up}x mas rapido.")

  end

  def secuencial(lista) do
    nueva_lista =
      lista
      |> Enum.map(fn p -> {p.nombre, Calculadora.precio_final(p)} end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn p ->
      Task.async(fn -> {p.nombre, Calculadora.precio_final(p)} end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))

  end

end

Main.main()
