
defmodule ServidorEj4 do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej4

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)
    IO.puts("ServidorEj4 listo")
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

  @stopwords ["el","la","los","las","de","del","un","una","unos","unas","y","o","en","es","por","para","con","a","al","se","su"]

  defp no_tildes(t) do
    t
    |> String.replace("á","a")
    |> String.replace("é","e")
    |> String.replace("í","i")
    |> String.replace("ó","o")
    |> String.replace("ú","u")
  end

  defp no_stopword(t) do
    t
    |> String.split()
    |> Enum.reject(&(&1 in @stopwords))
    |> Enum.join(" ")
  end

  defp limpiar(r) do
    texto =
      r.texto
      |> String.downcase()
      |> no_tildes()
      |> no_stopword()
    {r.id, texto}
  end

  def secuencial(lista), do: Enum.map(lista, &limpiar/1)

  def concurrente(lista) do
    lista
    |> Enum.map(fn r -> Task.async(fn -> limpiar(r) end) end)
    |> Enum.map(&Task.await(&1, 10_000))
  end

end

ServidorEj4.main()
