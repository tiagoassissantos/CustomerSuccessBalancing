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
    balancer = create_balancer
    customer_qty = balancer.group_and_count_customers(40)
    assert_equal 3, customer_qty
  end

  def test_should_return_empty_in_group_customers
    balancer = create_balancer
    customer_qty = balancer.group_and_count_customers(9)
    assert_equal 0, customer_qty
  end

  def test_should_group_customers_with_each_customer_success
    expected_result = [
      {cs_id: 1, customers_qty: 3},
      {cs_id: 2, customers_qty: 2}
    ]
    balancer = create_balancer
    group = balancer.group_customers_with_customer_success
    assert_equal expected_result, group
  end

  def test_should_sort_by_customers_qty_reverse
    cs_with_customers_qty = [ {cs_id: 2, customers_qty: 2}, {cs_id: 1, customers_qty: 3} ]
    expected_result = [ {cs_id: 1, customers_qty: 3}, {cs_id: 2, customers_qty: 2} ]
    balancer = create_balancer

    sorted = balancer.sort_by_customers_qty_reverse cs_with_customers_qty
    assert_equal expected_result, sorted
  end

  def test_should_get_customer_success_with_more_customers_scenario_one
    cs_with_customers_qty = [ {cs_id: 1, customers_qty: 3}, {cs_id: 2, customers_qty: 2} ]
    balancer = create_balancer

    result = balancer.get_customer_success_with_more_customers cs_with_customers_qty
    assert_equal 1, result.length
  end

  def test_should_get_customer_success_with_more_customers_scenario_two
    cs_with_customers_qty = [ {cs_id: 1, customers_qty: 3}, {cs_id: 2, customers_qty: 3} ]
    balancer = create_balancer

    result = balancer.get_customer_success_with_more_customers cs_with_customers_qty
    assert_equal 2, result.length
  end

  def test_should_get_customer_success_with_more_customers_scenario_three
    cs_with_customers_qty = []
    balancer = create_balancer

    result = balancer.get_customer_success_with_more_customers cs_with_customers_qty
    assert_equal 0, result.length
  end

  def test_should_get_customer_success_with_more_customers_scenario_four
    cs_with_customers_qty = [ {cs_id: 2, customers_qty: 3} ]
    balancer = create_balancer

    result = balancer.get_customer_success_with_more_customers cs_with_customers_qty
    assert_equal 1, result.length
  end

  def test_should_get_customer_succes_id_with_more_customers_scenario_one
    cs_with_customers_qty = [ {cs_id: 2, customers_qty: 3} ]
    balancer = create_balancer

    result = balancer.get_customer_succes_id_with_more_customers cs_with_customers_qty
    assert_equal 2, result
  end

  def test_should_get_customer_succes_id_with_more_customers_scenario_two
    cs_with_customers_qty = [ {cs_id: 2, customers_qty: 3}, {cs_id: 1, customers_qty: 3} ]
    balancer = create_balancer

    result = balancer.get_customer_succes_id_with_more_customers cs_with_customers_qty
    assert_equal 0, result
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end

  def create_balancer
    customer_success = build_scores([40, 70])
    customers = build_scores([80,20,50,10,30,60])
    balancer = CustomerSuccessBalancing.new(customer_success, customers, [1])
  end
end
