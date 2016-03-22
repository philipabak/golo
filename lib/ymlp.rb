require 'cgi'

module YMLP
  class Client

    YMLP_API_KEY="QGECREQTHTP7Y05G58FU"
    YMLP_USERNAME="marianna"
    YMLP_URL="https://www.ymlp.com/api/"
    YMLP_QUERY="?Key=#{YMLP_API_KEY}&Username=#{YMLP_USERNAME}&Output=json"
    WEB_FORM_URL="http://ymlp.com/subscribe.php?id=gewqwbegmgh"

    def subscribe_users
      users = User.find(:all, :conditions => "on_mailing_list=false")
      return if users.blank?

      user_id_field_id = get_user_id_field_id
      golo_group_id = get_golo_group_id
      
      users.each { |user|
        if user.old_email.nil?
          # do this via a web form to trigger the autoresponse
          add_contact_web_form(user, user_id_field_id, golo_group_id)
        else
          # keep going even if remove failed
          unsubscribe_and_remove(user, user_id_field_id, golo_group_id)
          add_contact(user, user_id_field_id, golo_group_id)
        end
        
        user.update_attributes :on_mailing_list => true, :old_email => nil
        $stderr.puts "Error updating user: #{user.errors.inspect}" unless user.errors.blank?
      }
    end

    protected

    def add_contact_web_form(user, user_id_field_id, golo_group_id)
      result = `curl -s -o /dev/null -D - -d 'YMP0=#{user.email}&YMP#{user_id_field_id}=#{user.id}' '#{WEB_FORM_URL}' | grep '200 OK'`
      $stderr.puts "Could not add user: #{user.email} (#{user.id}). Response: #{result}" unless result =~ /200 OK/
    end

    def add_contact(user, user_id_field_id, golo_group_id)
      json = call("Contacts.Add", "Field#{user_id_field_id}" => user.id, "GroupID" => golo_group_id, "Email" => user.email)
      response = ActiveSupport::JSON.decode json
      $stderr.puts "Could not add user: #{user.email} (#{user.id}). Response: #{response.inspect}" unless response["Code"] == "0"
    end

    def unsubscribe_and_remove(user, user_id_field_id, golo_group_id)
      # remove from golo group (must do this before unsubscribing)
      json = call("Contacts.Delete", "Email" => user.old_email, "GroupID" => golo_group_id)
      response = ActiveSupport::JSON.decode json
      unless response["Code"] == "0"
        $stderr.puts "Could not remove user's old email from golo group: #{user.old_email} (#{user.id}). Response: #{response.inspect}"
        return false
      end
      # unsubscribe old email
      json = call("Contacts.Unsubscribe", "Email" => user.old_email)
      response = ActiveSupport::JSON.decode json
      unless response["Code"] == "0"
        $stderr.puts "Could not unsubscribe user's old email: #{user.old_email} (#{user.id}). Response: #{response.inspect}"
        return false
      end
      return true
    end

    def get_user_id_field_id
      user_id_field_id = nil
      json = call "Fields.GetList"
      fields = ActiveSupport::JSON.decode json
      fields.each { |field|
        if field["FieldName"] == "user_id"
          user_id_field_id = field["ID"]
          break
        end
      }
      raise "Could not find \"user_id\" field." if user_id_field_id.nil?
      return user_id_field_id
    end

    def get_golo_group_id
      golo_group_id = nil
      json = call "Groups.GetList"
      groups = ActiveSupport::JSON.decode json
      groups.each { |group|
        if group["GroupName"] == "golo"
          golo_group_id = group["ID"]
          break
        end
      }
      raise "Could not find \"golo\" group." if golo_group_id.nil?
      return golo_group_id
    end

    def call(command, params={})
      url = "#{YMLP_URL}#{command}#{YMLP_QUERY}"
      params.each_pair {|k,v|
        url << "&#{k}=#{CGI.escape(v.to_s)}"
      }
      `curl -s '#{url}'`
    end
  end
end
