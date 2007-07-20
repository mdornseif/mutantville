require File.dirname(__FILE__) + '/../test_helper'

class LoginTest < Test::Unit::TestCase
  
  fixtures :logins
    
  def test_auth
    
    assert_equal  @bob, Login.authenticate("bob", "atest")    
    assert_nil Login.authenticate("nonbob", "atest")
    
  end


  def test_passwordchange
        
    @longbob.change_password("nonbobpasswd")
    @longbob.save
    assert_equal @longbob, Login.authenticate("longbob", "nonbobpasswd")
    assert_nil Login.authenticate("longbob", "alongtest")
    @longbob.change_password("alongtest")
    @longbob.save
    assert_equal @longbob, Login.authenticate("longbob", "alongtest")
    assert_nil Login.authenticate("longbob", "nonbobpasswd")
        
  end
  
  def test_disallowed_passwords
    
    u = Login.new    
    u.login = "nonbob"

    u.change_password("")
    assert !u.save     
    assert u.errors.invalid?('password')

    u.change_password("hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge" * 10)
    assert !u.save     
    assert u.errors.invalid?('password')
        
    u.change_password("")
    assert !u.save    
    assert u.errors.invalid?('password')
        
    u.change_password("bobs_secure_password")
    assert u.save     
    assert u.errors.empty?
        
  end
  
  def test_bad_logins

    u = Login.new  
    u.change_password("bobs_secure_password")

    u.login = ""
    assert !u.save     
    assert u.errors.invalid?('login')
    
    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.errors.invalid?('login')

    u.login = ""
    assert !u.save
    assert u.errors.invalid?('login')

    u.login = "okbob"
    assert u.save  
    assert u.errors.empty?
      
  end


  def test_collision
    u = Login.new
    u.login = "existingbob"
    u.change_password("bobs_secure_password")
    assert !u.save
  end


  def test_create
    u = Login.new
    u.login = "nonexistingbob"
    u.change_password("bobs_secure_password")
      
    assert u.save  
    
  end
  
end
