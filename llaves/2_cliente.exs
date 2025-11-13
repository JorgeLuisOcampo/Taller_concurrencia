defmodule Producto do
  defstruct nombre: "", stock: 0, precio_sin_iva: 0, iva: 0.0
  def crear(n, s, p, i), do: %Producto{nombre: n, stock: s, precio_sin_iva: p, iva: i}
end

defmodule ClienteIVA do
  @nodo_cliente :"cliente@192.168.1.2"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_iva

  def main() do
    Node.start(@nodo_cliente)
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      IO.puts("Cliente conectado al servidor")

      productos = crear_productos()

      IO.puts("\n----- Cálculo Secuencial -----")
      resultado_sec = secuencial(productos)
      IO.inspect(resultado_sec)

      IO.puts("\n----- Cálculo Concurrente -----")
      resultado_con = concurrente(productos)
      IO.inspect(resultado_con)

    else
      IO.puts("No se pudo conectar con el servidor.")
    end
  end

  defp crear_productos do
    [
      Producto.crear("camisa", 12, 15_500, 0.19),
      Producto.crear("pantalon", 20, 20_000, 0.19),
      Producto.crear("zapato", 30, 45_000, 0.19),
      Producto.crear("camiseta", 5, 35_000, 0.19),
      Producto.crear("medias", 18, 16_000, 0.19)
    ]
  end

  defp secuencial(lista) do
    send({@servicio, @nodo_servidor}, {self(), {:secuencial, lista}})

    receive do
      {:resultado, datos, tiempo} ->
        %{resultado: datos, tiempo: tiempo}
    after
      100_000 -> %{resultado: [], tiempo: 0}
    end
  end

  defp concurrente(lista) do
    send({@servicio, @nodo_servidor}, {self(), {:concurrente, lista}})

    receive do
      {:resultado, datos, tiempo} ->
        %{resultado: datos, tiempo: tiempo}
    after
      100_000 -> %{resultado: [], tiempo: 0}
    end
  end
end

ClienteIVA.main()
