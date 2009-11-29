require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/client'
require 'xmpp4r/roster/helper/roster'

class ConnectorWorker < BackgrounDRb::MetaWorker
  set_worker_name :connector_worker
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def login (arg)
    #Get params
    @pass = arg.pop
    @user = arg.pop
  
    #log in
    begin
      jid = Jabber::JID.new(@user)
      @cl = Jabber::Client.new(jid)
      @cl.connect
      @cl.auth(@pass)
      
      pres = Jabber::Presence.new.set_type(:available)
      @cl.send(pres)
    rescue
      return false
    else
      return true
    end
  end
  
  def getbuddylist
    
    @buddylist = Array.new
    @roster = Jabber::Roster::Helper.new(@cl)

    mainthread = Thread.current

    @roster.add_query_callback { |iq|
      mainthread.wakeup
    }

    Thread.stop

    @roster.groups.each { |group|

      @roster.find_by_group(group).each { |item|
        @buddylist.push(item.jid)
      }
    }
    
    return @buddylist
  
  end
  
  def update_status
    #This will update the status
    #pres = Jabber::Presence.new.set_type(:available)
    #@cl.send(pres)
  end
  
  def message(arg)
    #Get params
    msg = arg.pop
    to = arg.pop
    
    #Send Message
    m = Jabber::Message::new(to, msg).set_type(:normal) #.set_id('1')
    @cl.send(m)    
  end

  def logout
    @cl.close
  end
  
  def send_message(arg)
    
    login_info = arg.pop
    msg_info = arg.pop
    
    login(:arg => login_info)
    message(:arg => msg_info)
    logout
        
  end

  def listen_manager
      thread_pool.defer(:listen)
  end

  def listen

    @cl.add_presence_callback do |pres|

      begin
          #Juggernaut.send_to_all("alert('Presence Received: From: " + pres.from.to_s + "')")
      rescue
          #Juggernaut.send_to_all("alert('Presence Received but error')")
      end
        #Juggernaut.send_to_all("alert('Presence Received')")
    end

    @cl.add_message_callback do |message|

      from = message.from.to_s.split("/").first
      body = message.body.to_s

      begin
          Juggernaut.send_to_all("javascript:message('" + from + "', '" + body + "')")
          #Juggernaut.send_to_all("alert('Message Received: " + from + ": " + body + "')")
      rescue
          Juggernaut.send_to_all("alert('Message Received')")
      end
    end

    Thread.stop
  end

end

