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
    revome_unavailable_customer_success
    sort_customer_success
    cs_with_customers_qty = group_customers_with_customer_success
    cs_with_customers_qty = sort_by_customers_qty_reverse cs_with_customers_qty
    cs_with_more_customers = get_customer_success_with_more_customers cs_with_customers_qty
    return get_customer_succes_id_with_more_customers cs_with_more_customers
  end

  def revome_unavailable_customer_success
    @customer_success.delete_if { |cs| @away_customer_success.include? cs[:id] }
  end

  def sort_customer_success
    @customer_success.sort_by! { |value| value[:score] }
  end

  def group_and_count_customers(score)
    selected = @customers.select { |customer| customer[:score] <= score }
    @customers.delete_if { |customer| customer[:score] <= score }
    return selected.length
  end

  def group_customers_with_customer_success
    grouped_customer_success = []
    customer_success.each { |cs|
      customers_grouped = group_and_count_customers(cs[:score])
      grouped_customer_success.push( {cs_id: cs[:id], customers_qty: customers_grouped} )
    }
    grouped_customer_success
  end

  def sort_by_customers_qty_reverse(cs_with_customers_qty)
    cs_with_customers_qty.sort_by { |value| value[:customers_qty] }.reverse
  end

  def get_customer_success_with_more_customers(cs_with_customers_qty)
    return [] if cs_with_customers_qty.empty?
    return [cs_with_customers_qty[0]] if cs_with_customers_qty.length == 1
    
    if cs_with_customers_qty[0][:customers_qty] == cs_with_customers_qty[1][:customers_qty]
      return [cs_with_customers_qty[0], cs_with_customers_qty[1]]
    else
      return [cs_with_customers_qty[0]]
    end
  end

  def get_customer_succes_id_with_more_customers(cs_with_customers_qty)
    if cs_with_customers_qty.length == 1
      return cs_with_customers_qty[0][:cs_id]
    else
      return 0
    end
  end
end
