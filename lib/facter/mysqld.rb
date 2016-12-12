# mysqld

Facter.add('mysqld') do
  setcode do
    Facter::Core::Execution.exec('/bin/true')
  end
end
