require 'test_helper'

class JobLog2sControllerTest < ActionController::TestCase
  setup do
    @job_log2 = job_log2s(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:job_log2s)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job_log2" do
    assert_difference('JobLog2.count') do
      post :create, job_log2: { date: @job_log2.date, day_of_the_week: @job_log2.day_of_the_week, end_time: @job_log2.end_time, spend_time: @job_log2.spend_time, start_time: @job_log2.start_time, title: @job_log2.title }
    end

    assert_redirected_to job_log2_path(assigns(:job_log2))
  end

  test "should show job_log2" do
    get :show, id: @job_log2
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @job_log2
    assert_response :success
  end

  test "should update job_log2" do
    patch :update, id: @job_log2, job_log2: { date: @job_log2.date, day_of_the_week: @job_log2.day_of_the_week, end_time: @job_log2.end_time, spend_time: @job_log2.spend_time, start_time: @job_log2.start_time, title: @job_log2.title }
    assert_redirected_to job_log2_path(assigns(:job_log2))
  end

  test "should destroy job_log2" do
    assert_difference('JobLog2.count', -1) do
      delete :destroy, id: @job_log2
    end

    assert_redirected_to job_log2s_path
  end
end
