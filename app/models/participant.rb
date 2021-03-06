class Participant < ActiveRecord::Base
	validates :login, uniqueness: true
	validates :login, :game, presence: true
	validates_with EtuUttLoginValidator, on: :create

	belongs_to :game

	#has_many :hunters, :through => :hunter, :source => :target
	#has_many :targets, :through => :pursu, :source => :target

	has_many :targets, foreign_key: "hunter_id", class_name: 'Target'
	has_many :hunters, foreign_key: "pursued_id", class_name: 'Target'

	#has_many :targeter_players, through: :hunters, source: :hunter
	#has_many :targeted_players, through: :targets, source: :pursued
	
	has_paper_trail

	scope :pending, ->{ where(paid: false) }
	scope :validated, ->{ where(paid: true) }

	def to_param
		login
	end

	# Get the target that the current participant have to kill
	def target 
		#Target.healthy.where(hunter: self).take.try(:pursued) || Target.suffering.where(hunter: self).take.try(:pursued)
		targets.healthy.last.try(:pursued) || targets.suffering.last.try(:pursued)
	end

	# Get the hunter of the current participant
	def hunter
		#Target.healthy.where(pursued: self).take.try(:hunter) || Target.suffering.where(pursued: self).take.try(:hunter)
		hunters.healthy.last.try(:hunter) || hunters.suffering.last.try(:hunter)
	end

	def alive?
		!dead?
	end

	def dead?
		Target.killed.where(pursued: self).present?
	end

	def suffering?
		Target.suffering.where(pursued: self).present?
	end

	### Delegation

	def kill!
		Target.healthy.where(pursued: self).take.try(:kill!) || false
	end

	def may_kill?
		Target.healthy.where(pursued: self).take.try(:may_kill?) || false
	end

	def confirm_kill!
		t = Target.suffering.where(pursued: self).take || Target.healthy.where(pursued: self).take
		t.confirm_kill!
	end

	def deny_kill!
		Target.suffering.where(pursued: self).take.deny_kill!
	end

	def recognize_as_unreached!
		t = Target.healthy.where(pursued: self).take || Target.suffering.where(pursued: self).take
		t.recognize_as_unreached!
	end

	# Return who killed me
	def killer
		hunters.last.try(:hunter)
	end

	def to_s
		"#{first_name} #{last_name}"
	end

end
