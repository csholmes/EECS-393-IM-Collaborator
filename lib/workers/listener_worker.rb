require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/client'
require 'xmpp4r/roster/helper/roster'
require 'juggernaut'

class ListenerWorker < BackgrounDRb::MetaWorker
  set_worker_name :listener_worker
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end
  
  def listen(arg)

     @pass = arg.pop
     @user = arg.pop

     begin

       Jabber::debug = true

       #log in
       jid = Jabber::JID.new(@user)
       @cl = Jabber::Client.new(jid)
       @cl.connect
       @cl.auth(@pass)
       pres = Jabber::Presence.new.set_type(:available)
       @cl.send(pres)
     rescue
       Juggernaut.send_to_all("alert('Connection Problem')")
     else
       Juggernaut.send_to_all("alert('Connected successfully')")
     end

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

