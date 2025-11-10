defmodule Tpl do
  defstruct id: "", nombre: "", vars: %{}
  def crear(i,n,v), do: %Tpl{id: i, nombre: n, vars: v}

end

defmodule Procesador do
  def render(p) do
    html =
      p.vars
      |> Enum.reduce(p.nombre, fn{clave, valor}, acc ->
        String.replace(acc, "{#{clave}}", to_string(valor))
      end)
    :timer.sleep(String.length(html))
    IO.inspect({p.id, html})
  end

end

defmodule Main do
  def main do
    p1 = Tpl.crear("A1", "Hola {nombre}, gracias por tu compra de {producto}.", %{nombre: "Ana", producto: "libro"})
    p2 = Tpl.crear("B2", "Estimado {nombre}, su pedido {id} ha sido {estado}.", %{nombre: "Pedro", id: 1234, estado: "enviado"})
    p3 = Tpl.crear("C3", "Hola {nombre}! Tu cita está programada para el {dia}.", %{nombre: "Luz", dia: "viernes"})
    p4 = Tpl.crear("D4", "Bienvenido {nombre}. Tu cuenta fue creada exitosamente.", %{nombre: "Carlos"})
    p5 = Tpl.crear("E5", "Hola {nombre}, recuerda que tu saldo actual es de ${saldo}.", %{nombre: "Sofía", saldo: 24500})

    tpls = [p1, p2, p3, p4, p5]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [tpls]})
    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [tpls]})
    IO.puts("\nSecuencial: #{t_sec} microsegundos")
    IO.puts("Concurrente: #{t_con} microsgundos")
    sp_up = Benchmark.calcular_speedup(t_con, t_sec) |> Float.round(2)
    IO.puts("Speed up es #{sp_up}x mas rapiudo")
  end

  def secuencial(lista) do
    lista
    |> Enum.each(fn p ->
      Procesador.render(p)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn p ->
      Task.async(fn ->
        Procesador.render(p)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

end

Main.main()
