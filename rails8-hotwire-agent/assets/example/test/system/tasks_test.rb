require "application_system_test_case"

class TasksSystemTest < ApplicationSystemTestCase
  test "two creations and a validation error preserve Turbo frame and Stimulus" do
    visit new_session_path
    fill_in "email_address", with: users(:alice).email_address
    fill_in "password", with: "password-for-tests"
    click_on "Sign in"
    assert_current_path root_path

    # Token stays on documentElement across stream updates; a full page load
    # would erase it. This proves JS flow rather than a plain HTML fallback.
    page.execute_script("document.documentElement.dataset.exampleMarker = 'retained'")
    ["First task", "Second task"].each do |title|
      within "turbo-frame#task_form" do
        fill_in "Título", with: title
        assert_selector "output", text: "#{title.length}/200"
        click_on "Salvar tarefa"
      end
      assert_selector "#tasks article", text: title
      assert_selector "turbo-frame#task_form", count: 1
      within "turbo-frame#task_form" do
        assert_field "Título", with: ""
        assert_selector "output", text: "0/200"
      end
      assert_equal "retained", page.evaluate_script("document.documentElement.dataset.exampleMarker")
    end

    within "turbo-frame#task_form" do
      fill_in "Título", with: "x" * 201
      click_on "Salvar tarefa"
      assert_selector '[role="alert"]'
      assert_field "Título", with: "x" * 201
    end
    assert_selector "turbo-frame#task_form", count: 1
    assert_equal "retained", page.evaluate_script("document.documentElement.dataset.exampleMarker")
  end
end
