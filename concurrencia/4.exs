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
    IO.inspect({r.id , texto_limpio})

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

defmodule Main do
  def main do
    r1 = Review.crear("a1", "La película fue ÉPICA, me encantó cada escena")
    r2 = Review.crear("b2", "No me gustó la actuación del protagonista.")
    r3 = Review.crear("c3", "Excelente historia, pero un poco larga en algunas partes.")
    r4 = Review.crear("d4", "La música y los efectos sonoros fueron geniales.")
    r5 = Review.crear("e5", "Una obra maestra del cine moderno, sin duda.")

    resenas = [r1, r2, r3, r4, r5]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [resenas]})
    t_conc = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [resenas]})
    IO.puts("\nTiempo secuencial: #{t_sec} microsegundos.")
    IO.puts("Tiempo concurrente: #{t_conc} microsegundos.")
    speed_up = Benchmark.calcular_speedup(t_conc, t_sec) |> Float.round(2)
    IO.puts("Speed es #{speed_up}x mas rapido.")

  end

  def secuencial(lista) do
    lista
    |> Enum.each(fn r ->
      Limpieza.limpiar(r)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn r ->
      Task.async(fn ->
        Limpieza.limpiar(r)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

end

Main.main()
