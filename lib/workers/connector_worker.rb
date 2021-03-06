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
  
  def update_presence(arg) #This will update the presence
    pres = Jabber::Presence.new.set_type(arg)
    @cl.send(pres)
  end
  
  def message(arg)
    #Get params
    msg = arg.pop
    to = arg.pop
    
    #Send Message
    m = Jabber::Message::new(to, msg).set_type(:normal) #.set_id('1')
    @cl.send(m)    
    #Juggernaut.send_to_all("alert('Message Sent')");
  end

  def logout
    @cl.close
  end

  def listen_manager(arg)
      thread_pool.defer(:listen, arg)
  end

  def listen(arg)
    
    client = arg
  
    @cl.add_presence_callback do |pres|
      
      from = pres.from.to_s.split("/").first
      show = pres.show.to_s
      
      Juggernaut.send_to_client("javascript:updatePresence('" + from + "', '" + show + "')", client)

    end

    @cl.add_message_callback do |message|

      from = message.from.to_s.split("/").first
      body = message.body.to_s

      begin
          Juggernaut.send_to_client("javascript:message('" + from + "', '" + body + "')", client)
      rescue
          Juggernaut.send_to_client("alert('Message Received')", client)
      end
    end

    Thread.stop
  end

end

