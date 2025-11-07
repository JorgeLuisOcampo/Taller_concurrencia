defmodule Plantilla do
  defstruct id: "", contenido: "", vars: %{}

  def crear(id, contenido, vars) do
    %Plantilla{id: id, contenido: contenido, vars: vars}
  end
end

defmodule Render do
  # Renderiza la plantilla reemplazando las variables y retorna una tupla {id, texto_final}
  def renderizar(tpl) do
    texto_final =
      Enum.reduce(tpl.vars, tpl.contenido, fn {clave, valor}, acc ->
        String.replace(acc, "{#{clave}}", to_string(valor))
      end)

    # Simula tiempo de render según longitud del contenido
    :timer.sleep(String.length(tpl.contenido) * 2)

    resultado = {tpl.id, texto_final}
    IO.inspect(resultado)
    resultado
  end
end

defmodule Main do
  def main do
    # Plantillas simuladas
    p1 = Plantilla.crear("A1", "Hola {nombre}, gracias por tu compra de {producto}.", %{nombre: "Ana", producto: "libro"})
    p2 = Plantilla.crear("B2", "Estimado {nombre}, su pedido {id} ha sido {estado}.", %{nombre: "Pedro", id: 1234, estado: "enviado"})
    p3 = Plantilla.crear("C3", "Hola {nombre}! Tu cita está programada para el {dia}.", %{nombre: "Luz", dia: "viernes"})
    p4 = Plantilla.crear("D4", "Bienvenido {nombre}. Tu cuenta fue creada exitosamente.", %{nombre: "Carlos"})
    p5 = Plantilla.crear("E5", "Hola {nombre}, recuerda que tu saldo actual es de ${saldo}.", %{nombre: "Sofía", saldo: 24500})

    lista = [p1, p2, p3, p4, p5]

    # Medición de tiempos
    tiempo_sec = Benchmark.determinar_tiempo_ejecucion({Main, :render_secuencial, [lista]})
    tiempo_conc = Benchmark.determinar_tiempo_ejecucion({Main, :render_concurrente, [lista]})

    IO.puts("\nSecuencial: #{tiempo_sec} microsegundos")
    IO.puts("Concurrente: #{tiempo_conc} microsegundos")

    speedup = Benchmark.calcular_speedup(tiempo_conc, tiempo_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x más rápido\n")
  end

  # Versión secuencial (imprime tuplas)
  def render_secuencial(lista) do
    Enum.each(lista, fn tpl ->
      Render.renderizar(tpl)
    end)
  end

  # Versión concurrente (imprime tuplas)
  def render_concurrente(lista) do
    lista
    |> Enum.map(fn tpl ->
      Task.async(fn -> Render.renderizar(tpl) end)
    end)
    |> Enum.each(&Task.await(&1, 100_000))
  end
end

Main.main()
