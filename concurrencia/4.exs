defmodule Review do
  defstruct id: "", texto: ""

  def crear(id, texto) do
    %Review{id: id, texto: texto}
  end
end

defmodule Limpieza do
  @stopwords ["el", "la", "los", "las", "de", "del", "un", "una", "unos", "unas",
               "y", "o", "en", "es", "por", "para", "con", "a", "al", "se", "su"]

  def limpiar(review) do
    texto_limpio =
      review.texto
      |> String.downcase()
      |> quitar_tildes()
      |> quitar_signos()
      |> quitar_stopwords()

    :timer.sleep(Enum.random(5..15))
    {review.id, texto_limpio}
  end

  defp quitar_tildes(texto) do
    texto
    |> String.replace("á", "a")
    |> String.replace("é", "e")
    |> String.replace("í", "i")
    |> String.replace("ó", "o")
    |> String.replace("ú", "u")
  end

  defp quitar_signos(texto) do
    texto
    |> String.replace(~r/[¡!¿?,.;:()"]/u, "")
  end

  defp quitar_stopwords(texto) do
    texto
    |> String.split()
    |> Enum.reject(&(&1 in @stopwords))
    |> Enum.join(" ")
  end
end

defmodule Main do
  def main do
    r1 = Review.crear("a1", "¡La película fue ÉPICA, me encantó cada escena!")
    r2 = Review.crear("b2", "No me gustó la actuación del protagonista.")
    r3 = Review.crear("c3", "Excelente historia, pero un poco larga en algunas partes.")
    r4 = Review.crear("d4", "La música y los efectos sonoros fueron geniales.")
    r5 = Review.crear("e5", "Una obra maestra del cine moderno, sin duda.")

    lista = [r1, r2, r3, r4, r5]

    tiempo_sec = Benchmark.determinar_tiempo_ejecucion({Main, :limpieza_secuencial, [lista]})
    tiempo_conc = Benchmark.determinar_tiempo_ejecucion({Main, :limpieza_concurrente, [lista]})

    IO.puts("\nSecuencial: #{tiempo_sec} microsegundos")
    IO.puts("Concurrente: #{tiempo_conc} microsegundos")

    speedup = Benchmark.calcular_speedup(tiempo_conc, tiempo_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x más rápido\n")
  end

  # Versión secuencial con salida en tuplas
  def limpieza_secuencial(lista) do
    Enum.each(lista, fn r ->
      resultado = Limpieza.limpiar(r)
      IO.inspect(resultado)
    end)
  end

  # Versión concurrente con salida en tuplas
  def limpieza_concurrente(lista) do
    lista
    |> Enum.map(fn r ->
      Task.async(fn ->
        resultado = Limpieza.limpiar(r)
        IO.inspect(resultado)
      end)
    end)
    |> Enum.each(&Task.await(&1, 100_000))
  end
end

Main.main()
