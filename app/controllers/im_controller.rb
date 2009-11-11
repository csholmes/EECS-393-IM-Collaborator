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
          
    else #Start Listener
        MiddleMan.new_worker(:worker => :listener_worker, :worker_key => params[:login]+"_receive")
        @listener = MiddleMan.worker(:listener_worker, params[:login]+"_receive")
        @listener.async_listen(:arg => login_info)
          
        buddylist
    end     
  end
  
  def buddylist
    @buddies = @worker.getbuddylist
    @worker.logout
    
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
    
    worker = MiddleMan.worker(:connector_worker, session[:login])
    msg_info = [params[:buddy], params[:msg]]
  
    @user = params[:buddy]
    @text = params[:text] + "Me: " + params[:msg] + "<br/>"
    
    render :partial => "displaymessage"
    
    worker.login(:arg => [session[:login], session[:password]])
    worker.message(:arg => msg_info)
    worker.logout
  end
  
end
