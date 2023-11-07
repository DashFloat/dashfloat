defmodule DashFloatWeb.UserLoginLive do
  use DashFloatWeb, :live_view

  def render(assigns) do
    ~H"""
    <main>
      <section class="bg-gray-50 dark:bg-gray-900">
        <div class="flex flex-col items-center justify-center px-6 py-8 mx-auto md:h-screen lg:py-0">
          <a
            href="/"
            class="flex items-center mb-6 text-2xl font-semibold text-gray-900 dark:text-white"
          >
            DashFloat
          </a>
          <div class="w-full bg-white rounded-lg shadow dark:border md:mt-0 sm:max-w-md xl:p-0 dark:bg-gray-800 dark:border-gray-700">
            <div class="p-6 space-y-4 md:space-y-6 sm:p-8">
              <h1 class="text-xl font-bold leading-tight tracking-tight text-gray-900 md:text-2xl dark:text-white">
                Sign in to your account
              </h1>
              <FormComponents.simple_form
                for={@form}
                id="login_form"
                action={~p"/users/log_in"}
                phx-update="ignore"
              >
                <FormComponents.input field={@form[:email]} type="email" label="Email" required />
                <FormComponents.input
                  field={@form[:password]}
                  type="password"
                  label="Password"
                  required
                />

                <:actions>
                  <FormComponents.input
                    field={@form[:remember_me]}
                    type="checkbox"
                    label="Keep me logged in"
                  />
                  <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
                    Forgot your password?
                  </.link>
                </:actions>
                <:actions>
                  <FormComponents.button phx-disable-with="Signing in..." class="w-full">
                    Sign in <span aria-hidden="true">→</span>
                  </FormComponents.button>
                </:actions>
                <:actions>
                  <p class="text-sm font-medium text-gray-500 dark:text-gray-400">
                    Don’t have an account yet?
                    <.link
                      navigate={~p"/users/register"}
                      class="font-medium text-primary-600 hover:underline dark:text-primary-500"
                    >
                      Sign up
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
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form], layout: false}
  end
end
