class Volunteer < ActiveRecord::Base
  belongs_to :transport_type
  belongs_to :cell_carrier
  has_many :assignments
  has_many :regions, :through => :assignments

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :photo, :styles => { :thumb => "50x50", :small => "200x200", :medium => "500x500" }

  # column-level restrictions
  def admin_notes_authorized?
    current_user.admin
  end
  # column-level restrictions
  def admin_authorized?
    current_user.admin
  end

  # ActiveScaffold CRUD-level restrictions
  def authorized_for_update?
    current_user.admin or self.email == current_user.email
  end
  def authorized_for_create?
    current_user.admin
  end
  def authorized_for_delete?
    current_user.admin or self.email == current_user.email
  end

  # Admin info accessors
  def super_admin?
    current_user.admin
  end
  def region_admin?(r=nil)
    current_user.assignments.each{ |a|
      return true if (a.admin and r.nil?) or (a.admin and r == a.region)
    }
    return false
  end
  def any_admin?
    self.super_admin? or self.region_admin?
  end

  def sms_email
    return nil if self.cell_carrier.nil? or self.phone.nil? or self.phone.strip == ""
    return nil unless self.phone.tr('^0-9','') =~ /^(\d{10})$/
    # a little scary that we're blindly assuming the format is reasonable, but only admin can edit it...
    return sprintf(self.cell_carrier.format,$1) 
  end 

  def main_region
    self.regions[0]
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :admin_notes, :email, :gone_until, :has_car, :is_disabled, :name, :on_email_list, :phone, :pickup_prefs, :preferred_contact, :transport, :sms_too, :transport_type, :cell_carrier, :cell_carrier_id, :transport_type_id
end
