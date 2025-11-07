defmodule Usuario do
  defstruct email: "", edad: 0, nombre: ""

  def crear(email, edad, nombre) do
    %Usuario{email: email, edad: edad, nombre: nombre}
  end
end

defmodule Validador do
  # Función principal: valida un usuario y retorna su resultado
  def validar(usuario) do
    errores = []

    errores =
      errores
      |> validar_correo(usuario.email)
      |> validar_edad(usuario.edad)
      |> validar_nombre(usuario.nombre)

    :timer.sleep(Enum.random(3..10))  # Simula tiempo de validación

    if errores == [] do
      {usuario.email, :ok}
    else
      {usuario.email, {:error, errores}}
    end
  end

  defp validar_correo(errores, email) do
    if String.contains?(email, "@"), do: errores, else: errores ++ ["Correo inválido"]
  end

  defp validar_edad(errores, edad) do
    if edad >= 0, do: errores, else: errores ++ ["Edad negativa"]
  end

  defp validar_nombre(errores, nombre) do
    if String.trim(nombre) != "", do: errores, else: errores ++ ["Nombre vacío"]
  end
end

defmodule Main do
  def main do
    # Datos de ejemplo
    u1 = Usuario.crear("ana@example.com", 25, "Ana")
    u2 = Usuario.crear("pedroexample.com", 30, "Pedro")      # correo inválido
    u3 = Usuario.crear("luz@example.com", -4, "Luz")         # edad inválida
    u4 = Usuario.crear("carlos@example.com", 40, "")         # nombre vacío
    u5 = Usuario.crear("sofia@example.com", 22, "Sofía")

    lista = [u1, u2, u3, u4, u5]

    # Medición de tiempos
    tiempo_sec = Benchmark.determinar_tiempo_ejecucion({Main, :validar_usuarios_secuencial, [lista]})
    tiempo_conc = Benchmark.determinar_tiempo_ejecucion({Main, :validar_usuarios_concurrente, [lista]})

    IO.puts("\nSecuencial: #{tiempo_sec} microsegundos")
    IO.puts("Concurrente: #{tiempo_conc} microsegundos")

    speedup = Benchmark.calcular_speedup(tiempo_conc, tiempo_sec) |> Float.round(2)
    IO.puts("Speedup: #{speedup}x más rápido\n")
  end

  # Versión secuencial
  def validar_usuarios_secuencial(lista) do
    Enum.each(lista, fn u ->
      {email, resultado} = Validador.validar(u)
      IO.inspect({email, resultado})
    end)
  end

  # Versión concurrente
  def validar_usuarios_concurrente(lista) do
    lista
    |> Enum.map(fn u ->
      Task.async(fn ->
        {email, resultado} = Validador.validar(u)
        IO.inspect({email, resultado})
      end)
    end)
    |> Enum.each(&Task.await(&1, 100_000))
  end
end

Main.main()
