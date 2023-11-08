defmodule DashFloatWeb.UserResetPasswordLive do
  use DashFloatWeb, :live_view

  alias DashFloat.Identity

  def render(assigns) do
    ~H"""
    <main>
      <section class="bg-gray-50 dark:bg-gray-900">
        <div class="flex flex-col items-center justify-center px-6 py-8 mx-auto md:h-screen lg:py-0">
          <.link
            navigate={~p"/"}
            class="flex items-center mb-6 text-2xl font-semibold text-gray-900 dark:text-white"
          >
            DashFloat
          </.link>
          <div class="w-full bg-white rounded-lg shadow dark:border md:mt-0 sm:max-w-md xl:p-0 dark:bg-gray-800 dark:border-gray-700">
            <div class="p-6 space-y-4 md:space-y-6 sm:p-8">
              <h1 class="text-xl font-bold leading-tight tracking-tight text-gray-900 md:text-2xl dark:text-white">
                Reset Password
              </h1>
              <FormComponents.simple_form
                for={@form}
                id="reset_password_form"
                phx-submit="reset_password"
                phx-change="validate"
              >
                <FormComponents.error :if={@form.errors != []}>
                  Oops, something went wrong! Please check the errors below.
                </FormComponents.error>

                <FormComponents.input
                  field={@form[:password]}
                  type="password"
                  label="New password"
                  required
                />
                <FormComponents.input
                  field={@form[:password_confirmation]}
                  type="password"
                  label="Confirm new password"
                  required
                />

                <:actions>
                  <FormComponents.button phx-disable-with="Resetting..." class="w-full">
                    Reset Password
                  </FormComponents.button>
                </:actions>
                <:actions>
                  <p class="text-sm font-medium text-gray-500 dark:text-gray-400">
                    <.link
                      href={~p"/users/register"}
                      class="font-medium text-primary-600 hover:underline dark:text-primary-500"
                    >
                      Register
                    </.link>
                    |
                    <.link
                      href={~p"/users/log_in"}
                      class="font-medium text-primary-600 hover:underline dark:text-primary-500"
                    >
                      Log in
                    </.link>
                  </p>
                </:actions>
              </FormComponents.simple_form>
            </div>
          </div>
        </div>
      </section>
    </main>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{user: user} ->
          Identity.change_user_password(user)

        _any ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil], layout: false}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Identity.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Identity.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Identity.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
