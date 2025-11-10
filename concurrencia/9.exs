defmodule Notif do
  defstruct canal: {}, usuario: "", plantilla: ""
  def crear(c, u, p), do: %Notif{canal: c, usuario: u, plantilla: p}

end

defmodule Notificador do
  def enviar(n) do
    :timer.sleep(costo_por_canal(n.canal))
    IO.puts("Enviada a user #{n.usuario} (canal #{n.canal})")

  end

  def costo_por_canal(canal) do
    case canal do
      :push -> 100
      :email -> 200
      :sms -> 300
    end
  end

end



defmodule Main do
  def main do
    n1 = Notif.crear(:push, "TRST", "Por favor enviar la comida para gato.")
    n2 = Notif.crear(:email, "JOHN", "Recordatorio de pago pendiente.")
    n3 = Notif.crear(:sms, "ALIC", "Su pedido ha sido enviado.")
    n4 = Notif.crear(:push, "MIKE", "Nuevo mensaje en el chat.")
    n5 = Notif.crear(:email, "SARA", "Confirmación de cita médica.")
    n6 = Notif.crear(:sms, "DAVE", "Código de verificación: 584932")
    n7 = Notif.crear(:push, "LISA", "Tu entrega llegará en 30 minutos")
    n8 = Notif.crear(:email, "MARK", "Estado de tu solicitud: Aprobado")
    n9 = Notif.crear(:sms, "ANNA", "Saldo insuficiente en tu cuenta")
    n10 = Notif.crear(:push, "KEVIN", "Promoción especial solo hoy")
    n11 = Notif.crear(:email, "ROSE", "Bienvenido a nuestro servicio premium")
    n12 = Notif.crear(:sms, "TOM", "Tu reserva está confirmada para las 19:00")
    n13 = Notif.crear(:push, "LUcy", "Nueva actualización disponible")
    n14 = Notif.crear(:email, "PAUL", "Factura del mes lista para descargar")
    n15 = Notif.crear(:sms, "NORA", "Alerta de seguridad: inicio de sesión nuevo")
    n16 = Notif.crear(:push, "ERIC", "Tu paquete ha salido del almacén")
    n17 = Notif.crear(:email, "GINA", "Encuesta de satisfacción disponible")
    n18 = Notif.crear(:sms, "LEO", "Tu suscripción expira en 3 días")
    n19 = Notif.crear(:push, "ZOEY", "Oferta flash: 50% de descuento")
    n20 = Notif.crear(:email, "VICTOR", "Documentos importantes adjuntos")


    notificaciones = [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10,
                     n11, n12, n13, n14, n15, n16, n17, n18, n19, n20]

    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [notificaciones]})
    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [notificaciones]})
    IO.puts("\nSecuencial: #{t_sec} microsegundos")
    IO.puts("Concurrente: #{t_con} microsegundos")
    sp_up = Benchmark.calcular_speedup(t_con, t_sec) |> Float.round(2)
    IO.puts("Speed up es #{sp_up}x mas rapido.")

  end

  def secuencial(lista) do
    lista
    |> Enum.each(fn n->
      Notificador.enviar(n)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn n->
      Task.async(fn ->
        Notificador.enviar(n)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

end

Main.main()
