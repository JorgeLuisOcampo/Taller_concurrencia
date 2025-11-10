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
      {cliente, {:sencuencial, lista}} ->
        resultado = encuencial(lista)
        tiempo = Benchmark.determinar_tiempo_ejecucion({ServidorIVA, :sencuencial, [lista]})

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
  def sencuencial(lista) do
    lista
    |> Enum.map( fn p ->
      preparar(o)
    end)
  end

  # -------------------------
  #  CÁLCULO IVA CONCURRENTE
  # -------------------------
  def concurrente(lista) do
    lista
    |> Enum.map(fn o ->
      Task.async(fn ->
        preparar(o)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))

  end

  def preparar(o) do
    precio_con_iva = o.precio * 1 + o.iva
    precio_final = precio_con_iva * p.stock
    {nombre, precio_final}
  end
end

ServidorIVA.main()
