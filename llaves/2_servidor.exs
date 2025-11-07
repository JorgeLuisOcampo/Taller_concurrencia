defmodule ServidorIVA do
  @nodo_servidor :"servidor@IP_SERVIDOR"
  @servicio :servicio_iva

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)

    IO.puts("Servidor IVA listo")
    loop()
  end

  # Bucle principal del servidor
  defp loop do
    receive do
      {cliente, {:calcular_sencuencial, lista}} ->
        resultado = calcular_iva_sencuencial(lista)
        tiempo = Benchmark.determinar_tiempo_ejecucion({ServidorIVA, :calcular_iva_sencuencial, [lista]})

        send(cliente, {:resultado, resultado, tiempo})
        loop()

      {cliente, {:calcular_concurrente, lista}} ->
        resultado = calcular_iva_concurrente(lista)
        tiempo = Benchmark.determinar_tiempo_ejecucion({ServidorIVA, :calcular_iva_concurrente, [lista]})

        send(cliente, {:resultado, resultado, tiempo})
        loop()
    end
  end

  # -------------------------
  #  CÁLCULO IVA SECUENCIAL
  # -------------------------
  def calcular_iva_sencuencial(lista) do
    Enum.map(lista, fn p ->
      {p.nombre, p.precio_sin_iva * (1 + p.iva)}
    end)
  end

  # -------------------------
  #  CÁLCULO IVA CONCURRENTE
  # -------------------------
  def calcular_iva_concurrente(lista) do
    lista
    |> Enum.map(fn p ->
      Task.async(fn -> {p.nombre, p.precio_sin_iva * (1 + p.iva)} end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))
  end
end

ServidorIVA.main()
