defmodule Carrito do
  defstruct id: "", items: [], cupon: ""
  def crear(id, items, cupon), do: %Carrito{id: id, items: items, cupon: cupon}
end

defmodule Calculadora do
  def total_con_descuentos(c) do
    :timer.sleep(Enum.random(5..15))

    precio_por_cat =
      c.items
      |> Enum.map(fn {cat, {_p, v}} ->
        evaluar_cat(cat) * v
      end)
      |> Enum.sum()

    total_final =
      precio_por_cat
      |> aplicar_cupon(c.cupon)

    IO.inspect({c.id, total_final})
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

defmodule Servidor do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_carrito

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)

    IO.puts("\nServidor de Carritos listo\n")
    loop()
  end

  defp loop do
    receive do
      {cliente, {:secuencial, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({Servidor, :secuencial, [lista]})
        send(cliente, {:resultado, tiempo})
        loop()

      {cliente, {:concurrente, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({Servidor, :concurrente, [lista]})
        send(cliente, {:resultado, tiempo})
        loop()
    end
  end

  # ----------- LÓGICA ------------

  def secuencial(lista) do
    Enum.each(lista, fn c -> Calculadora.total_con_descuentos(c) end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn c ->
      Task.async(fn -> Calculadora.total_con_descuentos(c) end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))
  end
end

Servidor.main()
