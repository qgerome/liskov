class CourseMembership < ActiveRecord::Base
  ROLES = %w{Student Mentor Instructor}

  belongs_to :course

  validates_presence_of   :course_id, :role, :person_github_nickname
  validates_uniqueness_of :person_github_nickname, :scope => :course_id
  validate :person_permissions

  scope :for_person, lambda { |person| where(person_github_nickname: person.github_nickname) }

  def person
    @person ||= Clubhouse::Client::Person.new(person_github_nickname)
  rescue Clubhouse::Client::PersonNotFound
    return nil
  end

  def has_role?(has_role)
    has_role.to_s.capitalize == role.capitalize
  end

  private

  def person_permissions
    if person.nil?
      errors.add(:person_github_nickname, "is not valid")
    elsif person.permissions['Liskov'].nil?
      errors.add(:person_github_nickname, "does not have access to Liskov")
    end
  end
end
