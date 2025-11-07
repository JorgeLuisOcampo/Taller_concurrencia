defmodule Comentario do
  defstruct id: "", texto: ""

  def crear(id, texto) do
    %Comentario{id: id, texto: texto}
  end
end

defmodule Moderador do
  @palabras_prohibidas ["malo", "odio", "tonto", "estupido", "grosero"]

  # Evalúa un comentario y determina si es aprobado o rechazado
  def moderar(comentario) do
    :timer.sleep(Enum.random(5..12))

    if contiene_prohibidas?(comentario.texto) or contiene_link?(comentario.texto) or demasiado_largo?(comentario.texto) do
      # Salida como tupla
      IO.inspect({comentario.id, :rechazado})
      {comentario.id, :rechazado}
    else
      IO.inspect({comentario.id, :aprobado})
      {comentario.id, :aprobado}
    end
  end

  # Verifica si el texto contiene palabras prohibidas
  defp contiene_prohibidas?(texto) do
    texto_down = String.downcase(texto)
    Enum.any?(@palabras_prohibidas, fn palabra -> String.contains?(texto_down, palabra) end)
  end

  # Verifica si hay un enlace en el texto
  defp contiene_link?(texto) do
    String.contains?(texto, ["http", "www", ".com"])
  end

  # Verifica si el texto supera cierta longitud
  defp demasiado_largo?(texto) do
    String.length(texto) > 120
  end
end

defmodule Main do
  def main do
    # Comentarios de ejemplo
    c1 = Comentario.crear("A1", "Excelente servicio, muy recomendable.")
    c2 = Comentario.crear("B2", "Este producto es malo y tonto.")
    c3 = Comentario.crear("C3", "Visita mi página en http://spam.com para más info.")
    c4 = Comentario.crear("D4", "Buen precio y atención rápida.")
    c5 = Comentario.crear("E5", String.duplicate("Muy bueno! ", 20)) # largo

    lista = [c1, c2, c3, c4, c5]

    # Medición de tiempos
    tiempo_sec = Benchmark.determinar_tiempo_ejecucion({Main, :moderar_secuencial, [lista]})
    tiempo_conc = Benchmark.determinar_tiempo_ejecucion({Main, :moderar_concurrente, [lista]})

    IO.puts("\nSecuencial: #{tiempo_sec} microsegundos")
    IO.puts("Concurrente: #{tiempo_conc} microsegundos")

    speedup = Benchmark.calcular_speedup(tiempo_conc, tiempo_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x más rápido\n")
  end

  # Versión secuencial
  def moderar_secuencial(lista) do
    Enum.each(lista, fn c ->
      Moderador.moderar(c)
    end)
  end

  # Versión concurrente
  def moderar_concurrente(lista) do
    lista
    |> Enum.map(fn c ->
      Task.async(fn -> Moderador.moderar(c) end)
    end)
    |> Enum.each(&Task.await(&1, 100_000))
  end
end

Main.main()
