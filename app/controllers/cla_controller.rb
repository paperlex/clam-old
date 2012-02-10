class ClaController < ApplicationController
  
  def new
    if params[:org].present?
      @org = params[:org]
      @repo = JSON.parse(RestClient.get("https://api.github.com/repos/#{params[:org]}/#{params[:repo]}", "Authorization" => "token #{session[:auth_token]}"))
    else
      @repo = JSON.parse(RestClient.get("https://api.github.com/repos/#{@current_user.github_login}/#{params[:repo]}", "Authorization" => "token #{session[:auth_token]}"))
    end
    if params[:cla].present?
      @slaw = Paperlex::Slaw.find(params[:cla])
      @response_keys = @slaw["response_keys"]
      @cla = ClaTemplate.new(:slaw_uuid => params[:cla])
    end
  end
  
  def preview
    owner_responses = {}
    
    for field in params[:survey]
      key = field.first
      values = field.last
      if not values[:field_value].blank?
        owner_responses[key] = values[:field_value]
      end
    end
    
    render :text => Paperlex::Slaw.find(params[:slaw_uuid]).to_html(owner_responses)
  end
  
  def create
    if @current_user.contributor_license_agreements.count(:conditions => {:repo_name => params[:cla][:repo_name], :org_name => params[:cla][:org_name]}) > 0
      return redirect_to :controller => "repositories", :action => "index"
    end
    
    owner_responses = {}
    
    @slaw = Paperlex::Slaw.find(params[:slaw_uuid])
    @response_keys = @slaw["response_keys"]
    @cla = ClaTemplate.new(:slaw_uuid => params[:slaw_uuid])

    @cla.name = params[:cla_name]
    @cla.user_form = []
    @cla.owner_form = []
    for field in params[:survey]
      key = field.first
      values = field.last
      if values[:field_value].blank?
        @cla.user_form << {key => values}
      else
        @cla.owner_form << {key => values}
        owner_responses[key] = values[:field_value]
      end
    end
    @cla.save

    @current_user.contributor_license_agreements.create(:cla_template_id => @cla.id, :repo_name => params[:cla][:repo_name], :org_name => params[:cla][:org_name], :owner_responses => owner_responses)
    
    redirect_to :action => "index"
  end
  
  def show
    if params[:login] == @current_user.github_login
      @cla = @current_user.contributor_license_agreements.find_by_repo_name(params[:repo_name])
    else
      @cla = @current_user.contributor_license_agreements.find_by_repo_name_and_org_name(params[:repo_name], params[:login])
    end
    @clat = ClaTemplate.find(@cla.cla_template_id)
    @text = Paperlex::Slaw.find(@clat.slaw_uuid).to_html(@cla.owner_responses)
  end
  
  def signers 
    if params[:login] == @current_user.github_login
      @cla = @current_user.contributor_license_agreements.find_by_repo_name(params[:repo_name])
    else
      @cla = @current_user.contributor_license_agreements.find_by_repo_name_and_org_name(params[:repo_name], params[:login])
    end
  end
  
  def show_signed
    @contract = @current_user.contracts.find_by_uuid(params[:id])
    @signature = @contract.signature
    @text = Paperlex::Contract.find(@contract.uuid).to_html
  end
  
  def affix_signature
    @contract = @current_user.contracts.find(:first, :conditions => {:uuid => params[:contract_id]})
    contract = Paperlex::Contract.find(@contract.uuid)
    
    @user = User.find_by_github_login(params[:github_login])
    if @user.blank?
      @cla = ContributorLicenseAgreement.find_by_repo_name_and_org_name(params[:repo_name], params[:github_login])
    else
      @cla = @user.contributor_license_agreements.find_by_repo_name(params[:repo_name])
    end
        
    if params[:agree].blank? or params[:agree] != "yes"
      @error = "You must agree to terms of the agreement..."
      @text = contract.to_html
      return render(:action => :remote_sign)
    end
    
    begin
      contract.create_signature(:signer => @current_user.github_email, :identity => {:value => @current_user.github_login, :method => "GitHub OAuth", :github_id => @current_user.github_id, :github_email => @current_user.github_email}, :remote_ip => request.remote_ip, :user_agent => request.user_agent)
    rescue
      @error = "There was a problem signing the contract... please try again later."
      @text = contract.to_html
      return render(:action => :remote_sign)
    end
    
    redirect_to "/cla"
  end
  
  def sign
    @user = User.find_by_github_login(params[:github_login])
    if @user.blank?
      @cla = ContributorLicenseAgreement.find_by_repo_name_and_org_name(params[:repo_name], params[:github_login])
      @process_url = params[:github_login]
    else
      @cla = @user.contributor_license_agreements.find_by_repo_name(params[:repo_name])
      @process_url = @user.github_login
    end
    @clat = ClaTemplate.find(@cla.cla_template_id)
    @signature = @cla.signatures.find(:first, :conditions => {:user_id => @current_user.id})
    @contract = @current_user.contracts.find(:first, :conditions => {:contributor_license_agreement_id => @cla.id})
  end
  
  def process_form
    @user = User.find_by_github_login(params[:github_login])
    if @user.blank?
      @cla = ContributorLicenseAgreement.find_by_repo_name_and_org_name(params[:repo_name], params[:github_login])
      @process_url = params[:github_login]
    else
      @cla = @user.contributor_license_agreements.find_by_repo_name(params[:repo_name])
      @process_url = @user.github_login
    end
    @clat = ClaTemplate.find(@cla.cla_template_id)
    @signature = @cla.signatures.find(:first, :conditions => {:user_id => @current_user.id})
    @contract = @current_user.contracts.find(:first, :conditions => {:contributor_license_agreement_id => @cla.id})
    
    if @signature.present?
      return redirect_to(:action => "index")
    end
    
    required_fields = []
    for line in @clat.user_form
      key = line.keys.first
      field_info = line[key]
      
      required_fields << key if field_info["optional"] == "0"
    end
    
    @error = false
    for key in required_fields
      @error = true if params[:user_responses][key].blank?
    end
    if @error
      @contract = Contract.new(:responses => params[:user_responses])
      return render :action => "sign"
    end
    
    if @contract.blank?
      c = Contract.create(:user => @current_user, :contributor_license_agreement => @cla, :responses => params[:user_responses])
      
      contract = Paperlex::Contract.create({:subject => "Contributor License Agreement", :number_of_signers => 1, :responses => (c.responses.merge(@cla.responses)), :signature_callback_url => "#{CALLBACK_URL}/callback/signature", :slaw_id => ClaTemplate.find(:first).slaw_uuid})
      
      c.update_attribute :uuid, contract.uuid
      
      signer = contract.create_signer(:email => @current_user.github_email)
      
      @text = contract.to_html
      
      # If you have access to the Remote Signature program, you don't need to create a review session...
      unless HAS_REMOTE_SIGNATURE_ACCESS
        review_session = contract.create_review_session(:email => @current_user.github_email, :expires_in => 24.hours)
        redirect_to(review_session.url)
      else
        @contract = c
        render :action => :remote_sign
      end

    else
      @contract.responses = params[:user_responses]
      @contract.save
      
      contract = Paperlex::Contract.find(@contract.uuid)
      contract.responses = @contract.responses.merge(@cla.responses)
      contract.save_responses
      
      contract.update_signer(contract.signers.first["uuid"], :email => @current_user.github_email)
      
      @text = contract.to_html
      
      # If you have access to the Remote Signature program, you can leave the next two lines out...
      unless HAS_REMOTE_SIGNATURE_ACCESS
        contract.fetch_review_sessions
        contract.update_review_session(contract.review_sessions.first.uuid, :expires_in => 24.hours, :email => @current_user.github_email)    
        redirect_to(contract.review_sessions.first.url)
      else
        render :action => :remote_sign
      end
      
    end
  end
  
end
