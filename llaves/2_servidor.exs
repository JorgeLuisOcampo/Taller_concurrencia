defmodule ServidorIVA do
  @nodo_servidor :"servidor@192.168.1.25"
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
      {cliente, {:secuencial, lista}} ->
        resultado = secuencial(lista)
        tiempo = Benchmark.determinar_tiempo_ejecucion({ServidorIVA, :secuencial, [lista]})

        send(cliente, {:resultado, resultado, tiempo})
        loop()

      {cliente, {:concurrente, lista}} ->
        resultado = concurrente(lista)
        tiempo = Benchmark.determinar_tiempo_ejecucion({ServidorIVA, :concurrente, [lista]})

        send(cliente, {:resultado, resultado, tiempo})
        loop()
    end
  end

  # -------------------------
  #  CÁLCULO IVA SECUENCIAL
  # -------------------------
  def secuencial(lista) do
    lista
    |> Enum.map( fn p ->
      precio_final(p)
    end)
  end

  # -------------------------
  #  CÁLCULO IVA CONCURRENTE
  # -------------------------
  def concurrente(lista) do
    lista
    |> Enum.map(fn p ->
      Task.async(fn ->
        precio_final(p)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))

  end

  def precio_final(p) do
    precio_con_iva = p.precio * 1 + p.iva
    precio_final = precio_con_iva * p.stock
    {p.nombre, precio_final}
  end
end

ServidorIVA.main()
