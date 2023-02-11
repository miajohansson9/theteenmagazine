class CheckoutsController < ApplicationController
  def show
    current_user.set_payment_processor :stripe
    current_user.payment_processor.pay_customer

    @checkout_session = current_user
      .payment_processor
      .checkout(
        mode: "payment",
        # list of product prices
        line_items: "price_1MaK5yF8Iqixl4Ncggqet0w8",
        success_url: checkout_success_url,
      )
  end

  def success
  end
end
