defmodule Notificacion do
  defstruct canal: "", usuario: "", plantilla: ""

  def crear(canal, usuario, plantilla) do
    %Notificacion{canal: canal, usuario: usuario, plantilla: plantilla}
  end
end

defmodule Envio do
  # Función que simula el envío de una notificación
  def enviar(notif) do
    tiempo = tiempo_por_canal(notif.canal)
    :timer.sleep(tiempo)

    IO.puts("Enviada a #{notif.usuario} (canal #{notif.canal}) en #{tiempo} ms")
    {notif.usuario, notif.canal, tiempo}
  end

  defp tiempo_por_canal(canal) do
    case canal do
      :email -> Enum.random(80..120)
      :sms -> Enum.random(50..70)
      :push -> Enum.random(30..50)
      _ -> Enum.random(60..90)
    end
  end
end

defmodule Main do
  def main do
    # Datos simulados
    n1 = Notificacion.crear(:email, "Ana", "Bienvenida a la plataforma!")
    n2 = Notificacion.crear(:sms, "Pedro", "Tu pedido ha sido enviado.")
    n3 = Notificacion.crear(:push, "Luz", "Tienes una nueva notificación.")
    n4 = Notificacion.crear(:email, "Carlos", "Tu suscripción vence pronto.")
    n5 = Notificacion.crear(:sms, "Sofía", "Recuerda actualizar tu perfil.")

    lista = [n1, n2, n3, n4, n5]

    # Medición de tiempos
    tiempo_sec = Benchmark.determinar_tiempo_ejecucion({Main, :envios_secuenciales, [lista]})
    tiempo_conc = Benchmark.determinar_tiempo_ejecucion({Main, :envios_concurrentes, [lista]})

    IO.puts("\nSecuencial: #{tiempo_sec} microsegundos")
    IO.puts("Concurrente: #{tiempo_conc} microsegundos")

    speedup = Benchmark.calcular_speedup(tiempo_conc, tiempo_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x más rápido\n")
  end

  # Versión secuencial
  def envios_secuenciales(lista) do
    Enum.each(lista, fn notif ->
      Envio.enviar(notif)
    end)
  end

  # Versión concurrente
  def envios_concurrentes(lista) do
    lista
    |> Enum.map(fn notif ->
      Task.async(fn -> Envio.enviar(notif) end)
    end)
    |> Enum.each(&Task.await(&1, 100_000))
  end
end

Main.main()
