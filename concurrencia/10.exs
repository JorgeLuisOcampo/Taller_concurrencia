defmodule Paquete do
  defstruct id: "", peso: 0, fragil?: false

  def crear(id, peso, fragil?) do
    %Paquete{id: id, peso: peso, fragil?: fragil?}
  end
end

defmodule Logistica do
  # Función que simula la preparación de un paquete
  def preparar(paquete) do
    tiempo_etiqueta = Enum.random(20..40)
    tiempo_pesado = Enum.random(30..50)
    tiempo_embalaje = if paquete.fragil?, do: Enum.random(80..120), else: Enum.random(40..60)

    total = tiempo_etiqueta + tiempo_pesado + tiempo_embalaje
    :timer.sleep(total)

    # Salida como tupla
    IO.inspect({paquete.id, total})

    {paquete.id, total}
  end
end

defmodule Main do
  def main do
    # Paquetes simulados
    p1 = Paquete.crear("A1", 5, false)
    p2 = Paquete.crear("B2", 3, true)
    p3 = Paquete.crear("C3", 7, false)
    p4 = Paquete.crear("D4", 2, true)
    p5 = Paquete.crear("E5", 10, false)

    lista = [p1, p2, p3, p4, p5]

    # Medición de tiempos
    tiempo_sec = Benchmark.determinar_tiempo_ejecucion({Main, :procesar_secuencial, [lista]})
    tiempo_conc = Benchmark.determinar_tiempo_ejecucion({Main, :procesar_concurrente, [lista]})

    IO.puts("\nSecuencial: #{tiempo_sec} microsegundos")
    IO.puts("Concurrente: #{tiempo_conc} microsegundos")

    speedup = Benchmark.calcular_speedup(tiempo_conc, tiempo_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x más rápido\n")
  end

  # Versión secuencial
  def procesar_secuencial(lista) do
    Enum.each(lista, fn p ->
      Logistica.preparar(p)
    end)
  end

  # Versión concurrente
  def procesar_concurrente(lista) do
    lista
    |> Enum.map(fn p ->
      Task.async(fn -> Logistica.preparar(p) end)
    end)
    |> Enum.each(&Task.await(&1, 100_000))
  end
end

Main.main()
