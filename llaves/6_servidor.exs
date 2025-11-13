defmodule User do
  defstruct email: "", edad: 0, nombre: ""
  def crear(em, edad, name), do: %User{email: em, edad: edad, nombre: name}
end

defmodule Validador do
  def validar(u) do
    lista_errores = []

    lista_errores =
      lista_errores
      |> validar_email(u.email)
      |> validar_edad(u.edad)
      |> validar_nombre(u.nombre)

    :timer.sleep(Enum.random(3..10))

    if lista_errores == [] do
      IO.inspect({u.email, :ok})
    else
      IO.inspect({u.email, {:error, lista_errores}})
    end
  end

  def validar_email(lista, email) do
    if String.contains?(email, "@"), do: lista, else: lista ++ ["correo no valido"]
  end

  def validar_edad(lista, edad) do
    if edad >= 0, do: lista, else: lista ++ ["edad no valida"]
  end

  def validar_nombre(lista, nombre) do
    if nombre != "", do: lista, else: lista ++ ["nombre no valido"]
  end
end

defmodule Servidor do
  @nodo_servidor :"servidor@192.168.1.25"
  @servicio :servicio_validacion

  def main() do
    Node.start(@nodo_servidor)
    Node.set_cookie(:my_cookie)
    Process.register(self(), @servicio)

    IO.puts("\nServidor de Validación listo\n")
    loop()
  end

  defp loop do
    receive do
      {cliente, {:secuencial, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({Servidor, :secuencial, [lista]})
        send(cliente, {:resultado, tiempo})
        loop()

      {cliente, {:concurrente, lista}} ->
        tiempo = Benchmark.determinar_tiempo_ejecucion({Servidor, :concurrente, [lista]})
        send(cliente, {:resultado, tiempo})
        loop()
    end
  end

  def secuencial(lista) do
    Enum.each(lista, fn u -> Validador.validar(u) end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn u ->
      Task.async(fn -> Validador.validar(u) end)
    end)
    |> Enum.map(&Task.await(&1, 100_000))
  end
end

Servidor.main()
