Spree::CheckoutController.class_eval do
  # This is stolen and overridden from spree_core, it should be updated for new spree versions
  def object_params
    # For payment step, filter order parameters to produce the expected nested attributes for a single payment and its source, discarding attributes for payment methods other than the one selected
    if @order.payment?
      if params[:payment_source].present? && source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].underscore]
        params[:order][:payments_attributes].first[:source_attributes] = source_params
      end
      if (params[:order][:payments_attributes])
        # Start changed code
        if @order.preorder_total > 0
          payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
          raise "PaymentMethod does not support recurring payments" unless payment_method.respond_to?(:recurring_payment_method)
          params[:order][:payments_attributes] << params[:order][:payments_attributes].first.clone
          params[:order][:payments_attributes].first[:amount] = @order.preorder_total
          params[:order][:payments_attributes].last[:amount] = (@order.total - @order.preorder_total)
          params[:order][:payments_attributes].last[:payment_method_id] = payment_method.recurring_payment_method.id
        else
          # This is what the old spree core code did
          params[:order][:payments_attributes].first[:amount] = @order.total
        end
        # End changed code
      end
    end
    params[:order]
  end
end
