
defmodule ServidorEj7 do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej7

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)
    IO.puts("ServidorEj7 listo")
    loop()
  end

  defp loop do
    receive do
      {cliente, {{:secuencial, :ok}, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :secuencial, [lista]})
        resultado = secuencial(lista)
        send(cliente, {{:resultado, :ok}, resultado, tiempo})
        loop()
      {cliente, {{:concurrente, :ok}, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :concurrente, [lista]})
        resultado = concurrente(lista)
        send(cliente, {{:resultado, :ok}, resultado, tiempo})
        loop()
    end
  end

  # --- logica del ejercicio ---

  defp evaluar_cat(cat) do
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

  defp aplicar_cupon(suma, cupon) do
    case cupon do
      "10off" -> suma * 0.9
      "20off" -> suma * 0.8
      "2X1" -> suma * 0.5
      _ -> suma
    end
  end

  defp total_con_descuentos(c) do
    base =
      c.items
      |> Enum.map(fn {cat, {_p, v}} -> evaluar_cat(cat) * v end)
      |> Enum.sum()
    {c.id, aplicar_cupon(base, c.cupon)}
  end

  def secuencial(lista), do: Enum.map(lista, &total_con_descuentos/1)

  def concurrente(lista) do
    lista
    |> Enum.map(fn c -> Task.async(fn -> total_con_descuentos(c) end) end)
    |> Enum.map(&Task.await(&1, 10_000))
  end

end

ServidorEj7.main()
