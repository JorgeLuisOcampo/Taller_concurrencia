defmodule Comentario do
  defstruct id: "", texto: ""
  def crear(id, t), do: %Comentario{id: id, texto: t}

end

defmodule Moderador do
  @prohibidas ["maldito", "mierda", "pinche", "porquería", "basura"]
  @links ["https//:", "http://", "https://", "www.", ".com", "ftp://"]
  def moderar(c) do
    errores = []
    errores =
      errores
      |> prohibidas(c.texto)
      |> longitud(c.texto)
      |> links(c.texto)
    :timer.sleep(Enum.random(5..12))
    if errores == [] do
      {c.id, :aprobado}
    else
      {c.id, :rechazado}
    end
  end

  def prohibidas(errores, texto) do
    if String.contains?(texto, @prohibidas), do: errores ++ ["palabras prohiubidas"], else: errores
  end
  def longitud(errores, texto) do
    if String.length(texto) <= 50, do: errores, else: errores ++ ["longitud maxima excedida"]
  end
  def links(errores, texto) do
    if String.contains?(texto, @links), do: errores ++ ["comentario contiene links"], else: errores
  end
end

defmodule Main do
  def main do
    c1 = Comentario.crear("jk12", "este maldito pc es muy lento")
    c2 = Comentario.crear("tr34", "tengo hambre y no contestan el telefono en la pizzeria y dominos no esta abierto y no se de donde mas pedir comida por favor sugerencias")
    c3 = Comentario.crear("tr45", "Todo esta muy bien")
    c4 = Comentario.crear("ngr2", "ingresen a este enlace https//:www.google.com")
    c5 = Comentario.crear("ab56", "este servicio de mierda nunca funciona correctamente")
    c6 = Comentario.crear("cd78", "Estoy muy contento con la compra que realicé, el producto llegó en perfecto estado y antes de lo esperado, la atención al cliente fue excelente y definitivamente volveré a comprar aquí nuevamente")
    c7 = Comentario.crear("ef90", "Visiten mi sitio web http://mi-pagina-personal.com para más información")
    c8 = Comentario.crear("gh12", "Excelente servicio, muy recomendado")
    c9 = Comentario.crear("ij34", "pinche aplicación no sirve para nada, siempre se traba")
    c10 = Comentario.crear("kl56", "Necesito ayuda urgente con mi pedido porque hoy es el cumpleaños de mi hijo y prometí que llegaría a tiempo pero todavía no veo el seguimiento y no sé dónde está el paquete por favor ayúdenme lo antes posible")
    c11 = Comentario.crear("mn78", "Descarga gratis desde https://mega.nz/archivos123")
    c12 = Comentario.crear("op90", "Buen producto, cumple con lo esperado")
    c13 = Comentario.crear("qr12", "que porquería de aplicación, no vale la pena")
    c14 = Comentario.crear("st34", "La entrega fue rápida y el producto de buena calidad, estoy satisfecho con la compra y probablemente repita la experiencia en el futuro cercano con otros artículos que necesito para mi hogar")
    c15 = Comentario.crear("uv56", "Regístrense en www.ofertas-gratis.com para ganar premios")
    c16 = Comentario.crear("wx78", "Muy buena atención al cliente")
    c17 = Comentario.crear("yz90", "esta basura de software no funciona nunca")
    c18 = Comentario.crear("ab01", "Llevo esperando más de dos horas y todavía no resuelven mi problema, necesito esto para mi trabajo y cada minuto que pasa es tiempo perdido y dinero que se va, por favor alguien que me ayude inmediatamente")
    c19 = Comentario.crear("cd23", "Checa este link: ftp://servidor-seguro.com/archivos")
    c20 = Comentario.crear("ef45", "Todo perfecto, gracias por el servicio")

    comentarios = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10,
                  c11, c12, c13, c14, c15, c16, c17, c18, c19, c20]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [comentarios]})
    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [comentarios]})
    IO.puts("\nSecuencial: #{t_sec} microsegundos")
    IO.puts("Concurrente: #{t_con} microsegundos")
    sp_up = Benchmark.calcular_speedup(t_con, t_sec) |> Float.round(2)
    IO.puts("Speed up es #{sp_up}x mas rapido")

  end

  def secuencial(lista) do
    lista
    |> Enum.each(fn c ->
      Moderador.moderar(c)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn c ->
      Task.async(fn ->
        Moderador.moderar(c)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

end

Main.main()
