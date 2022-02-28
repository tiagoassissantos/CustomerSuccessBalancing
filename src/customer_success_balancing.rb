require 'timeout'

class CustomerSuccessBalancing
  attr_reader :customer_success
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    #available_customer_success = remove_unavailable_cs
    0
  end

  def revome_unavailable_customer_success
    @customer_success.delete_if { |cs| @away_customer_success.include? cs[:id] }
  end

  def sort_customer_success
    @customer_success.sort_by! { |value| value[:score] }
  end

  def group_customers(score)
    selected = @customers.select { |customer| customer[:score] <= score }
    @customers.delete_if { |customer| customer[:score] <= score }
    return selected
  end

  def group_customers_with_customer_success
    grouped_customer_success = []
    customer_success.each { |cs|
      customers_grouped = group_customers(cs[:score])
      grouped_customer_success.push( {cs_id: cs[:id], customers: customers_grouped} ) unless customers_grouped.empty?
    }
    grouped_customer_success
  end
end
