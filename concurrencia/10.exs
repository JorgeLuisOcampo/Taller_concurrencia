defmodule Paquete do
  defstruct id: "", peso: 0.0, fragil: ""
  def crear(id, p, f), do: %Paquete{id: id, peso: p, fragil: f}

end

defmodule Empaquetar do
  def preparar(p) do
    recepcion = 200
    t_peso = pesar(p.peso)
    t_fragil = es_fragil(p.fragil)
    :timer.sleep(recepcion)
    :timer.sleep(t_peso)
    :timer.sleep(t_fragil)
    listo_en_ms = recepcion + t_peso + t_fragil
    IO.inspect({p.id, listo_en_ms})
  end

  def pesar(peso) do
    cond do
      peso <= 500 -> 400
      peso > 500 -> 600
    end
  end

  def es_fragil(fragil) do
    case fragil do
      :si -> 300
      :no -> 100
    end
  end

end

defmodule Main do
  def main do
    p1 = Paquete.crear("ax182", 250, :no)
    p2 = Paquete.crear("bx293", 1250, :si)
    p3 = Paquete.crear("cx384", 500, :no)
    p4 = Paquete.crear("dx475", 750, :si)
    p5 = Paquete.crear("ex566", 3000, :no)
    p6 = Paquete.crear("fx657", 150, :si)
    p7 = Paquete.crear("gx748", 1800, :no)
    p8 = Paquete.crear("hx839", 2200, :si)
    p9 = Paquete.crear("ix920", 450, :no)
    p10 = Paquete.crear("jx011", 1200, :si)
    p11 = Paquete.crear("kx102", 3200, :no)
    p12 = Paquete.crear("lx213", 800, :si)
    p13 = Paquete.crear("mx324", 950, :no)
    p14 = Paquete.crear("nx435", 1750, :si)
    p15 = Paquete.crear("ox546", 2800, :no)
    p16 = Paquete.crear("px657", 350, :si)
    p17 = Paquete.crear("qx768", 4200, :no)
    p18 = Paquete.crear("rx879", 600, :si)
    p19 = Paquete.crear("sx980", 1350, :no)
    p20 = Paquete.crear("tx091", 1900, :si)

    paquetes = [p1, p2, p3, p4, p5, p6, p7, p8, p9, p10,
               p11, p12, p13, p14, p15, p16, p17, p18, p19, p20]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [paquetes]})
    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [paquetes]})
    IO.puts("\nSecuencial : #{t_sec} microsegundos")
    IO.puts("Concurrente: #{t_con} microsegundos")
    sp_up = Benchmark.calcular_speedup(t_con, t_sec)
    IO.puts("Speed up es #{sp_up}x mas rapido")

  end

  def secuencial(lista) do
    lista
    |> Enum.each(fn p ->
      Empaquetar.preparar(p)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn p ->
      Task.async(fn ->
        Empaquetar.preparar(p)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

end

Main.main()
