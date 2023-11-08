defmodule DashFloatWeb.UserConfirmationLive do
  use DashFloatWeb, :live_view

  alias DashFloat.Identity

  def render(%{live_action: :edit} = assigns) do
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
                Confirm Account
              </h1>
              <FormComponents.simple_form
                for={@form}
                id="confirmation_form"
                phx-submit="confirm_account"
              >
                <FormComponents.input field={@form[:token]} type="hidden" />

                <:actions>
                  <FormComponents.button phx-disable-with="Confirming..." class="w-full">
                    Confirm my account
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

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: nil], layout: false}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm_account", %{"user" => %{"token" => token}}, socket) do
    case Identity.confirm_user(token) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          # credo:disable-for-next-line Credo.Check.Refactor.NegatedIsNil
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/")}
        end
    end
  end
end
