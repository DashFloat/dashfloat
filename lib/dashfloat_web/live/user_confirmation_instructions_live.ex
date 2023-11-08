defmodule DashFloatWeb.UserConfirmationInstructionsLive do
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
              <FormComponents.header>
                No confirmation instructions received?
                <:subtitle>We'll send a new confirmation link to your inbox</:subtitle>
              </FormComponents.header>
              <FormComponents.simple_form
                for={@form}
                id="resend_confirmation_form"
                phx-submit="send_instructions"
              >
                <FormComponents.input field={@form[:email]} type="email" label="Email" required />

                <:actions>
                  <FormComponents.button phx-disable-with="Sending..." class="w-full">
                    Resend confirmation instructions
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

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user")), layout: false}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Identity.get_user_by_email(email) do
      Identity.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
