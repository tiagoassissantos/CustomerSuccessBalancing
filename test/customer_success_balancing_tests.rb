require 'minitest/autorun'
require 'timeout'
require_relative '../src/customer_success_balancing.rb'

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end


  def test_should_revome_unavailable_costomer_success
    customer_success = build_scores([100, 99])
    customers = build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
    balancer = CustomerSuccessBalancing.new(customer_success, customers, [2])
    balancer.revome_unavailable_customer_success

    assert_equal [{:id=>1, :score=>100}], balancer.customer_success
  end

  def test_should_sort_array
    balancer = CustomerSuccessBalancing.new(build_scores([1,5,7,3,6,9,5,3]), build_scores([]), [1])
    balancer.sort_customer_success
    assert_equal 3, balancer.customer_success[2][:score]
    assert_equal 9, balancer.customer_success[7][:score]
  end

  def test_should_group_customers_with_one_customer_success
    expected_result = [{id: 2, score: 20}, {id: 4, score: 10}, {id: 5, score: 30}]
    customers = build_scores([80,20,50,10,30,60])
    balancer = CustomerSuccessBalancing.new(build_scores([1,5,7,3,6,9,5,3]), customers, [1])
    group = balancer.group_customers(40)
    assert_equal expected_result, group
  end

  def test_should_return_empty_in_group_customers
    expected_result = []
    customers = build_scores([80,50,60])
    balancer = CustomerSuccessBalancing.new(build_scores([1,5,7,3,6,9,5,3]), customers, [1])
    group = balancer.group_customers(40)
    assert_equal expected_result, group
  end

  def test_should_group_customers_with_each_customer_success
    expected_result = [
      {cs_id: 1, customers: [{id: 2, score: 20}, {id: 4, score: 10}, {id: 5, score: 30}]},
      {cs_id: 2, customers: [{id: 3, score: 50}, {id: 6, score: 60}]}
    ]
    customer_success = build_scores([40, 70])
    customers = build_scores([80,20,50,10,30,60])
    balancer = CustomerSuccessBalancing.new(customer_success, customers, [1])
    group = balancer.group_customers_with_customer_success
    assert_equal expected_result, group
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
