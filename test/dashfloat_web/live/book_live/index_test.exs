defmodule DashFloatWeb.BookLive.IndexTest do
  use DashFloatWeb.ConnCase, async: true

  import DashFloat.Factories.BudgetingFactory
  import Phoenix.LiveViewTest

  @create_attrs %{name: "Test Book"}
  @update_attrs %{name: "Test Book Updated"}
  @invalid_attrs %{name: nil}

  setup %{conn: conn} do
    user = insert(:user)

    {:ok, conn: log_in_user(conn, user), user: user}
  end

  describe "list" do
    setup %{user: user} do
      book = insert(:book)
      insert(:book_user, book: book, user: user, role: :admin)

      {:ok, book: book}
    end

    test "returns all books", %{conn: conn, book: book} do
      {:ok, _index_live, html} = live(conn, ~p"/books")

      assert html =~ "Listing Books"
      assert html =~ book.name
    end
  end

  describe "create" do
    test "with valid data saves new book", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("a", "New Book") |> render_click() =~
               "New Book"

      assert_patch(index_live, ~p"/books/new")

      assert index_live
             |> form("#book-form", book: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/books")

      html = render(index_live)
      assert html =~ "Book created successfully"
      assert html =~ "Test Book"
    end

    test "with invalid data returns error", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("a", "New Book") |> render_click() =~
               "New Book"

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_submit() =~ "can&#39;t be blank"
    end
  end

  describe "update" do
    setup do
      book = insert(:book)

      {:ok, book: book}
    end

    test "with admin book_user and valid data updates book in listing", %{
      conn: conn,
      book: book,
      user: user
    } do
      insert(:book_user, book: book, user: user, role: :admin)

      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Edit") |> render_click() =~
               "Edit Book"

      assert_patch(index_live, ~p"/books/#{book}/edit")

      assert index_live
             |> form("#book-form", book: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/books")

      html = render(index_live)
      assert html =~ "Book updated successfully"
      assert html =~ "Test Book Updated"
    end

    test "with admin book_user and invalid data returns error", %{
      conn: conn,
      book: book,
      user: user
    } do
      insert(:book_user, book: book, user: user, role: :admin)

      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Edit") |> render_click() =~
               "Edit Book"

      assert_patch(index_live, ~p"/books/#{book}/edit")

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#book-form", book: @invalid_attrs)
             |> render_submit() =~ "can&#39;t be blank"
    end
  end

  describe "delete" do
    setup %{user: user} do
      book = insert(:book)
      insert(:book_user, book: book, user: user, role: :admin)

      {:ok, book: book}
    end

    test "deletes book in listing", %{conn: conn, book: book} do
      {:ok, index_live, _html} = live(conn, ~p"/books")

      assert index_live |> element("#books-#{book.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#books-#{book.id}")
    end
  end
end
