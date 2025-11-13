defmodule Review do
  defstruct id: "", texto: ""
  def crear(id, texto), do: %Review{id: id, texto: texto}
end

defmodule Limpieza do
  @stopwords ["el", "la", "los", "las", "de", "del", "un", "una", "unos", "unas",
              "y", "o", "en", "es", "por", "para", "con", "a", "al", "se", "su"]

  def limpiar(r) do
    texto_limpio =
      r.texto
      |> String.downcase()
      |> no_tildes()
      |> no_stopword()

    :timer.sleep(Enum.random(5..15))

    IO.inspect({r.id, texto_limpio})
  end

  def no_tildes(t) do
    t
    |> String.replace("á", "a")
    |> String.replace("é", "e")
    |> String.replace("í", "i")
    |> String.replace("ó", "o")
    |> String.replace("ú", "u")
  end

  def no_stopword(t) do
    t
    |> String.split()
    |> Enum.reject(&(&1 in @stopwords))
    |> Enum.join(" ")
  end
end

defmodule Servidor do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_review

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)

    IO.puts("\nServidor Review listo\n")
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

  def secuencial(lista) do
    Enum.each(lista, fn r -> Limpieza.limpiar(r) end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn r ->
      Task.async(fn -> Limpieza.limpiar(r) end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))
  end
end

Servidor.main()
