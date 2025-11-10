defmodule ClienteIVA do
  @nodo_cliente :"cliente@192.168.1.19"
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_iva

  def main() do
    Node.start(@nodo_cliente)
    Node.set_cookie(:my_cookie)

    if Node.connect(@nodo_servidor) do
      IO.puts("Cliente conectado al servidor")

      productos = crear_productos()

      # cálculo secuencial
      IO.puts("\n----- Cálculo Secuencial -----")
      IO.inspect(solicitar_sencuencial(productos))

      # cálculo concurrente
      IO.puts("\n----- Cálculo Concurrente -----")
      IO.inspect(solicitar_concurrente(productos))

    else
      IO.puts("No se pudo conectar")
    end
  end

  defp crear_productos do
    [
      Producto.crear("camisa", 12, 15500, 0.19),
      Producto.crear("pantalon", 20, 20000, 0.19),
      Producto.crear("zapato", 30, 45000, 0.19),
      Producto.crear("camiseta", 5, 35000, 0.19),
      Producto.crear("medias", 18, 16000, 0.19)
    ]
  end

  # --------------------------
  # SOLICITUD SECUENCIAL
  # --------------------------
  defp solicitar_sencuencial(lista) do
    send({@servicio, @nodo_servidor}, {self(), {:calcular_sencuencial, lista}})

    receive do
      {:resultado, datos, tiempo} ->
        %{resultado: datos, tiempo: tiempo}
    after
      5000 -> {:error, :timeout}
    end
  end

  # --------------------------
  # SOLICITUD CONCURRENTE
  # --------------------------
  defp solicitar_concurrente(lista) do
    send({@servicio, @nodo_servidor}, {self(), {:calcular_concurrente, lista}})

    receive do
      {:resultado, datos, tiempo} ->
        %{resultado: datos, tiempo: tiempo}
    after
      5000 -> {:error, :timeout}
    end
  end
end

ClienteIVA.main()
