require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/client'
require 'xmpp4r/roster/helper/roster'
require 'juggernaut'

class ImController < ApplicationController

  def index
    if params[:message].nil?
      @loginerror = ""
    else
      @loginerror = params[:message]
    end
    
    respond_to do |format|
      format.html 
    end
  end
  
  def buddies #logs in
    
    #Session Vars
    session[:login] = params[:login]
    session[:password] = params[:password] 
            
    #start worker
    MiddleMan.new_worker(:worker => :connector_worker, :worker_key => params[:login])
    @worker = MiddleMan.worker(:connector_worker, params[:login])#Session Vars

    #log in
    login_info = [params[:login], params[:password]]      
    if not @worker.login(:arg => login_info)
      redirect_to (:action => "index", :message => "Incorrect ID/Password Pair")
    else

      buddylist #get the buddylist
    
      #display page
      respond_to do |format|
        format.html 
      end
      
      @worker.async_listen_manager(:arg => params[:login]) #start listening
    end
  end
  

  
  def buddylist
    @buddies = @worker.getbuddylist
    
    if @buddies.nil? 
       @buddies = "" 
    end
    
    #render :partial => "buddylist"
  end
  
  def sendmessage
    
    #Send message
    worker = MiddleMan.worker(:connector_worker, session[:login])
    worker.message(:arg => [params[:to], params[:msg]])

    #display nothing
    render :nothing => true
  end

  def logout
    #log out from worker, and kill worker
    if MiddleMan.worker(:connector_worker, session[:login])
      worker = MiddleMan.worker(:connector_worker, session[:login])
      worker.logout
      MiddleMan.delete_worker(:worker => :connector_worker, :worker_key => session[:login])
    end
    
    #display nothing
    render :nothing => true
  end
  
  def changepresence
    
    case params[:pres]
    when "available"
      pres = :available
    when "dnd"
      pres = :dnd
    when "away"
      pres = :away
    end
    
    worker = MiddleMan.worker(:connector_worker, session[:login])
    worker.update_presence(:arg => pres)
    
  end
end
