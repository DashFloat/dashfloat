defmodule DashFloatWeb.UserRegistrationLive do
  use DashFloatWeb, :live_view

  alias DashFloat.Identity
  alias DashFloat.Identity.Schemas.User

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
                Register for an account
              </h1>
              <FormComponents.simple_form
                for={@form}
                id="registration_form"
                phx-submit="save"
                phx-change="validate"
                phx-trigger-action={@trigger_submit}
                action={~p"/users/log_in?_action=registered"}
                method="post"
              >
                <FormComponents.error :if={@check_errors}>
                  Oops, something went wrong! Please check the errors below.
                </FormComponents.error>

                <FormComponents.input field={@form[:email]} type="email" label="Email" required />
                <FormComponents.input
                  field={@form[:password]}
                  type="password"
                  label="Password"
                  required
                />

                <:actions>
                  <FormComponents.button phx-disable-with="Creating account..." class="w-full">
                    Create an account
                  </FormComponents.button>
                </:actions>
                <:actions>
                  <p class="text-sm font-medium text-gray-500 dark:text-gray-400">
                    Already registered?
                    <.link
                      navigate={~p"/users/log_in"}
                      class="font-medium text-primary-600 hover:underline dark:text-primary-500"
                    >
                      Sign in
                    </.link>
                    to your account now.
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
    changeset = Identity.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil], layout: false}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Identity.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Identity.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Identity.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Identity.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      # coveralls-ignore-start
      assign(socket, form: form, check_errors: false)
      # coveralls-ignore-stop
    else
      assign(socket, form: form)
    end
  end
end
