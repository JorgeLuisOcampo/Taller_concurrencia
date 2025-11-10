defmodule User do
  defstruct email: "", edad: 0, nombre: ""
  def crear(em,edad,name), do: %User{email: em, edad: edad, nombre: name}

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

  def validar_email(lista_errores, email) do
    if String.contains?(email, "@"), do: lista_errores, else: lista_errores ++ ["correo no valido"]
  end
  def validar_edad(lista_errores, edad) do
    if edad >= 0, do: lista_errores, else: lista_errores ++ ["edad no valida"]
  end
  def validar_nombre(lista_errores, nombre) do
    if nombre != "", do: lista_errores, else: lista_errores ++ ["nombre no valido"]
  end
end

defmodule Main do
  def main do
    u1 = User.crear("ana@example.com", 25, "Ana")
    u2 = User.crear("pedroexample.com", 30, "Pedro")
    u3 = User.crear("luz@example.com", -4, "Luz")
    u4 = User.crear("carlos@example.com", 40, "")
    u5 = User.crear("sofia@example.com", 22, "Sofia")

    usuarios = [u1, u2, u3, u4, u5]
    t_sec = Benchmark.determinar_tiempo_ejecucion({Main, :secuencial, [usuarios]})
    t_con = Benchmark.determinar_tiempo_ejecucion({Main, :concurrente, [usuarios]})
    IO.puts("\nSecuencial: #{t_sec} microsegundos.")
    IO.puts("Concurrente: #{t_con} microsegundos.")

    sp_up = Benchmark.calcular_speedup(t_con, t_sec) |> Float.round(2)

    IO.puts("Speed up es #{sp_up}x mas rapido.")

  end

  def secuencial(lista) do
    lista
    |> Enum.each(fn u ->
      Validador.validar(u)
    end)
  end

  def concurrente(lista) do
    lista
    |> Enum.map(fn u ->
      Task.async(fn ->
        Validador.validar(u)
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

end

Main.main()
