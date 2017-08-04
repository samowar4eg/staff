# Abstract class
class Employee
  attr_accessor :name

  def initialize(name)
    @name = name
    @boss = nil
  end

  def print
    puts @name
  end

  def access_level
    0
  end
end

# Main class
class Staff < Employee
  def initialize(name)
    super
    @subordinates = []
  end

  def hire(employee)
    check_staff(employee) # argument check, necessary only here, as there is no other way to join staff tree
    subordinates << employee
    employee.boss = self
  end

  def fire(employee, alternate)
    # hire only new staff, transfer subordinates to existing staff
    hire alternate unless hired? alternate
    transfer_staff(employee, alternate) # redirect all staff members to new boss
    subordinates.delete(employee) { raise 'can not fire colleague' } # remove employee if able
  end

  def print(offset = 0)
    puts '  ' * offset + name
    subordinates.each do |employee|
      employee.print(offset + 1)
    end
  end

  def access_level(level = 0)
    return level if boss.nil?
    level += 1
    boss.access_level(level)
  end

  protected

  def boss=(employee)
    @boss = employee
  end

  def subordinates
    @subordinates
  end

  def subordinates=(staff)
    @subordinates = staff
  end

  def top_boss # used to find top of staff tree
    return self if boss.nil?
    boss.top_boss
  end

  private

  def boss
    @boss
  end

  def gather_all_employees(staff, results = []) # collects all existing employees into array
    staff.subordinates.each do |employee|
      results << employee
      gather_all_employees(employee, results)
    end
    results
  end

  def hired?(employee)
    # it is always needed to check all existing employees starting from the head of the tree,
    # so not to miss staff in other branches
    gather_all_employees(top_boss).include? employee
  end

  def transfer_staff(employee, alternate) # assigns a new boss to the staff
    alternate.subordinates += employee.subordinates
    employee.subordinates.each do |sub|
      sub.boss = alternate
    end
  end

  def check_staff(staff)
    raise ArgumentError unless staff.instance_of? self.class
  end
end

# add main staff 'boss'
a = Staff.new('boss')

# boss hires 3 employees level 1
b = Staff.new('b')
c = Staff.new('c')
d = Staff.new('d')

a.hire b
a.hire c
a.hire d

# one of hired employees (level 1) hires other 3 employees level 2
b1 = Staff.new('b1')
b2 = Staff.new('b2')
b3 = Staff.new('b3')

b.hire b1
b.hire b2
b.hire b3

# one of hired employees (level 1) hires other 2 employees level 2
d1 = Staff.new('d1')
d2 = Staff.new('d2')

d.hire d1
d.hire d2

# one of hired employees (level 2) hires other 3 employees level 3
b21 = Staff.new('b21')
b22 = Staff.new('b22')
b23 = Staff.new('b23')

b2.hire b21
b2.hire b22
b2.hire b23

p 'print staff hierarchy'
a.print
puts '--------------------------------------'

p 'boss b (level 1) fires 1 employee b2 and transfer his staff to existing employee b3'
b.fire b2, b3
a.print
puts '--------------------------------------'
p 'boss b (level 1) fires 1 employee b3 and hires other brand new employee instead'
b4 = Staff.new('b4')
b.fire b3, b4
a.print
puts '--------------------------------------'

p 'boss a (level 0) fires 1 employee d (level 1) and transfer his staff to other existing employee b4 (level 3) instead'
a.fire d, b4
a.print
puts '--------------------------------------'

p 'try to fire employee with the same level'
begin
  b.fire c, b4
rescue => e
  p e.message
end
a.print
puts '--------------------------------------'

p 'fire employee who hired no staff'
a.fire c, b4
a.print
puts '--------------------------------------'

p 'fire employee who is already fired'
begin
  a.fire c, b4
rescue => e
  p e.message
end
a.print
puts '--------------------------------------'

p 'find someones (d2) access level'
p "d2 level #{d2.access_level}"

puts '--------------------------------------'
