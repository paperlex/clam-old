class CallbackController < ApplicationController
  
  def signature
    contract = Contract.find_by_uuid(params[:contract_uuid])
    Signature.create(:contributor_license_agreement => contract.contributor_license_agreement, :user => contract.user, :contract => contract, :contract_uuid => params[:contract_uuid], :signature_uuid => params[:signature_uuid], :identity_verification_method => params[:identity_verification_method], :identity_verification_value => params[:identity_verification_value], :callback_signature_created_at => params[:callback_signature_created_at])
    render :nothing => true
  end
  
end
