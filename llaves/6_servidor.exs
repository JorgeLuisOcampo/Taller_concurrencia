
defmodule ServidorEj6 do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_ej6

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)
    IO.puts("ServidorEj6 listo")
    loop()
  end

  defp loop do
    receive do
      {cliente, {{:secuencial, :ok}, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :secuencial, [lista]})
        resultado = secuencial(lista)
        send(cliente, {{:resultado, :ok}, resultado, tiempo})
        loop()
      {cliente, {{:concurrente, :ok}, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({__MODULE__, :concurrente, [lista]})
        resultado = concurrente(lista)
        send(cliente, {{:resultado, :ok}, resultado, tiempo})
        loop()
    end
  end

  # --- logica del ejercicio ---

  defp validar(u) do
    errores = []
    errores =
      errores
      |> validar_email(u.email)
      |> validar_edad(u.edad)
      |> validar_nombre(u.nombre)
    if errores == [], do: {u.email, :ok}, else: {u.email, {:error, errores}}
  end

  defp validar_email(lst, email), do: if String.contains?(email, "@"), do: lst, else: lst ++ ["correo no valido"]
  defp validar_edad(lst, edad), do: if edad >= 0, do: lst, else: lst ++ ["edad no valida"]
  defp validar_nombre(lst, nombre), do: if nombre != "", do: lst, else: lst ++ ["nombre no valido"]

  def secuencial(lista), do: Enum.map(lista, &validar/1)

  def concurrente(lista) do
    lista
    |> Enum.map(fn u -> Task.async(fn -> validar(u) end) end)
    |> Enum.map(&Task.await(&1, 10_000))
  end

end

ServidorEj6.main()
