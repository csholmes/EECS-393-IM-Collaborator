require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/client'
require 'xmpp4r/roster/helper/roster'
require 'juggernaut'

class ImController < ApplicationController
  
  def login
    
    #Session Vars
    session[:login] = params[:login]
    session[:password] = params[:password] 
            
    #Login, start worker
    MiddleMan.new_worker(:worker => :connector_worker, :worker_key => params[:login])
    @worker = MiddleMan.worker(:connector_worker, params[:login])
    login_info = [params[:login], params[:password]]
          
    if not @worker.login(:arg => login_info)
        @loginerror = "Could not be logged in" #+ params[:login] + params[:password]
        render :partial => "login_error"        
          
    else 
        @worker.listen_manager
        buddylist
    end     
  end
  
  def buddylist
    @buddies = @worker.getbuddylist
    
    if @buddies.nil? 
       @buddies = "" 
    end
    
    render :partial => "buddylist"
  end
  
  def messagebox
    @user = params[:buddy]
    @text = ""
    render :partial => "displaymessage"
    
  end
  
  def sendmessage
    
    #Send message
    worker = MiddleMan.worker(:connector_worker, session[:login])
    worker.message(:arg => [params[:to], params[:msg]])

    #display nothing
    render :nothing => true
  end
  
end
